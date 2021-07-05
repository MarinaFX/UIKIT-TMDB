//
//  Movie.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import Foundation
import UIKit

struct Movie: CustomStringConvertible, Equatable {
    let id: Int
    let title: String
    let overview: String
    let rating: Double
    
    var imageCover: UIImage?

    var description: String {
        return "The movie \(title) with ID of \(id) has \(rating) of rating. Description: \(overview) \n"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.overview == rhs.overview
    }
}
