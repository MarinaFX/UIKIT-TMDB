//
//  UIKIT_TMDBTests.swift
//  UIKIT-TMDBTests
//
//  Created by Marina De Pazzi on 11/05/22.
//

import XCTest
import Combine
@testable import UIKIT_TMDB

class UIKIT_TMDBTests: XCTestCase {
    
    var sut: TMDBService!
    var movies: [Movie] = []
    var disposables: Set<AnyCancellable> = []
    var image: UIImage?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        sut = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        sut = nil
    }
    
    func testRequestMoviesWithCombine() {
        let movieCollectionExpectation = expectation(description: "async movie download with combine")
        
        sut.popularMoviesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.movies = movies
                movieCollectionExpectation.fulfill()
            }
            .store(in: &disposables)
        
        sut.requestMovies(for: .popular, at: 1)

        
        wait(for: [movieCollectionExpectation], timeout: 5)
        
        XCTAssertNotNil(self.movies)
    }
    
    func testRequestMoviesWithCompletion() {
        let movieCollectionExpectation = expectation(description: "async movie download with completion")
        
        sut.requestMovies(type: "popular", pages: 1) { [weak self] movies in
            self?.movies = movies
            movieCollectionExpectation.fulfill()
        }
        
        wait(for: [movieCollectionExpectation], timeout: 5)
        
        XCTAssertNotNil(self.movies)
    }
    
    func testRequestMoviePosterWithCombine() {
        let moviePosterExpectation = expectation(description: "async movie poster download with combine")
        
        let url = URL(string: "https://image.tmdb.org/t/p/w500/6DrHO1jr3qVrViUO6s6kFiAGM7.jpg")!
        
        
    }
    
    func testRequestMoviePosterWithCompletion() {
        let moviePosterExpectation = expectation(description: "async movie poster download with completion")
        let url = URL(string: "https://image.tmdb.org/t/p/w500/6DrHO1jr3qVrViUO6s6kFiAGM7.jpg")!
        
        sut.fetchMoviePoster(with: url) { [weak self] image in
            self?.image = image
            moviePosterExpectation.fulfill()
        }
        
        wait(for: [moviePosterExpectation], timeout: 4)
        
        XCTAssertNotNil(self.image)
    }
    
    

//    func testMovieRequestWithCombinePerformance() throws {
//        let movieCollectionExpectation = expectation(description: "async movie download with combine")
//
//        measure {
//            sut.popularMoviesPublisher
//                .receive(on: DispatchQueue.main)
//                .sink { [weak self] movies in
//                    self?.movies = movies
//                    movieCollectionExpectation.fulfill()
//                }
//                .store(in: &disposables)
//
//        }
//        sut.requestMovies(for: .popular, at: 1)
//
//        wait(for: [movieCollectionExpectation], timeout: 5)
//
//        XCTAssertNotNil(self.movies)
//    }

    
    func testMovieRequestWithCompletionPerformance() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
