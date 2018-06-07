/*
 //
 ////
 ////////
 ////////////
 ////////////////
 //////// Copyright
 //// Jason Crouse
 / 2 /\ 0 /\ 1 /\ 8 /
 / 0 /
 / 1 /
 / 8 /
 */



import UIKit
import MapKit
import CoreLocation
import ARKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var winnings : [String] = []
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var targets = [ARItem]()
    var previousDegrees : Double = -75 // set heading for WNW
	var didSetUserLocation = false
    
    @IBOutlet weak var winningsLabel: UILabel!
    
    let belcher : CLLocation = CLLocation(latitude: 37.768360, longitude: -122.430378)
    
    func setupLocations() {
        // IMPORTANT: Item descriptions must be unique
		let firstTarget : ARItem?
		if let userLocation = self.userLocation {
			firstTarget = ARItem(itemDescription: "\(winnings.count)", location: userLocation, itemNode: nil)
				targets.append(firstTarget!)
		}
        
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
		if didSetUserLocation == false {
			setupLocations()
			didSetUserLocation = true
			print(userLocation, "= userLocation")
		}
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
            view.pinTintColor = UIColor.lightGray
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
            // let alert = UIAlertController(title: "Nice Try!", message: "You already collected this one. Get off your ass and collect a new one.", preferredStyle: UIAlertControllerStyle.alert)
            
            // alert.addAction(UIAlertAction(title: "I'm sorry, won't happen again", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in }))
            // self.present(alert, animated: true)
            
            // deselect this pin and return
            self.mapView.deselectAnnotation(view.annotation, animated: true)
            return
        }
        
        
        // Here you get the coordinate of the selected annotation.
        let coordinate = view.annotation!.coordinate
        
        // Make sure the optional userLocation is populated.
        if let userCoordinate = userLocation {
            
            // Make sure the tapped item is within range of the users location.
            if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= 45 {
                // Add to array of winnings
                
                if let title = view.annotation!.title! {
                    // If we wanted to do an AR Screen... we'd do it here
                    // For now... just let the homies get their prize... FOR FREE!
                    
                    winnings.append(title)
                    winningsLabel.text = String(winnings.count)
                    
                    // Display alert
                    //let alert = UIAlertController(title: "Congrats!", message: "You're RICH! You've won \(title)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    //alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in }))
                    // self.present(alert, animated: true)
                    
                    // Add vibration so John's ladies can truly enjoy BitcoinGO ;)
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                    
                    // create next object
                    
                    // Do some math to come up with next point, based on current point and previous path
                    let currentLat = coordinate.latitude
                    let currentLong = coordinate.longitude
                    let multiplier = 0.00135 // this is approximately 150 meters
                    let randDegrees = Double(arc4random_uniform(180)) - 90
                    let nextCoordinateLat = currentLat + multiplier*__cospi((randDegrees + previousDegrees)/180)
                    let nextCoordinateLong = currentLong + multiplier*__sinpi((randDegrees + previousDegrees)/180)
                    
                    // Put the pieces together to do the appropriate adding/removing of pins on the map, and CHANGE COLOR
                    let newTarget = ARItem(itemDescription: "new", location: CLLocation(latitude: nextCoordinateLat, longitude: nextCoordinateLong), itemNode: nil)
                    let newAnnotation = MapAnnotation(location: newTarget.location.coordinate, item: newTarget)
                    self.mapView.addAnnotation(newAnnotation)
                    
                    // Some math to ensure proper bearing for next time
                    previousDegrees = randDegrees + previousDegrees
        
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
                
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in }))
                self.present(alert, animated: true)
                
            }
            self.mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
    
}
