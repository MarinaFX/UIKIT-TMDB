//
//  MovieOverviewCell.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 02/07/21.
//

import UIKit

class MovieOverviewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
