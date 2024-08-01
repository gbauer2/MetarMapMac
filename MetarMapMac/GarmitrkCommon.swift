//
//  GarmitrkCommon.swift
//  Garmitrk
//
//  Created by George Bauer on 4/17/18.
//  Copyright © 2018-2021 GeorgeBauer. All rights reserved.
//

import Foundation
import CoreLocation       // for CLLocationCoordinate2D in struct PhaseTaxiOrFly

//MARK: - Globals
public var userWaypoints   = UserWaypoints()       // UserWaypoint annotations
public var myURL           = MyURL()
public let allAirports = Airports(url: myURL.airports)



//MARK: - Structures

// Not Used! (was in ReadGarminLogVC)
public struct LogEntry {
    //date,A/C-Type,ID,From,To,InstApp,Ldgs,(SEL MEL Other X/C Day Nght ActInstr SimInstr DualRcvd PIC SIC Misc TT),Rmk,DepTime,ArrTime,From(Name),To(Name),From(Pos),To(Pos),Distance,MaxSpeed,MaxAlt
    var dayTimeStart    = Date.distantPast
    var dayTimeEnd      = Date.distantPast
    var dayTimeUtcStart = Date.distantPast
    var aircraftType    = ""
    var aircraftID      = ""
    var fromID          = ""
    var toID            = ""
    var fromName        = ""
    var toName          = ""
    var fromLat         = 0.0
    var fromLon         = 0.0
    var toLat           = 0.0
    var toLon           = 0.0
    var instApps        = 0
    var ldgs            = 0
    var rmk             = ""
    var distance        = 0.0
    var distCrow        = 0.0
    var maxSpeed        = 0
    var maxAlt          = 0
    var hrSEL           = 0.0
    var hrMEL           = 0.0
    var hrSES           = 0.0
    var hrMES           = 0.0
    var hrAirline       = 0.0
    var hrPassenger     = 0.0
    var hrXC            = 0.0
    var hrDay           = 0.0
    var hrNight         = 0.0
    var hrInstrAct      = 0.0
    var hrInstrSim      = 0.0
    var hrDualRcvd      = 0.0
    var hrPIC           = 0.0
    var hrSIC           = 0.0
    var hrTT            = 0.0
}//end struct LogEntry
//    var Log       = LogEntry()

// Used only in ViewController
public struct SummaryLine {
    var line          = ""
    var dateTimeStart = Date.distantPast
    var dateTimeEnd   = Date.distantPast
    var addBlankLine  = false
}

// Used only in ViewController
public enum IconSize {
    case small
    case medium
    case large
}

public struct FlightSegIDandDate {
    var ID   = 0
    var date = Date.distantPast
}

// MARK: - Structs for ListTrk

// Used only in ViewController.  Flight contains 1 or more FlightPhases (taxi/fly)
public struct Flight {
    var startDate = Date()
    var endDate   = Date()
    var idxFirst  = -1
    var idxLast   = -1
    var flyTime   = 0.0
    var taxiTime  = 0.0
    var flyDist   = 0.0
    var taxiDist  = 0.0
    var maxAlt    = 0
    var eastMost  = -180.0
    var westMost  = 180.0
    var northMost = -90.0
    var southMost = 90.0
    var phasesTaxiOrFly = [PhaseTaxiOrFly]()
}

// PhaseTaxiOrFly separates out Taxi/Fly as well as flightSegIDs
public struct PhaseTaxiOrFly {     // PhaseTaxiOrFly contains array of LatLon points
    var wasFlying   = false
    var startDate   = Date.distantPast
    var endDate     = Date.distantPast
    var distNM      = 0.0
    var maxAlt      = 0
    var flightSegID = 0
    var idxFirst    = -1
    var idxLast     = -1
    var points      = [CLLocationCoordinate2D]()    // Used directly when plotting TrkLine
}

//MARK: - FILE URLs

public struct MyURL {
    static let doc = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    static let documents = doc ?? URL(fileURLWithPath: "Users/georgebauer/Documents")
    static let staticGarmitrk = documents.appendingPathComponent("GarminTrack")
    var garmitrk        = documents.appendingPathComponent("GarminTrack")
    var testData        = documents.appendingPathComponent("GarminTrack/TestData")

    var logFix          = staticGarmitrk.appendingPathComponent("LogFix.txt")
    var avDataG         = staticGarmitrk.appendingPathComponent("AvDataG")
    var airports        = staticGarmitrk.appendingPathComponent("AvDataG/MyAirports.txt")
    var userWaypoints   = staticGarmitrk.appendingPathComponent("AvDataG/UserWaypoints.txt")
    var userWpAlias     = staticGarmitrk.appendingPathComponent("AvDataG/UserWaypointAlias.txt")

    var trkIndex        = staticGarmitrk.appendingPathComponent("00TrkIndex.txt")
    var trkFileIndx     = staticGarmitrk.appendingPathComponent("00TrkFileIndx.txt")

    var flyLogNew       = staticGarmitrk.appendingPathComponent("FlyLogNew.txt")
    var flyLogErr       = staticGarmitrk.appendingPathComponent("FlyLogErrMac.txt")

    init() {}
    
