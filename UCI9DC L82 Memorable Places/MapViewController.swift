//
//  MapViewController.swift
//  UCI9DC L82 Memorable Places
//
//  Created by Stanislav Sidelnikov on 09/03/16.
//  Copyright © 2016 Stanislav Sidelnikov. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func placeAdded(place: Place)
}

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var delegate: MapViewControllerDelegate?
    var places: [Place]?
    var selectedPlace: Place?
    var touchedPlace: Place?
    private var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        setAnnotations()

        if let selectedPlace = selectedPlace {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let coordinate = CLLocationCoordinate2D(latitude: selectedPlace.latitude, longitude: selectedPlace.longitude)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager?.requestWhenInUseAuthorization()
        }
    }

    private func setAnnotations() {
        guard let places = places else {
            return
        }

        for place in places {
            addAnnotationForPlace(place)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationManager?.startUpdatingLocation()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }

    @IBAction func mapLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Ended {
            print("Long press detected")
            let touchPoint = gesture.locationInView(mapView)
            let pointCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

            let location = CLLocation(latitude: pointCoordinates.latitude, longitude: pointCoordinates.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                guard error == nil else {
                    print("Error while reverse geocoding. Error: \(error?.localizedDescription)")
                    return
                }
                if let placemark = placemarks?.first {
                    let pm = CLPlacemark(placemark: placemark)
                    if let latitude = pm.location?.coordinate.latitude, longitude = pm.location?.coordinate.longitude {
                        var name = "\(pm.subThoroughfare ?? "") \(pm.thoroughfare ?? "") \(pm.subLocality ?? "") \(pm.postalCode ?? ""), \(pm.subAdministrativeArea ?? ""), \(pm.country ?? "")"
                        name = name.condenseWhitespace().trim()
                        let newPlace = Place(name: name, latitude: latitude, longitude: longitude)
                        self.delegate?.placeAdded(newPlace)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.addAnnotationForPlace(newPlace)
                        }
//                        self.touchedPlace = newPlace
//                        dispatch_async(dispatch_get_main_queue()) {
//                            print("Performing segue")
//                            self.performSegueWithIdentifier("unwindSavePlace", sender: self)
//                        }
                    }
                } else {
                    print("No placemarks returned")
                }
            })
        }
    }
    
    private func addAnnotationForPlace(place: Place) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        annotation.title = place.name
        mapView.addAnnotation(annotation)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: MKMapViewDelegate {

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager?.stopUpdatingLocation()
            locationManager = nil
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }
}
