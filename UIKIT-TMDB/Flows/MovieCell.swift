//
//  MovieCell.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit

@IBDesignable class UIRoundedImageView: UIImageView {
    //MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        commonInit()
    }

    func commonInit() {
        layer.cornerRadius = cornerRadius
    }
    
    //MARK: - Inspectable Variables - cornerRadius
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

class MovieCell: UITableViewCell {
    
    //MARK: - Class and Variables Setup
    @IBOutlet weak var coverImage: UIRoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.coverImage.layer.cornerRadius = 15
    }
}
