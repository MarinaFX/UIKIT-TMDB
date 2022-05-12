//
//  TMDBService.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation
import UIKit
import Combine

//typealias MovieJSON = [String: Any]

enum MovieType: CustomStringConvertible {
    var description: String {
        switch self {
            case .popular: return "popular"
            case .nowPlaying: return "now_playing"
        }
    }
    
    case popular
    case nowPlaying
}

class TMDBService {
    //MARK: - Variables setup
    
    private let BASE_IMAGE_URL: String = "https://image.tmdb.org/t/p/w500"
    private var disposables: Set<AnyCancellable> = []
    
    func getUrl(param: String, pages: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(param)?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=\(pages)"
    }
    
    var popularMoviesPublisher: CurrentValueSubject<[Movie], Never> = .init([])
    var nowPlayingMoviesPublisher: CurrentValueSubject<[Movie], Never> = .init([])
    
    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    
    //MARK: - URLSession - Popular Movies
    
    /**
     Request movies by creating a subscription that returns a movie whenever the publisher is updated
     
     - Parameters:
        - type: Popular or now playing movies
        - pages: what pages to fetch movies from API
     */
    func requestMovies(for type: MovieType, at pages: Int = 1) {
        if pages < 0 { fatalError("The number of pages is invalid. Pages count: \(pages)") }
        
        guard let url = URL(string: getUrl(param: type.description, pages: pages)) else { return }
        
        typealias MovieJSON = [String: Any]
        typealias TemporaryMovie = (id: Int, title: String, overview: String, rating: Double, posterPath: String)
                
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { try JSONSerialization.jsonObject(with: $0.data) }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    fatalError("error error error: \(error.localizedDescription)")
                case .finished:
                    print("completion finished successfully. All movies were fetched")
                }
            }, receiveValue: { [weak self] `any` in
                let JSON = `any` as! [String: Any]
                let JSONmovies = JSON["results"] as! [MovieJSON]

                for movieJSON in JSONmovies {
                    guard let id = movieJSON["id"] as? Int,
                          let title = movieJSON["original_title"] as? String,
                          let overview = movieJSON["overview"] as? String,
                          let rating = movieJSON["vote_average"] as? Double,
                          let posterPath = movieJSON["poster_path"] as? String
                    else { continue }
                    
                    let movie = Movie(id: id, title: title, overview: overview, rating: rating, posterPath: posterPath)
                    
                    type == .popular ? self?.popularMovies.append(movie) : self?.nowPlayingMovies.append(movie)
                }
                if type == .popular {
                    self?.popularMoviesPublisher.send(self?.popularMovies ?? [])
                    self?.fetchMoviePoster(for: .popular)
                }
                else {
                    self?.nowPlayingMoviesPublisher.send(self?.nowPlayingMovies ?? [])
                    self?.fetchMoviePoster(for: .nowPlaying)
                }
            })
            .store(in: &disposables)
        
    }
    
    func fetchMoviePoster(for type: MovieType) {
        var localMovies: [Movie] = []
        if type == .popular {
            localMovies = popularMovies
        }
        else {
            localMovies = nowPlayingMovies
        }
        
        for movie in localMovies {
            URLSession.shared.dataTaskPublisher(for: URL(string: BASE_IMAGE_URL + movie.posterPath!)!)
                .tryMap { $0.data }
                .subscribe(on: DispatchQueue.global())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                    case .finished:
                        print("completion finished successfully. All images were fetched")
                    }
                }, receiveValue: { image in
                    let image = UIImage(data: image)
                    movie.imageCover = image
                })
                .store(in: &disposables)
        }
        
        if type == .popular {
            self.popularMoviesPublisher.send(localMovies)
        }
        else {
            self.nowPlayingMoviesPublisher.send(localMovies)
        }
        
    }
    
    /**
     Request movies with @escaping completion
     
     - Parameters:
        - type: Popular or now playing movies
        - pages: what pages to fetch movies from API
        - completionHandler: ``[Movie] -> Void``
     */
    func requestMovies(type: String, pages: Int = 1, using completionHandler: @escaping ([Movie]) -> Void) {
        if pages < 0 { fatalError("The number of pages is invalid. Pages count: \(pages)") }
        guard let url = URL(string: getUrl(param: type, pages: pages)) else { return }
        
        typealias MovieJSON = [String: Any]
        typealias TemporaryMovie = (id: Int, title: String, overview: String, rating: Double, posterPath: String)
        
        let dispatchSemaphore = DispatchSemaphore(value: 0)
        
        var localMovies: [Movie] = []
        var localTempMovies: [TemporaryMovie] = []
        
        //MARK: Movies request

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let unwrappedData = data,
                  let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: .fragmentsAllowed) as? [String: Any],
                  let movies = json["results"] as? [MovieJSON]
            else { dispatchSemaphore.signal(); return }
            
            for movieJSONObject in movies {
                guard let id = movieJSONObject["id"] as? Int,
                      let title = movieJSONObject["original_title"] as? String,
                      let overview = movieJSONObject["overview"] as? String,
                      let rating = movieJSONObject["vote_average"] as? Double,
                      let posterPath = movieJSONObject["poster_path"] as? String
                else { continue }
                
                let tempMovie = TemporaryMovie(id: id, title: title, overview: overview, rating: rating, posterPath: posterPath)
                localTempMovies.append(tempMovie)
                
                //print("🟡🟡🎥🟡🟡")
            }
            
            dispatchSemaphore.signal()
            //print("🟢🟢🎥🟢🟢")
        }
        .resume()
        
        //print("🔴🔴📸🔴🔴")
        dispatchSemaphore.wait()
        //print("🟢🟢📸🟢🟢")
        
        //MARK: Movie poster request
        
        let dispatchGroup = DispatchGroup()
        let imageSemaphore = DispatchSemaphore(value: 1)
        
        for tempMovie in localTempMovies {
            guard let url = URL(string: BASE_IMAGE_URL + tempMovie.posterPath) else { continue }
            dispatchGroup.enter()
            //print("🟡🟡📸🟡🟡")
            
            fetchMoviePoster(with: url) { image in
                let movie = Movie(id: tempMovie.id, title: tempMovie.title, overview: tempMovie.overview, rating: tempMovie.rating, imageCover: image)
                imageSemaphore.wait()
                localMovies.append(movie)
                imageSemaphore.signal()
                dispatchGroup.leave()
                //print("🟢🟢📸🟢🟢")
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .background)) {
            completionHandler(localMovies)
            //print("🟢🟢💯🟢🟢")
        }
        
    }
    
    
    //MARK: - URLSession - Poster Image
    
    func fetchMoviePoster(with url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else { completionHandler(nil); return }
            let image = UIImage(data: data)
            completionHandler(image)
        }
    }
    
    //MARK: - URLSession - Now Playing Movies
}
