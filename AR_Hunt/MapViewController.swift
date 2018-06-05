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
		var previousDegrees : Double = 0
	
		func setupLocations() {
				// IMPORTANT: Item descriptions must be unique
				let firstTarget = ARItem(itemDescription: "1.12 BTC", location: CLLocation(latitude: 37.768436, longitude: -122.430411), itemNode: nil)
				targets.append(firstTarget)
			
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
	
		func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		
				// Return if user has selected "My Location" instead of a pin
				if view.annotation?.title! == "My Location" { return }
			
				// Here you get the coordinate of the selected annotation.
				let coordinate = view.annotation!.coordinate
				if let userCoordinate = userLocation {
						// Make sure the tapped item is within range of the users location.
						if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) <= 1000000 {
								// Add to array of winnings
								if let title = view.annotation!.title! {
										winnings.append(title)
										/*
										// Display alert
										let alert = UIAlertController(title: "Congrats!", message: "You're RICH! You've won \(title)", preferredStyle: UIAlertControllerStyle.alert)
					
										alert.addAction(UIAlertAction(title: "Thanks!", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
										print(alert)
										}))
										//self.present(alert, animated: true)
										*/
										// create next object
									
										print(previousDegrees, " Previous degrees")
									
										let currentLat = coordinate.latitude
										let currentLong = coordinate.longitude
										let multiplier = 0.00135
										let randDegrees = Double(arc4random_uniform(180)) - 90
										let nextCoordinateLat = currentLat + multiplier*__cospi((randDegrees + previousDegrees)/180)
										let nextCoordinateLong = currentLong + multiplier*__sinpi((randDegrees + previousDegrees)/180)
										let newTarget = ARItem(itemDescription: "new", location: CLLocation(latitude: nextCoordinateLat, longitude: nextCoordinateLong), itemNode: nil)
										let newAnnotation = MapAnnotation(location: newTarget.location.coordinate, item: newTarget)
										self.mapView.addAnnotation(newAnnotation)
										self.mapView.removeAnnotation(view.annotation!)
										print(randDegrees)
									
										previousDegrees = randDegrees + previousDegrees
										print(previousDegrees, " previous Degrees")
						
										// transitionToGameScreen()
										}
							} else if userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) > 40 {
										let distance = Int(userCoordinate.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)))
										let alert = UIAlertController(title: "Sorry", message: "You are \(distance) meters away. That's too far to get rich. Don't be lazy!", preferredStyle: UIAlertControllerStyle.alert)
					
										alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction!) in
												print(alert)
										}))
										//self.present(alert, animated: true)
							}
				}
  }
  /*
   // Transitions to AR, QUIZ, OR GAMESCREEN
   func transitionToGameScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "") as? ViewController {
              if let mapAnnotation = view.annotation as? MapAnnotation {
                    self.present(viewController, animated: true, completion: nil)
              }
        }
   }
  
  */
}
