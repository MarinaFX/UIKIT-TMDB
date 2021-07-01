//
//  TMDBService.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation

struct TMDBService {
    //MARK: - Class and variables setup
    let urlString: String = "https://api.themoviedb.org/3/movie/popular?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=1"
    
    //MARK: - URLSession - Popular Movies
    func requestPopularMovies(pages: Int = 1, using completionHandler: @escaping ([Movie]) -> Void) {
        if pages < 0 { fatalError("The number of pages is invalid. Pages count: \(pages)") }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            print(response)
        }
        .resume()
    }
    
    //MARK: - URLSession - Now Playing Movies
}
