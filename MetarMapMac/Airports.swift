//
//  Airports.swift
//  Garmitrk
//
//  Created by George Bauer on 4/30/18.
//  Copyright © 2018-2021 GeorgeBauer. All rights reserved.
//

import Foundation
import CoreLocation

public struct Airports {
    let cMeterToFeet = 3.28084
    let cMetersToNM  = 0.000539957
    var fileURL     = URL(fileURLWithPath: "Missing URL")
    var fileDate    = Date.distantPast
    var all         = [Airport]()
    var dictByID    = [String: Airport]()
    var nSmall      = 0
    var nMedium     = 0
    var nLarge      = 0
    var nSeaplane   = 0
    var nInCountry  = [String: Int]()
    var nInState    = [String: Int]()
    var nSPBinState = [String: Int]()
    var errStr      = ""
    var lineErrs    = [String]()
    var fileName: String { fileURL.lastPathComponent }
    var count: Int { dictByID.count }

    //------ Airports.init - Read MyAirports.txt into Airports.all[]
    init(url: URL) {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: url.path) {
            print("⛔️ Airport#\(#line) \(url.path) does not exist.")
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
        
        for line in sourceLines {
            if line.isEmpty { continue }
            let items = line.components(separatedBy: ",")
            if items.count < 8 {
                lineErrs.append("<8 items in line #\(lineErrs.count) \(line)")
                errStr = "\(lineErrs.count) line errors"
                continue
            }
            var airport = Airport()
            //0(ident),1(type),2(name),3(lat),4(lon),5(elev),6(state/region),7(city),8(schedServ)"
            airport.ID      =        items[0]
            airport.apType  =        items[1]
            airport.name    =        items[2]
            airport.lat     = Double(items[3]) ?? -999
            airport.lon     = Double(items[4]) ?? -999
            airport.country = String(items[6].prefix(2))
            airport.state   = String(items[6].suffix(2))
            airport.city    =        items[7]
            switch airport.apType {
            case "S": nSmall  += 1
            case "M": nMedium += 1
            case "L": nLarge  += 1
            case "W": nSeaplane += 1
            default: break
            }//end switch
            nInCountry[airport.country, default: 0] += 1
            nInState[airport.state, default: 0] += 1
            if airport.apType == "W" {
                nSPBinState[airport.state, default: 0] += 1
            }
            if airport.lat > -998 && airport.lon > -998 {
                all.append(airport)
                if airport.ID.count == 4 && airport.ID.hasPrefix("K") {
                    let minusK = String(airport.ID.dropFirst())
                    //print("🤪 Airport#\(#line) \(airport.ID) has 'K', \(minusK).")
                    dictByID[minusK] = airport
                }

                dictByID[airport.ID] = airport
            } else {
                lineErrs.append("LatLon in line #\(lineErrs.count) \(line)")
                errStr = "\(lineErrs.count) line errors"
            }
        }
        return
    }//end init
    
    //MARK: - Methods
    
    //------ getNearestAirport - Get Nearest Airport from airports()
    public func getNearestAirport(atLat: Double, atLon: Double, maxNM: Double, dist: inout Double) -> Airport {
        var airportNearest = Airport()
        let maxLatDif = maxNM/60
        let maxLonDif = maxNM/40
        var closestSofar  = maxNM

        for airport in all {
            if abs(atLat-airport.lat) > maxLatDif || abs(atLon - airport.lon) > maxLonDif {
                continue
            }
            //let dist = GreatCircDist(atLat, atLon, airport.lat, airport.lon)
            let locAP = CLLocation(latitude: airport.lat, longitude: airport.lon)
            let locMe = CLLocation(latitude: atLat,   longitude: atLon)
            let dist  = locAP.distance(from: locMe) * cMetersToNM

            if dist < closestSofar {
                closestSofar = dist
                airportNearest = airport
            }
        }//next airport

        return airportNearest
    }//end func GetNearestAirport
    
    //------ getNearestAirport3 - Get Nearest Airport from airports()
    public func getNearestAirport3(atLat: Double, atLon: Double, maxNM: Double) -> (large: Airport?, Small: Airport?) {
        var airportNearestL: Airport?
        var airportNearestS: Airport?
        let maxLatDif = maxNM/60
        let maxLonDif = maxNM/40
        var closestSofarL  = maxNM
        var closestSofarS  = maxNM

        for airport in all {
            if abs(atLat-airport.lat) > maxLatDif || abs(atLon - airport.lon) > maxLonDif {
                //print("😇 Airport#\(#line) \(airport)")
                continue
            }
            let locAP = CLLocation(latitude: airport.lat, longitude: airport.lon)
            let locMe = CLLocation(latitude: atLat,   longitude: atLon)
            
            let dist  = locAP.distance(from: locMe) * cMetersToNM
            var size = airport.apType
            let id = airport.ID
            let noDigitsInID = strHasNoDigits(str: id)
            if size == "S" && noDigitsInID && id.count>3 {
                size = "M"
            }

            switch size {
            case "L", "M":
                if dist < closestSofarL {
                    closestSofarL = dist
                    airportNearestL = airport
                }
            case "S":
                if airport.ID.hasPrefix("US-") {
                    print("⛔️ Airport#\(#line) \(airport) dist=\(dist.formatDbl(".1"))")
                    continue
                }
                if dist < closestSofarS {
                    closestSofarS = dist
                    airportNearestS = airport
                }
            case "W":
                break
            default:
                print("⛔️ Airport#\(#line) \(airport)")
            }
        }
        airportNearestL?.dist = closestSofarL
        airportNearestS?.dist = closestSofarS
        return (airportNearestL, airportNearestS)
    }//end func GetNearestAirport

    //------ getNearbyAirports - Get all Airports within a radius of maxNM
    public func getNearbyAirports(atLat: Double, atLon: Double, maxNM: Double) -> [(airport: Airport, dist: Double)] {
        var airportsNearby = [Airport]()
        var tuples = [(airport: Airport, dist: Double)]()
        for airport in all {
            //let dist = GreatCircDist(atLat, atLon, airport.lat, airport.lon)
            let locAP = CLLocation(latitude: airport.lat, longitude: airport.lon)
            let locMe = CLLocation(latitude: atLat,   longitude: atLon)
            let dist  = locAP.distance(from: locMe) * cMetersToNM
            if dist <= maxNM {
                airportsNearby.append(airport)
                tuples.append((airport, dist))
            }
        }
        tuples.sort(by: { $0.dist < $1.dist })
        return tuples
    }//end func getNearbyAirports

}//end struct Airports


