//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Ilya on 04.10.2020.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}


class MapViewController: UIViewController {
    
    var mapviewControllerDelegate: MapViewControllerDelegate?
    
    var place =  Place()
    let annotationID = "annotationID"
    let locationManager = CLLocationManager()
    var incomeSegueID = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var directionsArray: [MKDirections] = []
    var previosLocation: CLLocation?{
        didSet{
          startTrackingUserLocation()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }
    
    
    @IBOutlet weak var goButon: UIButton!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
   
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBAction func doneButtonPressed() {
        mapviewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    @IBAction func centerViewinUserLocation() {
        showUserLocation()
    }
    
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView(){
        goButon.isHidden = true
        
        if incomeSegueID == "showMap" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButon.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections){
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map {$0.cancel()}
        directionsArray.removeAll()
    }
    
    private func setupPlaceMark(){
        guard let location = place.location else {return}
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error  = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            let annotion = MKPointAnnotation()
            annotion.title = self.place.name
            annotion.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            annotion.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            self.mapView.showAnnotations([annotion], animated: true)
            self.mapView.selectAnnotation(annotion, animated: true)
        }
    }
    private func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAU()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                self.showAlert(title: "Location services are disabled", message: "Enable in settings")
            }
            
        }
        
    }
    
    private func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction (title: "ok", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
         
    }
    
    private func showUserLocation(){
        
            if let location = locationManager.location?.coordinate{
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            
        }
    }
    
    private func startTrackingUserLocation(){
        guard let previosLocation = previosLocation else {return}
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previosLocation) > 50 else {return}
        self.previosLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            self.showUserLocation()
        }
        
    }
    
    private func getDirections(){
        guard let location = locationManager.location?.coordinate else{
            showAlert(title: "Error", message: "not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previosLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Dest not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate{(response,error) in
            if let error = error{
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction error")
                return
            }
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%.1f", route.distance/1000)
                let timeInterval = route.expectedTravelTime
                print(distance)
                print(timeInterval)
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D)->MKDirections.Request?{
        guard let destinationCoordinate = placeCoordinate else{return nil}
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        return request
    }
    
    private func getCenterLocation(for mapview: MKMapView) -> CLLocation{
        let latitude = mapview.centerCoordinate.latitude
        let longitude = mapview.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func checkLocationAU(){
        if CLLocationManager.locationServicesEnabled() {
            mapView.showsUserLocation = true
            if incomeSegueID == "getAdress"{
                showUserLocation()
            }
        } else{
            showAlert(title: "ok", message: "ok")
        }
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        
        var annotionView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID) as? MKPinAnnotationView
        if annotionView == nil {
            annotionView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            annotionView?.canShowCallout = true
        }
        if let imageData = place.imageData{
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotionView?.rightCalloutAccessoryView = imageView
            
        }
       
        
        return annotionView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
       
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueID == "showMap" && previosLocation != nil{
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil{
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                }else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                }else{
                    self.addressLabel.text = ""
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate{
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAU()
    }
}
