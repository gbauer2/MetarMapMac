//
//  ViewController.swift
//  MetarMapMac
//
//  Created by George Bauer on 2024-07-31.
//

import Cocoa
import MapKit
import Compression
import WebKit


// Add https://github.com/marmelroy/Zip to your Package.swift dependencies.
// import Zip

var webView: WKWebView!



class ViewController: NSViewController, NSWindowDelegate {
    let codeFile = "ViewController"
    var flightSegIdSel      = -1
    var gIconSize           = IconSize.small
    var gPrevIconSize       = IconSize.small

    var trkLog = TrkLog()

   @IBOutlet weak var lblLocation:     NSTextField!
    @IBOutlet weak var txtFilter:       NSTextField!
    @IBOutlet weak var lblFilterResult: NSTextField!
    @IBOutlet weak var statusBarMap:    NSTextField!
    @IBOutlet weak var statusBar2:      NSTextField!
    @IBOutlet weak var statusBar3:      NSTextField!

    @IBOutlet weak var popupDates:      NSPopUpButton!
    @IBOutlet weak var txtDates:        NSTextField!
    @IBOutlet weak var btnNextDate:     NSButton!
    @IBOutlet weak var btnPrevDate:     NSButton!

    @IBOutlet weak var popupSegs:       NSPopUpButton!
    @IBOutlet weak var txtSegs:         NSTextField!
    @IBOutlet weak var btnNextSeg:      NSButton!
    @IBOutlet weak var btnPrevSeg:      NSButton!
    @IBOutlet weak var btnAnimate:      NSButton!
    @IBOutlet weak var btnClear:        NSButton!

    @IBOutlet weak var popupCopy:       NSPopUpButton!

    @IBOutlet weak var chkAutoZoom:     NSButton!
    @IBOutlet weak var btnPrevTrkPt:    NSButton!
    @IBOutlet weak var btnNextTrkPt:    NSButton!
    @IBOutlet weak var btnZoomExtents:  NSButton!
    @IBOutlet weak var btnsegMapType:   NSSegmentedControl!
    @IBOutlet weak var progressInd1:    NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        let filemngr    = FileManager.default
//        let homeDirURL  = filemngr.homeDirectoryForCurrentUser
        let documentURL = try! filemngr.url(for: .documentDirectory,  in: .userDomainMask, appropriateFor: nil, create: false)
//        let desktopURL  = try? filemngr.url(for: .desktopDirectory,   in: .userDomainMask, appropriateFor: nil, create: false)
        let downloadURL = try! filemngr.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        // Do any additional setup after loading the view.

        let airportURL = documentURL.appendingPathComponent("GarminTrack/AvDataG/myAirports.txt")
        let airports = Airports(url: airportURL)
        if airports.count < 999 || !airports.errStr.isEmpty {
            print("⛔️ \(codeFile)#\(#line) \(airports.errStr)")
        } else {
            print("😀 \(codeFile)#\(#line) \(airports.count) airports read in.")
        }

        let avWxMetarURL = URL(string: "https://aviationweather.gov/data/cache/metars.cache.csv.gz")!
        downloadData(url: avWxMetarURL)

        let metarURL = downloadURL.appendingPathComponent("metars.csv")
        let metars = Metars(url: metarURL)
        if metars.count < 999 || !metars.errStr.isEmpty {
            print("⛔️ \(codeFile)#\(#line) \(metars.errStr)")
        } else {
            print("😀 \(codeFile)#\(#line) \(metars.count) METARs read in.")
        }

        for metar in metars.all {
            if metar.flightCat != "VFR" && metar.flightCat != "MVFR" && metar.flightCat != "IFR" && metar.flightCat != "LIFR" {
                print("🤬 \(metar.ID) \(metar.flightCat) \(metar.rawData)")
            }
        }
    }//viewDidLoad

    func downloadData(url: URL) {
        URLSession.shared.downloadTask(with: url)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    //MARK: - =-=-=-=-=-=-= Graphics for MKMapView mapView =-=-=-=-=-=-=-=

    //MARK: ---- mapView Variables ----
    weak var delegate: MapVCdelegate?          //delegate - Here because not allowed in extension

    // For VC+MKMapView
    let allSegsStr  = "All Segs"
    let allDatesStr = "All Dates"
    let maxMapClickDistPix: CGFloat = 4.0       // pixels

    var mouseIsInMap        = false
    var dateStrFromPopup    = ""
    var flightSegIDfromPopup = ""
    var isDegMin            = false

    var mapReturnType = 0

    // Set by resetExtents()
    var currentZoomScale: MKZoomScale = 0.5
    var mapCenterLat = 42.0
    var mapCenterLon = -80.0
    var mapDeltaLat  = 90.0
    var mapDeltaLon  = 110.0
    var searchType   = 0
    var searchName   = ""

    // Return to Caller delegate
    var latFromMap = 0.0                    // Here because not allowed in extension
    var lonFromMap = 0.0                    // Here because not allowed in extension
    var waypointIDFromMap = ""              // Here because not allowed in extension


    //MARK: --- @IBOutlets for mapView ---
    @IBOutlet var mapView:           MKMapView!
    @IBOutlet weak var btnSaveLoc:   NSButton!
    @IBOutlet weak var lblSelected:  NSTextField!    //NSLabel!
    @IBOutlet weak var lblMapLatLon: NSTextField!
    @IBOutlet weak var lblMap2:      NSTextField!

}//class ViewController

