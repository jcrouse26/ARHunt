// Jason Crouse copyright (c) 2018
//
///
////
/////
////////
////////////
////////////////

import UIKit
import MapKit
import CoreLocation
import ARKit

class MapViewController: UIViewController {
    
    var winnings : [String] = []
    @IBOutlet weak var mapView: MKMapView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        setupLocations()
        
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MapAnnotation else { return nil }
        if annotation.captured == false { return nil }
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.pinTintColor = UIColor.darkGray
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Return and deselect if user has selected "My Location" instead of a pin
        if view.annotation?.title! == "My Location" {
            self.mapView.deselectAnnotation(view.annotation, animated: true)
            return
        }
        if view.reuseIdentifier! == "pin" {
            // create an alert saying you've already won
            let alert = UIAlertController(title: "Nice Try!", message: "You already collected this one. Get off your ass and collect a new one.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "I'm sorry, won't happen again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                //print(alert)
            }))
            self.present(alert, animated: true)
            
            // deselect this pin and return
            self.mapView.deselectAnnotation(view.annotation, animated: true)
            return
        }
        
        
        // Here you get the coordinate of the selected annotation.
        let coordinate = view.annotation!.coordinate
        
        // Make sure the optional userLocation is populated.
        if let userCoordinate = userLocation {
            
            // Make sure the tapped item is within range of the users location.
            if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= 400 {
                
                // Add to array of winnings ... Aka GET RICH!!!
                
                if let title = view.annotation!.title! {
                    winnings.append(title)
                    
                    let alert = UIAlertController(title: "Congrats!", message: "You're RICH! You've won \(title)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                        print(alert)
                    }))
                    self.present(alert, animated: true)
                    
                    // Add vibration so John's ladies can truly enjoy BitcoinGO
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    
                    // Attempt to create it as a MapAnnotation (custom class)
                    guard let annotation = view.annotation as? MapAnnotation else { return }
                    annotation.captured = true
                    
                    // Remove and add new annotation to map
                    self.mapView.removeAnnotation(view.annotation!)
                    self.mapView.addAnnotation(annotation)
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
