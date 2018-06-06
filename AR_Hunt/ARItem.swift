//
//  ARItem.swift
//  AR_Hunt
//
//  Created by Jason Crouse on 6/1/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import CoreLocation
import SceneKit

struct ARItem {
		let itemDescription : String
		let location : CLLocation
	
		var itemNode: SCNNode?
}
