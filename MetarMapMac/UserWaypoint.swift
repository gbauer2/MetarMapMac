//
//  UserWaypoint.swift
//  Garmitrk
//
//  Created by George Bauer on 7/29/18.
//  Copyright © 2018-2021 GeorgeBauer. All rights reserved.
//

import Foundation
import MapKit

//MARK: - class UserWaypoints
public class UserWaypoints {
    var fileURL             = URL(fileURLWithPath: "Missing URL")   // fileURL
    var waypointAnnotations = [WaypointAnnotation]()                // Array of waypts
    var dict                = [String: Int]()                       // dictionary by name
    var errorCount          = 0
    var errMsgs             = [String]()
    var fileName: String { fileURL.lastPathComponent }
    var count: Int { waypointAnnotations.count }
    
    init() {}
    
    //Read in User Waypoints form the file "userWaypoints.txt"
    init(fileURL: URL?) throws {            //25-142 = 117 lines
        waypointAnnotations = [WaypointAnnotation]()
        guard let fileURL = fileURL else {
            let msg = "Bad userWaypoints.txt URL"
            print("⛔️ UserWaypoint#\(#line) \(msg)")
            throw msg
        }
        self.fileURL = fileURL
        var lineNo = 0
        var usrLatDegStr: String
        var usrLatMinStr: String
        var usrLonDegStr: String
        var usrLonMinStr: String

        //-------------------------- Read Garmintrack\userWaypoints.txt File ------------------------
        
        let lines = FileHandler.readFileLines(url: fileURL)
        if lines.count < 3 {
            let msg = "Empty file:\n\(fileURL.path)"
            print("⛔️ UserWaypoint#\(#line) \(msg)")
            throw msg
        }
        usrLatDegStr = ""
        usrLonDegStr = ""
        var idx = 0
        for line in lines {
            lineNo += 1
            if line.isEmpty { continue }       // Ignore Blank Lines
            
            //    0      1        2        3        4       5       6       7      8
            // aName, UsrLatD, UsrLatM, UsrLonD, UsrLonM, wpType, state, radius, desc
            //    0      1        2        3        4       5     6
            // aName, UsrLatD, UsrLonD,  wpType, state, radius, desc
            let aSplit = line.components(separatedBy: ",")
            let aName = Gb.removeQuotes(aSplit[0])
            var posType = 5                 // LatD,LatM,LonD,LonM
            if aSplit.count < 9 {
                if aName == "XXX" { break }           // exit
                if aSplit.count != 7 || !aSplit[1].contains(".") {
                    errorCount += 1
                    errMsgs.append("⛔️ UserWaypoint#\(#line) in \(fileURL.lastPathComponent), line \(lineNo)\nLess than 9 items in: \(line)\n")
                    continue
                }
                posType = 3                 // LatDec, LonDec
            }

            usrLatDegStr = aSplit[1].trim
            if posType == 5 {
                usrLatMinStr = aSplit[2].trim
                usrLonDegStr = aSplit[3].trim
                usrLonMinStr = aSplit[4].trim
            } else {
                usrLatMinStr = "0"
                usrLonDegStr = aSplit[2].trim
                usrLonMinStr = "0"
            }
            let wpType = Gb.removeQuotes(aSplit[posType])
            let state  = Gb.removeQuotes(aSplit[posType+1])
            let radius = Double(aSplit[posType+2]) ?? 0
            let desc   = Gb.removeQuotes(aSplit[posType+3])
            
            let errCheck = checkUserWPforErrors(wpType, state, usrLatDegStr, usrLatMinStr, usrLonDegStr, usrLonMinStr)
            
            if errCheck.isEmpty {
                let usrLat = Gb.dbl(str: usrLatDegStr) + Gb.dbl(str: usrLatMinStr) / 60.0
                var usrLon = Gb.dbl(str: usrLonDegStr) + Gb.dbl(str: usrLonMinStr) / 60.0
                if usrLon > 0 { usrLon = -usrLon }              //Assume UserWaypoint is in Western Hemisphere
                var imageSmall:  NSImage
                var imageMedium: NSImage
                var imageLarge:  NSImage
                
                //let subtitle = waypoint.desc
                //var info = "\(waypoint.wpType)\n"
                //info += waypoint.state + "\n\(formatLatLon(lat: waypoint.Lat, lon: waypoint.Lon, places: 3))"
                // "A"irport, "B"uilding, "H"ome, "L"ake, "R"estaurant
                switch wpType {
                case "A":       // Airport
                    imageSmall  = NSImage(imageLiteralResourceName: "ap12")
                    imageMedium = NSImage(imageLiteralResourceName: "ap24")
                    imageLarge  = NSImage(imageLiteralResourceName: "ap32")
                case "H":       // Home
                    imageSmall  = NSImage(imageLiteralResourceName: "004-home-16")
                    imageMedium = NSImage(imageLiteralResourceName: "004-home-24")
                    imageLarge  = NSImage(imageLiteralResourceName: "004-home-32")
                case "L":       // Lake
                    imageSmall  = NSImage(imageLiteralResourceName: "water-12")
                    imageMedium = NSImage(imageLiteralResourceName: "water-24")
                    imageLarge  = NSImage(imageLiteralResourceName: "water-32")
                case "R":       // Restaurant
                    imageSmall  = NSImage(imageLiteralResourceName: "003-food-16")
                    imageMedium = NSImage(imageLiteralResourceName: "003-food-24")
                    imageLarge  = NSImage(imageLiteralResourceName: "003-food-32")
                default:        // "B"uilding
                    imageSmall  = NSImage(imageLiteralResourceName: "004-home-16")
                    imageMedium = NSImage(imageLiteralResourceName: "004-home-24")
                    imageLarge  = NSImage(imageLiteralResourceName: "004-home-32")
                }//end switch
                
                let coord = CLLocationCoordinate2D(latitude: usrLat, longitude: usrLon)
                let userWpAnn = WaypointAnnotation(title: aName, subtitle: desc, coordinate: coord,
                            wpType: wpType, elev: 0, radiusNM: radius, state: state,
                            imageSmall: imageSmall, imageMedium: imageMedium, imageLarge: imageLarge)
//                if aName.hasPrefix("Rag") {
//                    print(aName)
//                }
                dict[aName.uppercased()] = idx
                waypointAnnotations.append(userWpAnn)
                idx += 1
            } else {
                errorCount += 1
                errMsgs.append("⛔️ UserWaypoint#\(#line) in \(fileURL.lastPathComponent), line \(lineNo)  \"\(errCheck)\" in:\n     [\(line)]\n")
            }//endif errCheck.isEmpty
            
        }//next line
        return
    }//end init
   
    
    //---- checkUserWPforErrors - returns "" for OK, or Error Name
    private func checkUserWPforErrors(_ wpType: String, _ state: String , _ latD: String, _ latM: String, _ lonD: String, _ lonM: String) -> String {
        // "YukonR"  ,65,21.2  ,143,07   ,"L","AK",2,"Yukon River"
        
        guard let lat = Double(latD) else { return "Lat=\(latD)"}
        if lat > 80.0 || lat <= 0.0 {
            return "Lat=\(lat)"
        }
        
        guard let minutesLat = Double(latM) else { return "LatMin=\(latM)"}
        if minutesLat < 0.0 || minutesLat >= 60.0 {
            return "LatMin = \(minutesLat)"
        }
        
        guard let lon = Double(lonD) else { return "Lon=\(lonD)"}
        if lon > 180.0 || lon < 0.0 {
            return "Lon = \(lon)"
        }
        
        guard let minutesLon = Double(lonM) else { return "LonMin=\(lonM)"}
        if minutesLon < 0.0 || minutesLon >= 60.0 {
            return "LonMin = \(minutesLon)"
        }
        
        if !"ABHLR".contains(wpType) {   // Airport, Building, Home, Lake, Restaurant
            return "Type=\(wpType)"
        }
        
        if state.count != 2 {
            return "State=\(state)"
        }
        return ""
    }//end func checkUserWPforErrors
    
}//end class UserWaypoints


//MARK: - class WaypointAnnotation
public class WaypointAnnotation: NSObject, MKAnnotation {
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
    
}//end class WaypointAnnotation

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
