//
//  MapAnnotation.swift
//  AR_Hunt
//
//  Created by Jason Crouse on 6/1/18.
//
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
	
	// The protocol requires a variable coordinate and an optional title.
	let coordinate: CLLocationCoordinate2D
	let title: String?
	var captured = false
	// Here you store the ARItem that belongs to the annotation.
	let item: ARItem
	
	// With the init method you can populate all variables.
	init(location: CLLocationCoordinate2D, item: ARItem) {
		self.coordinate = location
		self.item = item
		self.title = item.itemDescription
		
		super.init()
	}
}

