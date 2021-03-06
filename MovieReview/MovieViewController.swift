//
//  MovieViewController.swift
//  MovieReview
//
//  Created by Sylvia Mach on 1/31/17.
//  Copyright © 2017 Sylvia Mach. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredData: [NSDictionary]!
    
    var movies:[NSDictionary]?
    var endpoint: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        self.tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

        requestNetwork()
        navigationController?.hidesBarsOnSwipe = true
        
        // Do any additional setup after loading the view.
    }
    
    func requestNetwork(){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) {(
            data: Data?,
            response: URLResponse?,
            error: Error?
        ) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    //print(dataDictionary)
                    MBProgressHUD.hide(for: self.view, animated: false)
                    self.movies = dataDictionary["results"] as? [NSDictionary]
                    self.filteredData = self.movies
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }

    
    //Search bar function
    func searchBar(_ searchBar:UISearchBar, textDidChange searchText:String){
        
        //movie is unsafe, because movie can be nil
        // want to protect my process if movie is empty
        // how?
        guard let movies = self.movies else {
            return
        }
        
        filteredData = searchText.isEmpty ? movies : movies.filter({(movie: NSDictionary) -> Bool in
            // If dataItem matches the searchText, return true to include it
            let title = movie["title"] as! String
            return title.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
       
    
    //Show cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    
    func refreshControlAction(_ refreshControl:UIRefreshControl){
        refreshControl.endRefreshing()
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let filteredData = filteredData {
            return filteredData.count
        }else{
            return 0
        }
    }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath ) as! MovieCell
        let movie = filteredData![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
    
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
    
        let baseUrl = "https://image.tmdb.org/t/p/w500"
    
        if let posterPath = movie["poster_path"] as? String{
            let imageUrl = NSURL(string:baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl as! URL)
        }
    
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
    
}
