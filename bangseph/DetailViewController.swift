/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var posts = NSMutableArray()
    var hospitals : [Hospital] = []
    var detailCandy: Candy?
    
    var url : String?
    var url2 : String?
    
    
    func loadInitialData(){
        
            let yadmNm = "\(detailCandy!.name)역"
            let addr = ""
            let lat = Double(detailCandy!.latitude)
            let lon = Double(detailCandy!.longitude)
            let hospital = Hospital(title: yadmNm, locationName: addr, coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: lon!))
            hospitals.append(hospital)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control : UIControl){
        let location = view.annotation as! Hospital
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)->MKAnnotationView?{
        guard let annotation = annotation as? Hospital else { return nil}
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView{
            dequeuedView.annotation = annotation
            view = dequeuedView
        }else{
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url="http://openapi.seoul.go.kr:8088/547a6a426a6c6263343772465a5a4f/xml/SearchSTNTimeTableByIDService/1/300/\(detailCandy!.addr)/1/1/"
        
        let latitude = Double(detailCandy!.latitude)
        print(latitude)
        let logitude = Double(detailCandy!.longitude)
        print(logitude)
        let initialLocation = CLLocation(latitude: latitude!, longitude: logitude!)
        centerMapOnLocation(location: initialLocation)
        mapView.delegate = self
        loadInitialData()
        mapView.addAnnotations(hospitals)
}
    
    
    
    
    let regionRadius: CLLocationDistance = 200
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "timetable" {
            let tabController = segue.destination as? UITabBarController
                
             let UpTimeTableViewController = tabController!.viewControllers?[0] as! UpTimeTabelViewController
             let DownTimeTableViewController = tabController!.viewControllers?[1] as! DownTableViewController
            UpTimeTableViewController.url=url
            
            DownTimeTableViewController.url=url
            
            
        }
    }
}
