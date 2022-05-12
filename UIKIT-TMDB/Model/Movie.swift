//
//  Movie.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation
import UIKit

class Movie: Codable, CustomStringConvertible, Equatable {
    let id: Int
    let title: String
    let overview: String
    let rating: Double
    
    var posterPath: String?
    var imageCover: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case rating
    }
    
    init(id: Int, title: String, overview: String, rating: Double, posterPath: String? = "", imageCover: UIImage? = UIImage(named: "")) {
        self.id = id
        self.title = title
        self.overview = overview
        self.rating = rating
        self.posterPath = posterPath
        self.imageCover = imageCover
    }
    
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try values.decode(Int.self, forKey: .id)
//        self.title = try values.decode(String.Type, forKey: .title)
//        self.overview = try values.decode(String.Type, forKey: .overview)
//        self.rating = try values.decode(Double.Type, forKey: .rating)
//    }

    var description: String {
        return "The movie \(title) with ID of \(id) has \(rating) of rating. Description: \(overview) \n"
    }
    
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.overview == rhs.overview
    }
}
