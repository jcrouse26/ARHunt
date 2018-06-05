/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation
import ARKit

class MapViewController: UIViewController {
  
  var winnings : [String] = []
  
  let locationManager = CLLocationManager()
  
  var userLocation: CLLocation?
  
  var targets = [ARItem]()

  func setupLocations() {
    
    // IMPORTANT: Item descriptions must be unique
    
    let firstTarget = ARItem(itemDescription: "1.12 BTC", location: CLLocation(latitude:
      37.768436, longitude: -122.430411), itemNode: nil)
    targets.append(firstTarget)
    
    let secondTarget = ARItem(itemDescription: "0.71 BTC", location: CLLocation(latitude:
      37.765288, longitude: -122.439970), itemNode: nil)
    targets.append(secondTarget)
    
    let thirdTarget = ARItem(itemDescription: "1.66 BTC", location: CLLocation(latitude:
      37.765288, longitude: -122.429970), itemNode: nil)
    targets.append(thirdTarget)
    
    let fourthTarget = ARItem(itemDescription: "0.44 BTC", location: CLLocation(latitude:
      37.769434, longitude: -122.431986), itemNode: nil)
    targets.append(fourthTarget)
    
    let fifthTarget = ARItem(itemDescription: "2.39 BTC", location: CLLocation(latitude:
      37.770621, longitude: -122.434271), itemNode: nil)
    targets.append(fifthTarget)
    
    let sixthTarget = ARItem(itemDescription: "0.46 BTC", location: CLLocation(latitude:
      37.768136, longitude: -122.441706), itemNode: nil)
    targets.append(sixthTarget)
    
    let seventhTarget = ARItem(itemDescription: "0.30 BTC", location: CLLocation(latitude:
      37.765388, longitude: 122.443530), itemNode: nil)
    targets.append(seventhTarget)
    
    let eighthTarget = ARItem(itemDescription: "0.52 BTC", location: CLLocation(latitude:
      37.768365, longitude: -122.432426), itemNode: nil)
    targets.append(eighthTarget)
    
    let ninthTarget = ARItem(itemDescription: "1.88 BTC", location: CLLocation(latitude:
      37.770629, longitude: -122.430956), itemNode: nil)
    targets.append(ninthTarget)
    
    
    let tenthTarget = ARItem(itemDescription: "3.87 BTC", location: CLLocation(latitude:
      37.768934, longitude: -122.427030), itemNode: nil)
    targets.append(tenthTarget)
    
    // In this loop you iterate through all items inside the targets array and add an annotation for each target.
    for item in targets {
      let annotation = MapAnnotation(location: item.location.coordinate, item: item)
      if !winnings.contains(annotation.item.itemDescription) {
        self.mapView.addAnnotation(annotation)
      }
      
    }
  }
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
    setupLocations()
    
    
    if CLLocationManager.authorizationStatus() == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    // do something, maybe update locationManager
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.destination is ProfileViewController {
        let vc = segue.destination as? ProfileViewController
        vc?.winnings = winnings
        vc?.userLocation = userLocation
        
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    self.userLocation = userLocation.location
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
  
    // Return if user has selected "My Location" instead of a pin
    if view.annotation?.title! == "My Location" { return }
    
    // Here you get the coordinate of the selected annotation.
    let coordinate = view.annotation!.coordinate
    
    // Make sure the optional userLocation is populated.
    if let userCoordinate = userLocation {
    
      // Make sure the tapped item is within range of the users location.
      if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= 40 {
        
        // Add to array of winnings
        
        if let title = view.annotation!.title! {
          winnings.append(title)
        
          let alert = UIAlertController(title: "Congrats!", message: "You're RICH! You've won \(title)", preferredStyle: UIAlertControllerStyle.alert)
        
          alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
            print(alert)
          }))
          self.present(alert, animated: true)
        
          // Remove object from map
          self.mapView.removeAnnotation(view.annotation!)
          /*
           // Instantiate an instance of ARViewController from the storyboard.
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
           if let viewController = storyboard.instantiateViewController(withIdentifier: "ARViewController") as? ViewController {
           // more code later
            // This line checks if the tapped annotation is a MapAnnotation.
           if let mapAnnotation = view.annotation as? MapAnnotation {
              // Finally, you present viewController.
              self.present(viewController, animated: true, completion: nil)
           }
           }*/
        }
      } else if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) > 40 {
        let distance = Int(userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)))
        let alert = UIAlertController(title: "Sorry", message: "You are \(distance) meters away. That's too far to get rich. Don't be lazy!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
          print(alert)
        }))
        self.present(alert, animated: true)
        
      }
    }
  }
  
}
