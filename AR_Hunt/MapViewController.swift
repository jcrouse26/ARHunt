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
	
	@IBOutlet weak var winningsLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	var winnings : [String] = []
	let locationManager = CLLocationManager()
	var userLocation: CLLocation?
	var targets = [ARItem]()
	var previousDegrees : Double = 0 // Initial heading (0º == Due North)
	var currentLat = 37.768436 // 68 Belcher
	var currentLong = -122.430411 // 68 Belcher
	
    let belcher : CLLocation = CLLocation(latitude: 37.768360, longitude: -122.430378)
    
	func setupCourse() {
		var i = 0
		while i < 20 {
			let multiplier = 0.00135
			let randDegrees = Double(arc4random_uniform(180)) - 90
			let nextCoordinateLat = currentLat + multiplier*__cospi((randDegrees + previousDegrees)/180)
			let nextCoordinateLong = currentLong + multiplier*__sinpi((randDegrees + previousDegrees)/180)
			let newTarget = ARItem(itemDescription: String(i + 1), location: CLLocation(latitude: nextCoordinateLat, longitude: nextCoordinateLong), itemNode: nil)
			let newAnnotation = MapAnnotation(location: newTarget.location.coordinate, item: newTarget)
			targets.append(newTarget)
			self.mapView.addAnnotation(newAnnotation)
			previousDegrees = randDegrees + previousDegrees
			currentLat = nextCoordinateLat
			currentLong = nextCoordinateLong
			i += 1
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
		setupCourse()
		
		
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
            if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= 45 {
                // Add to array of winnings
                
                if let title = view.annotation!.title! {
                    // If we wanted to do an AR Screen... we'd do it here
                    // For now... just let the homies get their prize... FOR FREE!
                    
                    winnings.append(title)
                    winningsLabel.text = String(winnings.count)
                    
                    // Display alert
                    let alert = UIAlertController(title: "Congrats!", message: "You're RICH! You've won \(title)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
                        print(alert)
                    }))
                    self.present(alert, animated: true)
                    
                    // Add vibration so John's ladies can truly enjoy BitcoinGO ;)
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
                
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in }))
                self.present(alert, animated: true)
                self.mapView.deselectAnnotation(view.annotation, animated: true)
                
            }
            self.mapView.deselectAnnotation(view.annotation, animated: true)
        }
    }
    
}
