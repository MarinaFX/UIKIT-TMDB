//
//  MovieListViewController.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit

//MARK: - ViewController

class MovieListViewController: UIViewController {
    
    //MARK: - Variables setup
    @IBOutlet weak var tableView: UITableView!
    
    private let cellID: String = "movieCell"
    private let service = TMDBService()
    
    var filteredPopularMovies: [Movie] = []
    var filteredNowPlayingMovies: [Movie] = []
    
    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var searchController = UISearchController(searchResultsController: nil)
    
    //MARK: Class setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        
        service.requestMovies(type: "popular") { (popularMovies) in
            self.popularMovies = popularMovies
            
            self.filteredPopularMovies = popularMovies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        service.requestMovies(type: "now_playing") { (nowPlayingMovies) in
            self.nowPlayingMovies = nowPlayingMovies
            
            self.filteredNowPlayingMovies = nowPlayingMovies
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Segues - To Movie Details
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMovieDetails", let indexPath = sender as? IndexPath {
            let destination = segue.destination as! MovieDetailViewController
            
            if indexPath.section == 0 {
                destination.movie = popularMovies[indexPath.row]
            }
            else {
                destination.movie = nowPlayingMovies[indexPath.row]
            }
        }
    }
    
}

//MARK: - TableView - Delegate

extension MovieListViewController:  UITableViewDelegate {
    //MARK: Row Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMovieDetails", sender: indexPath)
    }
    
    //MARK: Header Setup
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String = ""
        
        if section == 0 {
            title = "Popular Movies"
            
        } else if section == 1 {
            title = "Now Playing"
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 60))
        header.backgroundColor = .clear
        
        let label = UILabel(frame: CGRect(x: 20, y: 16, width: view.frame.size.width, height: 22))
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.text = title
        
        header.addSubview(label)
        
        return header
    }
}

//MARK: - TableView - DataSource

extension MovieListViewController: UITableViewDataSource {
    
    //MARK: Row in section setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPopularMovies.count > 0 && section == 0 {
            return filteredPopularMovies.count > 2 ? 2 : filteredPopularMovies.count
        }
        if section == 1 {
            return filteredNowPlayingMovies.count
        }
        
        return 0
    }
    
    //MARK: Section count setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //MARK: Cell setup
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MovieCell
        
        let movie = indexPath.section == 0 ? filteredPopularMovies[indexPath.row] : filteredNowPlayingMovies[indexPath.row]

        cell.coverImage.image = movie.imageCover
        cell.titleLabel.text = movie.title
        cell.overviewLabel.text = movie.overview
        cell.rating.text = String(movie.rating)

        return cell
    }
}

//MARK: - SearchControllerDelegate

extension MovieListViewController: UISearchResultsUpdating {
    //MARK: Update view while searching
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        
        if searchText.isEmpty {
            filteredPopularMovies = popularMovies
            filteredNowPlayingMovies = nowPlayingMovies
        }
        else {
            filteredNowPlayingMovies = []
            filteredPopularMovies = []
            for movie in (popularMovies + nowPlayingMovies) {
                if movie.title.lowercased().contains(searchText.lowercased()) {
                    if popularMovies.contains(movie) && !filteredPopularMovies.contains(movie) {
                        filteredPopularMovies.append(movie)
                    }
                    if nowPlayingMovies.contains(movie) && !filteredNowPlayingMovies.contains(movie) {
                        filteredNowPlayingMovies.append(movie)
                    }
                }
            }
        }
        
        tableView.reloadData()
    }
}
