//
//  ProfileViewController.swift
//  AR_Hunt
//
//  Created by Jason Crouse on 6/4/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var winnings : [String] = []
    var userLocation : CLLocation?

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return winnings.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = winnings[indexPath.row]
        return cell
    }
  
    // MARK: - Navigation
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MapViewController {
            let vc = segue.destination as? MapViewController
          
            // Pass user location back to Map View
            vc?.userLocation = userLocation
            // Pass winnings back to Map View
            vc?.winnings = winnings
      }
  }
  

}
