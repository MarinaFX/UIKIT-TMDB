//
//  MovieDetailViewController.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 02/07/21.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    //MARK: - Class and Variables Setup
    
    @IBOutlet weak var tableView: UITableView!
    
    let moviePresentationCellID: String = "moviePresentationCell"
    let movieOverviewCellID: String = "movieOverviewCell"
    
    var movie: Movie?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 900

        tableView.delegate = self
        tableView.dataSource = self
    }

}

//MARK: - TableView - Delegate

extension MovieDetailViewController: UITableViewDelegate {
    
}

//MARK: - TableView - DataSource

extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movie == nil ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let unwrappedMovie = movie else { fatalError("No movie was received to diplay") }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: moviePresentationCellID, for: indexPath) as! MoviePresentationCell
            
            cell.imageCover.image = unwrappedMovie.imageCover
            cell.titleLabel.text = unwrappedMovie.title
            cell.infoLabel.text = unwrappedMovie.title
            cell.ratingLabel.text = String(unwrappedMovie.rating)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: movieOverviewCellID, for: indexPath) as! MovieOverviewCell
            
            cell.titleLabel.text = "Overview"
            cell.descriptionLabel.text = unwrappedMovie.overview
            
            return cell
        }
    }
}
