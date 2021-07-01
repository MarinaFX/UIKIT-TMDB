//
//  TMDBService.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation
import UIKit

struct TMDBService {
    //MARK: - Class and variables setup
    
    private let BASE_IMAGE_URL: String = "https://image.tmdb.org/t/p/original"
    var movies: [Movie]?
    
    //MARK: - URLSession - Popular Movies
    
    func requestPopularMovies(pages: Int = 1, using completionHandler: @escaping ([Movie]) -> Void) {
        if pages < 0 { fatalError("The number of pages is invalid. Pages count: \(pages)") }
        
        typealias MovieJSON = [String: Any]

        let urlString: String = "https://api.themoviedb.org/3/movie/popular?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=\(pages)"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let unwrappedData = data,
                  let json = try? JSONSerialization.jsonObject(with: unwrappedData, options: .fragmentsAllowed) as? [String: Any],
                  let movies = json["results"] as? [MovieJSON]
            else { completionHandler([]); return }
            
            var localMovies: [Movie] = []
            
            for movieJSONObject in movies {
                guard let id = movieJSONObject["id"] as? Int,
                      let title = movieJSONObject["original_title"] as? String,
                      let overview = movieJSONObject["overview"] as? String,
                      let rating = movieJSONObject["vote_average"] as? Double,
                      let posterPath = movieJSONObject["poster_path"] as? String
                else { continue }
                
                let image = fetchMoviePoster(with: URL(string: BASE_IMAGE_URL + posterPath))
                
                let movie = Movie(id: id, title: title, overview: overview, rating: rating, imageCover: image)
                localMovies.append(movie)
            }
            
            completionHandler(localMovies)
            
        }
        .resume()
    }
    
    
    //MARK: - URLSession - Poster Image
    
    func fetchMoviePoster(with url: URL?) -> UIImage? {
        guard
            let url = url,
            let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    //MARK: - URLSession - Now Playing Movies
}
