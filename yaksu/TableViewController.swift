
import UIKit
import MapKit
import CoreLocation

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
    
    
    
    @IBAction func foundRoad(_ sender: Any) {
        showMeWhere()
        
    }
    @IBOutlet var findRoadBt: UIBarButtonItem!
    @IBOutlet weak var yaksuInCell: UITableViewCell!
    @IBOutlet weak var yaksuUserCell: UITableViewCell!
    @IBOutlet weak var yaksuAddressCell: UITableViewCell!
    @IBOutlet weak var yaksuNameCell: UITableViewCell!
    @IBOutlet weak var detailMapView: MKMapView!
    
    var dvRecords:[[String:String]] = []
    var annoTitle:String = ""
    var annoCheck:String = ""
    var indexName : [String] = []
    var indexNum : Int = 0
    var annoLat: Double?
    var annoLong: Double?
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print(annoTitle)
        yaksuNameCell.textLabel?.text = "약수터명"
        yaksuNameCell.detailTextLabel?.text = annoTitle
        
        //print(tItems)
        for i in dvRecords{
            let title = (i as AnyObject).value(forKey: "약수터명")
            indexName.append(title as! String)
            
            
            let indexOfA = indexName.index(of: annoTitle)
            if indexOfA != nil {
                indexNum = indexOfA!
            }
            
            
            
        }
        print(indexNum)
        
        
        let content = dvRecords[indexNum]
        print(content)
        let address = (content as AnyObject).value(forKey: "소재지지번주소")
        let userCount = (content as AnyObject).value(forKey: "일평균이용인구수")
        let incongruity = (content as AnyObject).value(forKey: "부적합항목")
        let lat = (content as AnyObject).value(forKey: "위도")
        let long = (content as AnyObject).value(forKey: "경도")
        annoLat = (lat as! NSString).doubleValue
        annoLong = (long as! NSString).doubleValue
        yaksuAddressCell.textLabel?.text = "소재지지번주소"
        yaksuAddressCell.detailTextLabel?.text = address as? String == "" ? "등록된 주소가 없습니다." : address as? String
        yaksuUserCell.textLabel?.text = "일평균이용인구수"
        yaksuUserCell.detailTextLabel?.text = userCount as? String == "" ? "0" : userCount as? String
        yaksuInCell.textLabel?.text = "부적합 항목"
        yaksuInCell.detailTextLabel?.text = incongruity as? String
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        detailMapView.showsUserLocation = true
        
        zoomToRegion()
        
        let anno = MKPointAnnotation()
        anno.coordinate.latitude = annoLat!
        anno.coordinate.longitude = annoLong!
        anno.title = annoTitle
        anno.subtitle = address as? String
        
        detailMapView.addAnnotation(anno)
        detailMapView.selectAnnotation(anno, animated: true)
        
        self.title = "약수터"

    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        var  annotationView = detailMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            
            annotationView?.rightCalloutAccessoryView = btn
            
            annotationView?.image = UIImage(named:"drop.png")
            
            
            if annoCheck == "적합" {
                annotationView?.pinTintColor = UIColor.green
                
            }
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            showMeWhere()
        }
    }

    func showMeWhere() {
        
        
        let latitude:CLLocationDegrees = annoLat!
        let longitude:CLLocationDegrees = annoLong!
        
        let regionDistance:CLLocationDistance = 1000;
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = annoTitle
        mapItem.openInMaps(launchOptions: options)
    }
  
    func zoomToRegion() {
        // 35.162685, 129.064238
        let center = CLLocationCoordinate2DMake(annoLat!, annoLong!)
        let span = MKCoordinateSpanMake(0.4, 0.4)
        let region = MKCoordinateRegionMake(center, span)
        detailMapView.setRegion(region, animated: true)
    }

   

}
