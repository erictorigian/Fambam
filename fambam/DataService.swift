//
//  DataService.swift
//  fambam
//
//  Created by Eric Torigian on 4/14/16.
//  Copyright © 2016 Eric Torigian. All rights reserved.
//

import Foundation
import Firebase

class DataService {
	static let ds = DataService()
	
	private var _REF_BASE = Firebase(url: "https://fambam.firebaseio.com")

	var REF_BASE: Firebase {
		return _REF_BASE
	}
	
	
	
}