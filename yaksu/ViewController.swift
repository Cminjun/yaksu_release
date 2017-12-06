//
//  ViewController.swift
//  yaksu
//
//  Created by D7703_14 on 2017. 11. 28..
//  Copyright © 2017년 Personal Team. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController,MKMapViewDelegate, XMLParserDelegate,CLLocationManagerDelegate {
    
    //사용자 위치정보 
    
    var locationManager:CLLocationManager!
    //
    
    let apiKey = "Jzw%2BUKesxva7uySAWrOded4uRBmzgDHJiriNW4jf9NYmunRiM0sxj8o1p%2FK%2FDClXEwvsGplWFarlemqZCi9Adg%3D%3D"
    let endPoint = "http://api.data.go.kr/openapi/appn-mnrlsp-info-std"
    var parser:XMLParser!
    var record:[String:String] = [:]
    var records:[[String:String]] = []
    var url:URL?
    var myLat = Double()
    var myLong = Double()
    @IBOutlet var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getList()
        var annotations = [MKPointAnnotation]()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    
        
        
        //let path = Bundle.main.path(forResource: "yaksu", ofType: "plist")
        //파일 경로 찾아서 오기
        
        //var contents = NSArray(contentsOfFile: path!) as! [[String : String]]
        
        
        if records.count > 0{
            for item in records{
                let lat = (item as AnyObject).value(forKey: "위도")
                let long = (item as AnyObject).value(forKey: "경도")
                let title = (item as AnyObject).value(forKey: "약수터명")
                let subTitle = (item as AnyObject).value(forKey: "수질검사결과구분")
                
                
                
                let myLat = (lat as! NSString).doubleValue
                let myLong = (long as! NSString).doubleValue
                let myTitle = title as! String
                let mySubTitle = subTitle as! String
                let annotation = MKPointAnnotation()
                
                annotation.coordinate.latitude = myLat
                annotation.coordinate.longitude = myLong
                annotation.title = myTitle
                annotation.subtitle = mySubTitle
                
                annotations.append(annotation)
                
                
            }
        } else {
            
            
        }
        myMapView.showAnnotations(annotations, animated: true)
        myMapView.addAnnotations(annotations)
        zoomToRegion()
    }
    
    /*func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        if let coor = manager.location?.coordinate{
            print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            myLat = coor.latitude
            myLong = coor.longitude
        }
    }*/

    func zoomToRegion(){
        let center = CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        let span = MKCoordinateSpanMake(0.35, 0.44)
        let region = MKCoordinateRegionMake(center, span)
        
        myMapView.setRegion(region, animated: true)
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        var  annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            annotationView?.image = UIImage(named:"drop.png")
            
            if annotation.title! == "사용자 위치" {
                annotationView?.pinTintColor = UIColor.green
                
            }
            if annotation.subtitle! == "적합" {
                annotationView?.pinTintColor = UIColor.green
                
            }
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        
        return annotationView
        
    }
    func getList() { //numOfRows를 입력
        //let str = detailEndPoint + "?serviceKey=\(servieKey)&numsofRows=20"
        let str = endPoint + "?serviceKey=\(apiKey)&s_page=1&s_list=1155&type=xml"
        print(str)
        
        if let url = URL(string: str) {
            if let parser = XMLParser(contentsOf: url) {
                
                parser.delegate = self
                let success = parser.parse()
                if success {
                    print("parse success in getList")
                    print(records)
                    
                } else {
                    print("parse failed in getList")
                }
            }
        }
    }
    var selectedAnnotation: MKPointAnnotation!
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            performSegue(withIdentifier:"segue_detail", sender: view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let detailVC = segue.destination as! TableViewController
            detailVC.annoTitle = selectedAnnotation.title!
            detailVC.annoCheck = selectedAnnotation.subtitle!
            detailVC.dvRecords = records
            
        }
    }
   
    func saveDetail(url:URL) {
        
        // "loc" key로 items를 sort
        let sortedItems = records.sorted{($1["loc"])! > ($0["loc"])!}
        let tempItems = sortedItems  // tableView에서 재활용
        //print("items = \(items)")
        
        records = []
        
        //-----------------thread controll----------------------
        //-------DispatchQueue선언(멀티 thread)-------------------
        //qos 속성에 따라 우선순위 변경
        let equeue = DispatchQueue(label:"com.yangsoo.queue", qos:DispatchQoS.userInitiated)
        //-------xml parxer(background thread사용)---------------
        equeue.async {
//            for dic in tempItems {
//                // 상세 목록 파싱
//                self.getDetail(idx: dic["idx"]!)
//                //-------tableview(main thread사용(ui는 main thread 사용 필수))---
//                DispatchQueue.main.async {
//                    self.myTableView.reloadData()
//                    let temp = self.items as NSArray  // NSArry는 화일로 저장하기 위함
//                    temp.write(to: url, atomically: true)
//                }
//            }
            
        }
        //-----------------thread controll------------------------
    }
    var key = ""
    var entryCheck = false
    var stringCheck = false
    var dataArr = [String]()
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //key = elementName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        key = elementName
        print(key)
        if key == "com.google.gson.internal.LinkedTreeMap" {
            record = [:]
        }
        if key == "entry" {
            entryCheck = true
        }
        if key == "string" {
            stringCheck = true
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        
        var parseV = string.trimmingCharacters(in: .whitespaces)
        if key == "null" && entryCheck {
         dataArr.append("없음")
        }
        if key == "double" {
            dataArr.append(String(string).trimmingCharacters(in: .whitespaces))
        }
        if key == "string" && stringCheck {
            if !parseV.characters.contains("\n") {
                dataArr.append(parseV)
            }
            print(string.trimmingCharacters(in: .whitespaces))
            
        }
       
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "com.google.gson.internal.LinkedTreeMap" {
            records.append(record)
        }
        if elementName == "entry" {
            
            if dataArr[0] == "\n" || dataArr[0] == "null"{
                dataArr.remove(at: 0)
            }
            
            record[dataArr[0]] = dataArr[1]
            dataArr.removeAll()
            entryCheck = false
        }
        if elementName == "string" {
            stringCheck = false
        }
        print("/"+elementName)
    }


}

