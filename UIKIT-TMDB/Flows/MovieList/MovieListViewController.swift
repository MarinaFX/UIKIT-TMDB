//
//  MovieListViewController.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit
import Combine

//MARK: - ViewController

class MovieListViewController: UIViewController {
    
    //MARK: - Variables setup
    @IBOutlet weak var tableView: UITableView!
    
    private var searchController = UISearchController(searchResultsController: nil)

    private let service: TMDBService = .init()
    private let cellID: String = "movieCell"
    
    private var popularMovies: [Movie] {
        service.popularMoviesPublisher.value
    }
    
    private var nowPlayingMovies: [Movie] {
        service.nowPlayingMoviesPublisher.value
    }
    
    private var filteredPopularMovies: [Movie] = []
    private var filteredNowPlayingMovies: [Movie] = []
        
    private var subscriptions: Set<AnyCancellable> = []
    
    //MARK: Class setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        //MARK: Using Combine
        fetchMovies(with: "Combine")
        
        //MARK: Using completions
        fetchMovies(with: "Completion")
    }
    
    func fetchMovies(with type: String) {
        if type == "Completion" {
            service.requestMovies(type: "popular") { (popularMovies) in
//                self.popularMovies = popularMovies
//
//                self.filteredPopularMovies = popularMovies
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
            
            service.requestMovies(type: "now_playing") { (nowPlayingMovies) in
//                self.nowPlayingMovies = nowPlayingMovies
//
//                self.filteredNowPlayingMovies = nowPlayingMovies
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
            }
        }
        else {
            //creating publisher
            service.popularMoviesPublisher
                .receive(on: DispatchQueue.main)
                .sink { movies in
                    self.tableView.reloadData()
                }
                .store(in: &subscriptions)
            //creating subscription
            service.requestMovies(for: .popular, at: 1)
            
            //creating publisher
            service.nowPlayingMoviesPublisher
                .receive(on: DispatchQueue.main)
                .sink { movies in
                    self.tableView.reloadData()
                }
                .store(in: &subscriptions)
            //creating subscription
            self.service.requestMovies(for: .nowPlaying, at: 1)

        }
    }
    
    //MARK: Segues - To Movie Details
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMovieDetails", let indexPath = sender as? IndexPath {
            let destination = segue.destination as! MovieDetailViewController
            
            let text = searchController.searchBar.text ?? ""

            if text.isEmpty {
                if indexPath.section == 0 {
                    destination.movie = popularMovies[indexPath.row]
                }
                else {
                    destination.movie = nowPlayingMovies[indexPath.row]
                }
            }
            else {
                if indexPath.section == 0 {
                    print(filteredPopularMovies)
                    destination.movie = filteredPopularMovies[indexPath.row]
                }
                else {
                    print(nowPlayingMovies)
                    destination.movie = filteredNowPlayingMovies[indexPath.row]
                }
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
        let text = searchController.searchBar.text ?? ""

        if text.isEmpty {
            if popularMovies.count > 0 && section == 0 {
                return popularMovies.count > 2 ? 2 : popularMovies.count
            }
            if section == 1 {
                return nowPlayingMovies.count
            }
        }
        else {
            if filteredPopularMovies.count > 0 && section == 0 {
                return filteredPopularMovies.count > 2 ? 2 : filteredPopularMovies.count
            }
            if section == 1 {
                return filteredNowPlayingMovies.count
            }
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
        var movie: Movie = Movie(id: 0, title: "", overview: "", rating: 0.0)
        
        let text = searchController.searchBar.text ?? ""
        
        if text.isEmpty {
            movie = indexPath.section == 0 ? popularMovies[indexPath.row] : nowPlayingMovies[indexPath.row]
        }
        else {
            movie = indexPath.section == 0 ? filteredPopularMovies[indexPath.row] : filteredNowPlayingMovies[indexPath.row]
        }

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
