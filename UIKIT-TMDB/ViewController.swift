//
//  ViewController.swift
//  UIKIT-TMDB
//
//  Created by Marina De Pazzi on 30/06/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let service: TMDBService = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
//    private var movies: [Movie] {
//        service.moviesPublisher.value
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        service.moviesPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { movies in
//                self.tableView.reloadData()
//            }
//            .store(in: &subscriptions)
//
//        service.requestMovies("popular", 0)
    }


}

//extension ViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return UITableViewCell()
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return movies.count
//    }
//}
