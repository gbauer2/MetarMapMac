//
//  Metars.swift
//  MetarMac101
//
//  Created by George Bauer on 2024-07-30.
//

import Foundation
import MapKit

struct Metars {
    let cMeterToFeet = 3.28084
    let cMetersToNM  = 0.000539957

    var fileURL     = URL(fileURLWithPath: "Missing URL")
    var fileDate    = Date.distantPast
    var all         = [Metar]()
    var annotations = [MetarAnnotation]()
    var dictByID    = [String: Metar]()
    var errStr      = ""
    var lineErrs    = [String]()
    var fileName:   String { fileURL.lastPathComponent }
    var count:      Int { all.count }


    init(url: URL) {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: url.path) {
            print("⛔️ Metars#\(#line) \(url.path) does not exist.")
            errStr = "Could not find \(url.path)"
            return
        }
        fileURL = url
//        let fileInfo = FileInfo(url: fileURL)
//        fileDate = fileInfo.modificationDate

        //— reading —    // macOSRoman is more forgiving than utf8
        let contentAsString: String
        do  {
            contentAsString = try String(contentsOf: url, encoding: .macOSRoman)
        } catch {
            errStr = "Could not read \(url.path)"
            return
        }

        //print(contentAsString)
        let sourceLines = contentAsString.components(separatedBy: .newlines)

        for (idx, line) in sourceLines.enumerated() {
            if line.isEmpty { continue }
            if idx < 7      { continue }
            let items = line.components(separatedBy: ",")
            if items.count < 8 {
                lineErrs.append("<8 items in line #\(lineErrs.count) \(line)")
                errStr = "\(lineErrs.count) line errors"
                continue
            }
            let metar = Metar(csvStr: line)
            all.append(metar)
        }

    }//init

}//struct Metars

//MARK: - class MetarAnnotation
public class MetarAnnotation: NSObject, MKAnnotation {
    public var title:      String?
    public var subtitle:   String?
    public var coordinate: CLLocationCoordinate2D
    public var wpType:     String
    public var elev:       Int
    public var radiusNM:   Double
    public var state:      String
    public var imageSmall: NSImage
    public var imageMedium:NSImage
    public var imageLarge: NSImage

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, wpType: String, elev: Int, radiusNM: Double, state: String, imageSmall: NSImage, imageMedium: NSImage, imageLarge: NSImage) {
        self.title      = title
        self.subtitle   = subtitle
        self.coordinate = coordinate
        self.wpType     = wpType
        self.elev       = elev
        self.radiusNM   = radiusNM
        self.state      = state
        self.imageSmall = imageSmall
        self.imageMedium = imageMedium
        self.imageLarge = imageLarge
    }//end init

}//end class MetarAnnotation

//MARK: --- class WaypointPin ---
// -------- Define datatype "WaypointPin", which inherits from MKAnnotation --------
//class WaypointPin: NSObject, MKAnnotation {
//    var title:           String?
//    var subtitle:        String?
//    var coordinate:      CLLocationCoordinate2D
//    var info:            String
//    var pinColor:        NSColor
//    var backgroundColor: NSColor?
//
//    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, info: String, pinColor: NSColor, backgroundColor: NSColor?) {
//        self.title           = title
//        self.subtitle        = subtitle
//        self.coordinate      = coordinate
//        self.info            = info
//        self.pinColor        = pinColor
//        self.backgroundColor = backgroundColor
//    }//end init
//}//end class WaypointPin
