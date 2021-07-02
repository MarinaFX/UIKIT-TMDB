//
//  MovieListViewController.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit

//MARK: - ViewController

class MovieListViewController: UIViewController {
    
    //MARK: - Class and variables setup
    @IBOutlet weak var tableView: UITableView!
    
    private let cellID: String = "movieCell"
    private let service = TMDBService()
    
    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        service.requestPopularMovies { (popularMovies) in
            self.popularMovies = popularMovies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Segues - To Movie Details
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMovieDetails", let indexPath = sender as? IndexPath {
            
            let destination = segue.destination as! MovieDetailViewController
            
            destination.movie = popularMovies[indexPath.row]
        }
    }
    
}

//MARK: - TableView - Delegate

extension MovieListViewController:  UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMovieDetails", sender: indexPath)
    }
}

//MARK: - TableView - DataSource

extension MovieListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popularMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MovieCell
        
        let movie = popularMovies[indexPath.row]

        cell.coverImage.image = movie.imageCover
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        cell.rating.text = String(movie.rating)

        
        return cell
    }
}
