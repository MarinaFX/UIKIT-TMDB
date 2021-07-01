//
//  MovieCell.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit

/*@IBDesignable*/ class MovieCell: UITableViewCell {
    
    //MARK: - Class and Variables Setup
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    //MARK: - UI Setup
//    override func prepareForInterfaceBuilder() {
//        commonInit()
//    }
//
//    func commonInit() {
//        coverImage.layer.cornerRadius = cornerRadius
//    }
    
    //MARK: - Inspectable Variables - cornerRadius
//    @IBInspectable var cornerRadius: CGFloat = 0 {
//        didSet {
//            coverImage.layer.cornerRadius = cornerRadius //storyboard esta crashando nessa linha. Seria por conta dos outlets? Estou tentando setar o corner radius de um outlet que ainda nao foi instanciado?
//        }
//    }
    
}
