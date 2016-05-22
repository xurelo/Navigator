//
//  ViewController.swift
//  Navigator
//
//  Created by Francisco Manuel Romero on 22/05/16.
//  Copyright © 2016 Francisco Manuel Romero. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    private let navHandler = CLLocationManager();
    private var firstPoint : CLLocation? = nil;
    private var prevPoint : CLLocation? = nil;
    @IBOutlet weak var mapa: MKMapView!
    
    
    @IBAction func maptypeChanged(sender: AnyObject) {
        let uc: UISegmentedControl = sender as! UISegmentedControl;
        switch uc.selectedSegmentIndex {
        case 0:
            print("0 selected: Normal");
            mapa.mapType = .Standard;
        case 1:
            print("1 selected: Satellite");
            mapa.mapType = .Satellite;
        case 2:
            print("2 selected: Hybrid");
            mapa.mapType = .Hybrid;
        default:
            print("unknown selected");
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navHandler.delegate = self;
        navHandler.desiredAccuracy = kCLLocationAccuracyBest;
        navHandler.requestWhenInUseAuthorization();
        mapa.mapType = .Standard;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedWhenInUse) {
            navHandler.startUpdatingLocation();
            navHandler.startUpdatingHeading();
            mapa.showsUserLocation = true;
            mapa.showsCompass = true;
            mapa.zoomEnabled = true;
        } else {
            navHandler.stopUpdatingLocation();
            navHandler.stopUpdatingHeading();
            mapa.showsUserLocation = false;
            mapa.showsCompass = false;
            mapa.zoomEnabled = false;
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location latitude:\(manager.location!.coordinate.latitude)");
        print("location longitude:\(manager.location!.coordinate.longitude)");
        print("horizontal accuracy:\(manager.location!.horizontalAccuracy)");
        
        if (firstPoint == nil) {
            firstPoint = manager.location!;
            let span = MKCoordinateSpanMake(0.005, 0.005)
            var mycenter = CLLocationCoordinate2D();
            mycenter.latitude = firstPoint!.coordinate.latitude;
            mycenter.longitude = firstPoint!.coordinate.longitude;
            let region = MKCoordinateRegion(center: mycenter, span: span);
            mapa.setRegion(region, animated: true);
        }
        
        if (prevPoint != nil) {
            let distance : CLLocationDistance = manager.location!.distanceFromLocation(prevPoint!);
            print("distance:\(distance)");
            if (distance > 50) {
                let pin = MKPointAnnotation();
                pin.title = "\(manager.location!.coordinate.longitude),\(manager.location!.coordinate.latitude)";
                let total : CLLocationDistance = manager.location!.distanceFromLocation(firstPoint!);
                pin.subtitle = "\(total) m.";
                pin.coordinate = manager.location!.coordinate;
                prevPoint = manager.location!;
                mapa.addAnnotation(pin);
            }
        } else {
            prevPoint = manager.location!;
        }
        
        var punto = CLLocationCoordinate2D();
        punto.latitude = manager.location!.coordinate.latitude;
        punto.longitude = manager.location!.coordinate.longitude;
        mapa.centerCoordinate = punto;
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "Error", message: "Could not read GPS:\(error.code)", preferredStyle: .Alert);
        let accionOK = UIAlertAction(title: "OK", style: .Default, handler:
        {accion in
            //error
        });
        alerta.addAction(accionOK);
        self.presentViewController(alerta, animated: true, completion: nil);
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("magnetic north:\(newHeading.magneticHeading)");
        print("true north:\(newHeading.trueHeading)");
    }

}

