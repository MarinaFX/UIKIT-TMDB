//
//  TMDBService.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation
import UIKit

struct TMDBService {
    //MARK: - Variables setup
    
    private let BASE_IMAGE_URL: String = "https://image.tmdb.org/t/p/w154"
    
    func getUrl(param: String, pages: Int) -> String {
        return "https://api.themoviedb.org/3/movie/\(param)?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=\(pages)"
    }
    
    var movies: [Movie]?
    
    //MARK: - URLSession - Popular Movies
    
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
