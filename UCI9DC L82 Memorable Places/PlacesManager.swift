//
//  PlacesManager.swift
//  UCI9DC L82 Memorable Places
//
//  Created by Stanislav Sidelnikov on 11/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import Foundation

final class Place: NSObject {
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }

    var name: String
    var latitude: Double
    var longitude: Double

    required init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDoubleForKey("latitude")
        self.longitude = aDecoder.decodeDoubleForKey("longitude")
        self.name = aDecoder.decodeObjectForKey("name") as! String
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(latitude, forKey: "latitude")
        aCoder.encodeDouble(longitude, forKey: "longitude")
        aCoder.encodeObject(name, forKey: "name")
    }
}

class PlacesManager {
    static var sharedInstance = PlacesManager()

    internal private(set) var places:[Place] {
        didSet {
            let placesData = NSKeyedArchiver.archivedDataWithRootObject(places)
            NSUserDefaults.standardUserDefaults().setObject(placesData, forKey: KEY)
        }
    }

    private let KEY = "places"

    init() {
        let placesData = NSUserDefaults.standardUserDefaults().objectForKey(KEY) as? NSData
        if let placesData = placesData, placesArray = NSKeyedUnarchiver.unarchiveObjectWithData(placesData) as? [Place] {
            places = placesArray
        } else {
            places = [Place]()
        }
    }

    func count() -> Int {
        return places.count
    }

    subscript(index: Int) -> Place? {
        return places[index]
    }

    func append(place: Place) {
        places.append(place)
    }

    func removeAtIndex(index: Int) -> Bool {
        if self[index] != nil {
            places.removeAtIndex(index)
            return true
        } else {
            return false
        }
    }

}