    init(isUnitTest: Bool) {
        guard let documents = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else  {
            fatalError("Could not find Documents file", file: "GarmitrkCommon", line: #line)
        }
        testData = documents.appendingPathComponent("GarminTrack/TestData")
        let baseURL: URL
        if isUnitTest {
            baseURL = documents.appendingPathComponent("GarminTrack/TestData")
        } else {
            baseURL = documents.appendingPathComponent("GarminTrack")
        }
            //let testData      = documents.appendingPathComponent("GarminTrack/TestData")
            garmitrk      = baseURL
            logFix        = baseURL.appendingPathComponent("LogFix.txt")
            airports      = baseURL.appendingPathComponent("AvDataG/MyAirports.txt")
            userWaypoints = baseURL.appendingPathComponent("AvDataG/UserWaypoints.txt")

            trkIndex      = baseURL.appendingPathComponent("00TrkIndex.txt")
            trkFileIndx   = baseURL.appendingPathComponent("00TrkFileIndx.txt")

            flyLogNew     = baseURL.appendingPathComponent("FlyLogNew.txt")
            flyLogErr     = baseURL.appendingPathComponent("FlyLogErrMac.txt")

    }//end init

}//end struct MyURL

//MARK: - GLOBAL CONSTANTS

public struct Gcc {
    static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    static let appBuild   = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")            as? String ?? "0"

    static let firstTrkYearRecorded = 1995
    static let firstTrkDateRecorded = Date(timeIntervalSince1970: 7305*24*3600 + 6*3600)
    static let lastTrkDateRecorded  = Date()
    static var isUnitTesting: Bool {
        let isU = ProcessInfo.processInfo.environment["UNITTEST"]
        if isU != "1" {
            print("ProcessInfo.processInfo.environment[\"UNITTEST\"] = \(isU ?? "??")")
            //
        }
        return ProcessInfo.processInfo.environment["UNITTEST"] == "1"
    }

}//end

//MARK: - USER PREFERENCES

public struct UserPrefs {
    static let dropDownFilesNewest = 6  // How many recently changed trk files shown in cboFiles ComboBox Dropdown list
    static let dropDownFilesLatest = 6  // How many most recent flights (as indicated by filename) in cboFiles ComboBox Dropdown list
}//end


//MARK: - TRK FILE FUNCS

public struct Gfunc {

    //---- displayLatLon - Display Latitude & Longitude
    static func clipboardLatLon(lat: Double, lon: Double, isDegMin: Bool) -> String {
        let lat = max(-90, lat)
        var txtLatLon: String
        if isDegMin {
            let latTxt = Gb.latText(deg: lat, res: 3)
            let lonTxt = Gb.lonText(deg: lon, res: 3)
            txtLatLon = latTxt + " " + lonTxt
        } else {
            txtLatLon =  "\(String(format: "%7.3f", lat)), \(String(format: "%8.3f",lon))"
        }
        return txtLatLon
    }//end func

    static func displayLatLon(lat: Double, lon: Double, isDegMin: Bool) -> String {
        let lati = max(-90, min(90, lat))
        let long = max(-180, min(180, lon))
        let txtLatLon: String
        if isDegMin {
            let latTxt = Gb.latText(deg: lati, res: 2)
            let lonTxt = Gb.lonText(deg: long, res: 2)
            txtLatLon = latTxt + " " + lonTxt
        } else {
            txtLatLon =  "\(String(format: "%7.4f", lati)), \(String(format: "%8.4f",long))"
        }
        return txtLatLon
    }//end func

    /// LonText - Convert Numerical Deg into "EDD MM.Mmmm" or "WDD MM.Mmmm" format - Lon sign is correct
    /// Convert Longitude Degrees into "EDD MM.Mmmm" or "WDD MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func lonTextForPCX5AVD(deg: Double, res: Int = 5) -> String {
        // "T  N2837.14571 W08145.12987 19-JAN-96 22:03:34 -9999"  (Pcx5AVD) DegMin<sp>DegMin
        let str: String
        var leadingZero = ""
        if abs(deg) < 100.0 { leadingZero = "0" }
        if deg < 0.0 {
            str = "W" + leadingZero + latlonTextForPCX5AVD(deg, res: res)
        } else {
            str = "E" + leadingZero + latlonTextForPCX5AVD(deg, res: res)
        }
        return str
    }//end func

    /// Convert Latitude Degrees into "NDD MM.Mmmm" or "SDD MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func latTextForPCX5AVD(deg: Double, res: Int = 5) -> String {
        //Calls LLtest
        var str: String
        if deg < 0.0 {
            str = "S" + latlonTextForPCX5AVD(deg, res: res)
        } else {
            str = "N" + latlonTextForPCX5AVD(deg, res: res)
        }
        return str
    }//end func latText

    /// Convert dblDeg into "DD°MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func latlonTextForPCX5AVD(_ dblDeg: Double, res: Int = 5) -> String {
        let td = abs(dblDeg)
        let formater = NumberFormatter()    //????? Change to not use NumberFormatter
        formater.minimumIntegerDigits  = 2
        formater.minimumFractionDigits = res
        formater.maximumFractionDigits = res
        var intDeg = Int(td)
        let minutes = (td - Double(intDeg)) * 60.0
        var formattedMin = formater.string(from: minutes as NSNumber) ?? "??"
        if formattedMin.hasPrefix("60") {
            formattedMin = formater.string(from: 0.0 as NSNumber) ?? "??"
            intDeg += 1
        }
        return "\(intDeg)\(formattedMin)"
    }//end func latlonText



    static func airportDictToStr(dict: [String:Int], maxWid: Int, startLine: String) -> String {
        let array = dict.sorted(by: { $0.value > $1.value })
        var str = startLine
        for (key, value) in array {
            var ky = key
            if ky.hasPrefix("US-") { ky = String(ky.dropFirst(3)) }
            let addTo = " \(ky):\(value),"
            str += addTo
            if str.count >= maxWid { break }
        }
        return String(str.dropLast(1))
    }//end func

}//end struct Gfunc

public struct MyLog {

    @discardableResult static func showUnitTest(str: String) -> String {
        let txt: String
        if Gcc.isUnitTesting {
            txt = "⚙️✅ \(str) UnitTest"
        } else {
            txt = "🙂✅ \(str) Normal Run"
        }
        print(txt)
        return txt
    }
}
