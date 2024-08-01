//
//  TrkLog.swift
//  Garmitrk
//
//  Created by George Bauer on 8/11/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import Foundation

// TrkLog is used to to tranlate & hold the info from a GPS Track Log.
// It is initialized be reading a file in 1 of several formats or "TrkType"s (see trkPoint)
public struct TrkLog {
    
//    enum ErrMsg: Error {
//        case withMsg(msg: String)
//    }
    
//    public var timeZoneHr: Double?              // TimeZone offset of trkFile
    public var sepChar: Character = ","         // Comma or Tab
//    public var trkType      = TrkType.unknown   // Type of File trkPoints extacted from
//    public var garmSoftVer  = ""                // Garmin Software Version
    public var numTrkPoints = 0                 // Number of Trackpoints read
    public var trkPoints    = [TrkPoint]()      // Array to store Trackpoints 1-nTrkPoints
    public var lonLftTrk    = -120.0               // Lat/Lon Limits
    public var latTopTrk    = 55.0
    public var latBotTrk    = 22.0
    public var lonRgtTrk    = -70.0
    public var maxAlt       = 0
    
    init() { }
    
    //MARK: - func TrkLog.init 156
    //---- TrkLog.init - Reads entire TrackFile into [gTrackPoints], determines gTrkTyp & bounds
    init(url: URL) throws {    // 34-190 = 156-lines
        //Sets: numTrackPoints, [trackPoints], trkType, lonLftTrk, latTopTrk, latBotTrk, lonRgtTrk
        //------------------------ Determine Type of Trk File that we're reading ----------------------
        var lineText     = ""
        let fileManager  = FileManager.default
        let fileLines: [String]
        if(fileManager.fileExists(atPath: url.path)) {
            fileLines = FileHandler.readFileLines(url: url)
        } else {
            throw "TrkLog.init#\(#line) File does not exist!\n\(url.path)"
        }
        if fileLines.isEmpty { throw "TrkLog.init#\(#line) File empty or unreadable\n\(url.path)"}
        numTrkPoints = 0
        var lineNo = -1

        //-------------------------- Read in Trackpoints from the trk file -----------------------------
        latTopTrk = -999.9
        latBotTrk = 999.9
        lonRgtTrk = -999.9
        lonLftTrk = 999.9
        trkPoints = [TrkPoint]()
        
        while  lineNo < fileLines.count-1  {        // parse 148-211 = 63-lines $$ Timing 2.0 sec
            lineNo += 1
            lineText = fileLines[lineNo]
            if lineText == "" && lineNo >= fileLines.count-2 { break }  //ignore blank line at EOF
            
            var trkPt = TrkPoint()

        }//Loop thru file

        if trkPoints.isEmpty {
            print("😡 TrkLog.init#\(#line) No Trackpoints found")
        } else {
            let lastIdx = trkPoints.count - 1
            let tp0 = trkPoints[0]
            let tp = trkPoints[lastIdx]
            print("🤠 TrkLog.init#\(#line) 1st  trackpoint read: flightSegID \(tp0.flightSegID)  Sequence# \(tp0.sequence)   \(tp0.date)")
            print("🤠 TrkLog.init#\(#line) Last trackpoint read: flightSegID \(tp.flightSegID)  Sequence# \(tp.sequence)   \(tp.date)")
        }
        //------------------------------------  Sort if required -------------------------------------
        //$$ Timing 2.0 sec
        return
    }//end func TrkLog.init
    
    //MARK: - Create TrkPoint from trkFile line
    
    //==================================== PCX5AVD ==================================
    //         "H  LATITUDE    LONGITUDE ..." separates flightSegs     Use Line# for sequence
    
    /*
     H  SOFTWARE NAME & VERSION
     I  PCX5AVD 2.05
     H  R DATUM                IDX DA            DF            DX            DY            DZ
     M  G WGS 84               103 +0.000000e+00 +0.000000e+00 +0.000000e+00 +0.000000e+00 +0.000000e+00
     H  COORDINATE SYSTEM
     U  LAT LON DM
     H  LATITUDE    LONGITUDE    DATE      TIME     ALT    ;track
     T  N2830.39201 W08133.60710 16-FEB-96 15:11:14 -9999
     */
    //06/01/2001 03:00PM PCX5AVD txt files start having header showing Ver#2.11 with no letter
    //11/30/2002 10:30AM PCX5AVD txt files start having header showing Ver#2.20 with no letter
    //04/15/2003 04:30PM PCX5AVD txt files start having header showing Ver#2.21 with no letter
    //12/22/2004 11:00AM PCX5AVD txt files start having header showing Ver#3.00 with no letter
    //08/18/2005         PCX5AVD txt files start having header showing Ver#3.01 with no letter
    //08/18/2005 09:45PM PCX5AVD txt files start having header showing Ver#3.02 with no letter
    //08/20/2005         PCX5AVD txt files start having header showing Ver#3.03a
    //08/20/2005 12:01PM PCX5AVD txt files start having header showing Ver#3.04a
    //12/09/2005 Start using Garmin MapSource.
    //05/16/2014 Start using Garmin BaseCamp (1-time 2012-08-23 BaseCamp 696)

    // 1
//    public func getPcx5AVDTkPt(lineText: String, lineNo: Int, trkIDfromFile: inout Int) -> TrkPoint {
//        //                     Example LA960119-FL.TRK (regular); LA970725.TRK (has Alt,Dir,Kts)
//        //                      "T  N4538.01227 W06940.74515 09-AUG-95 16:19:52 -9999 "
//        var trkPt = TrkPoint()
//        trkPt.trkType   = .pcx5AVD
//        trkPt.trkIDfromFile = trkIDfromFile
//        trkPt.sequence  = lineNo+1                                                      // Sequence
//        var latTxt      = lineText.substring(begin: 3, length: 11)  // N2834.01570
//        latTxt          = String(latTxt.prefix(3)) + " " + latTxt.substring(begin: 3)
//        var lonTxt      = lineText.substring(begin: 15, length: 12) // W08133.05813
//        lonTxt          = String(lonTxt.prefix(4)) + " " + lonTxt.substring(begin: 4)
//        trkPt.lat       = Gb.decodeDegMin(strDegMin: latTxt)                            // Lat
//        trkPt.lon       = Gb.decodeDegMin(strDegMin: lonTxt)                            // Lon
//        
//        let dateTimeG = lineText.substring(begin: 28, length: 18)   //"09-AUG-95 16:19:52"  PCX5AVD
//        var tkptDateTime = GbDate.cDatePlus(dateTimeG)   //(dateTimeG + "Z")  //'????? Converts to Local ?did it use the rules of the time?
//        if GbDate.isDayLite(date: tkptDateTime) {
//            tkptDateTime = Calendar.current.date(byAdding: .hour, value: -4, to: tkptDateTime) ?? Date.distantPast
//        } else {
//            tkptDateTime = Calendar.current.date(byAdding: .hour, value: -5, to: tkptDateTime) ?? Date.distantPast
//        }
//        //dateTimePt = TimeZoneInfo.ConvertTimeToUtc(dateTimePt)     'reconvert to UTC using the rules of the time (not in XP or older)
//        trkPt.date      = tkptDateTime                                                  // DateTime
//        if lineText.count >= 62 {
//            let altTxt = lineText.substring(begin: 47, length: 5).trim
//            trkPt.alt   = Int(altTxt) ?? 0            //Alt=48,5 -9999 or " 1070"    len=54 or len=64  (Pilot3) PCX5AVD
//        }
//        trkPt.isGood    = true                                                          // isGood
//        return trkPt
//    }//end func
//    
//    
//
//    //==================================== MapSource ==================================
//    
//    //12/09/2005 Start using Garmin MapSource.
//    //"Track    ACTIVE LOG ..." separates flightSegs. Use Line# for sequence
//    //05/16/2014 Start using Garmin BaseCamp (1-time 2012-08-23 BaseCamp 696)
//
//    /*
//     Header    Name    Start Time    Elapsed Time    Length    Average Speed    Link
//     Track    ACTIVE LOG    9/17/2004 3:39:37 AM     00:02:59    23 ft    0.09 mph
//     Header    Position    Time    Altitude    Depth    Leg Length    Leg Time    Leg Speed    Leg Course
//     Trackpoint    N25 03.723 E121 38.414    9/17/2004 3:39:37 AM     231 ft
//     Trackpoint    N25 03.723 E121 38.411    9/17/2004 3:40:18 AM     160 ft        14 ft    00:00:41    0.24 mph    287∞ true
//     */
//
//    //                          Example: LAB31221.trk
//    //"Trackpoint    N28 32.140 W81 37.321    12/4/2013 4:17:38 PM     205 ft            0.2 mi    0:00:12    68 mph    55∞ true"
//    //                          Example: L4A91001.trk
//    //"Trackpoint    N28 34.246 W81 34.371    10/1/2009 3:23:42 PM     824 ft            0.3 mi    0:00:09    107 mph    347∞ true"
//    // MAA60406bu-utc contains "(UTC)"
//    // "Track    ACTIVE LOG ..." separates flightSegs     Use Line# for sequence
//    // 2
//    public func getMapSourceTkPt(lineText: String, lineNo: Int, trkIDfromFile: inout Int) -> TrkPoint {
//        var trkPt = TrkPoint()
//        trkPt.trkType   = .mapSource
//        
//        if lineText.hasPrefix("Trackp") {
//            trkPt.trkIDfromFile = trkIDfromFile
//            trkPt.sequence  = lineNo+1                                          // Sequence
//            
//            let elements = lineText.components(separatedBy: "\t")   // Tab Delimited  (MapSource)
//            
//            let latLonTxt  = elements[1]                            // Lat/Lon        (MapSource)
//            let idx = latLonTxt.firstIntIndexOf(" ", startingAt: 5)
//            let latTxt = latLonTxt.prefix(idx)
//            let lonTxt = latLonTxt.suffix(latLonTxt.count - idx - 1)
//            trkPt.lat    = Gb.decodeDegMin(strDegMin: String(latTxt))   // Lat "N28 30.611" L4A91001.trk
//            trkPt.lon    = Gb.decodeDegMin(strDegMin: String(lonTxt))   // Lon "W81 33.484" L4A91001.trk
//            var dateTimeG = elements[2]
//            if dateTimeG.hasSuffix("(UTC)") { // only in MapSource file "MAA60406bu-utc.trk" ?
//                dateTimeG = dateTimeG.substring(begin: 0, length: dateTimeG.count - 5).trim + "Z"  //Reads as UTC, converts to Local
//            }
//            trkPt.date = GbDate.cDate(dateTimeG)                        // Local
//            var altStr = elements[3].trim
//            if altStr.hasSuffix("ft") { altStr = String(altStr.dropLast(2)).trim}
//            trkPt.alt    = Int((Double(altStr) ?? 0.0 ).rounded())      // Alt was "Val" (MapSource)
//            trkPt.isGood    = true                                      // isGood
//        } else if lineText.contains("ACTIVE LOG") {
//            trkIDfromFile += 1
//        }//endif
//        
//        return trkPt
//    }//end func
//    
//    //05/16/2014 Start using Garmin BaseCamp (1-time 2012-08-23 BaseCamp 696)
//    // 3
//    public func getBaseCampTkPt(lineText: String, lineNo: Int, trkIDfromFile: inout Int, sepChar: Character) -> TrkPoint {
//        var trkPt = TrkPoint()
//        trkPt.trkType = .baseCamp
//        //                                           'Examples: MAB40702-FLPA.trk
//        let elements = lineText.components(separatedBy: String(sepChar))    //Tab or Comma  BaseCamp
//        if elements.count < 9 {
//            return trkPt
//        }
//        trkPt.sequence  = Int(elements[0].trim) ?? 0
//        trkPt.trkIDfromFile = Int(elements[1].trim) ?? 0              //trkIDfromFile   BaseCamp
//        guard let lat = Double(elements[2].trim) else { return trkPt }  //Lat
//        trkPt.lat       = lat                                           //Lat
//        guard let lon = Double(elements[3].trim) else { return trkPt }  //Lon
//        trkPt.lon       = lon                                           //Lon
//        trkPt.alt       = Int((Double(elements[4].trim) ?? 0.0) * Gb.cMeterToFeet + 0.5)
//        let dateTimeG   = elements[5]
//        trkPt.date      = dateTimeParseT(dateTimeG) //??? Converts to Local Did it use rules of the time?
//        trkPt.isGood    = true
//        return trkPt
//    }//end func
//    
//    //2020-08 add log_yymmdd_... for Cirrus SR22T N1326C
//    // 4
//    public func getSR22LogTkPt(lineText: String, lineNo: Int, trkIDfromFile: inout Int, sepChar: Character) -> TrkPoint {
//        var trkPt = TrkPoint()
//        trkPt.trkType = .sr22Log
//        
//        let elements = lineText.components(separatedBy: ",").map{$0.trim}   // Comma Delimited
//        if elements.count > 8 && !elements[4].isEmpty && !elements[5].isEmpty {
//            //print("TrkLog.init#\(#line) \(elements.count) elements")
//            trkPt.timeZoneHr = extractTimeZoneOffset(elements[2])
//            trkPt.sequence  = lineNo+1
//            trkPt.trkIDfromFile = 0                                         //TrkFlightSegID
//            guard let lat   = Double(elements[4]) else { return trkPt } //Lat
//            trkPt.lat       = lat                                       //Lat
//            guard let lon   = Double(elements[5]) else { return trkPt } //Lon
//            trkPt.lon       = lon                                       //Lon
//            guard let alt   = Double(elements[8]) else { return trkPt } //Alt
//            if abs(lat) < 0.01 && abs(lon) < 0.01 { return trkPt }      //Ignore 0.00N/0.00W
//            trkPt.alt       = Int(alt + 0.5)                            //Alt
//            trkPt.date      = dateTimeParseWithZone(dateStr:elements[0], timeStr: elements[1], zoneStr:elements[2])
//            trkPt.isGood    = true
//        }
//        return trkPt
//    }//end func
//    
//    //2021-07-31 ForeFlight
//    // 5
//    public func getForeflightTkPt(lineText: String, lineNo: Int, trkIDfromFile: inout Int, sepChar: Character) -> TrkPoint {
//        var trkPt = TrkPoint()
//        trkPt.trkType = .foreflight
//        //      Example:
//        let elements = lineText.components(separatedBy: ",").map {$0.trim}   // Comma Delimited
//        if elements.count > 5 && !elements[4].isEmpty && !elements[5].isEmpty {
//            //print("TrkLog.init#\(#line) \(elements.count) elements")
//            trkPt.sequence  = lineNo+1
//            trkPt.trkIDfromFile = 0                                     // trkIDfromFile
//            guard let lat = Double(elements[1]) else { return trkPt }   //Lat
//            trkPt.lat       = lat
//            guard let lon = Double(elements[2]) else { return trkPt }   //Lon
//            trkPt.lon       = lon
//            guard let alt = Double(elements[3]) else { return trkPt }   //Alt
//            trkPt.alt       = Int(alt + 0.5)                       
//            let epochTime = Double(elements[0]) ?? 0.0    //3600*24=86400sec/day = 31557600/yr
//            trkPt.date      = Date(timeIntervalSince1970: TimeInterval(epochTime))
//            if abs(lat) < 0.01 && abs(lon) < 0.01 {
//                return trkPt                                           //Ignore 0.00N/0.00W
//            }
//            trkPt.isGood    = true
//        }
//        return trkPt
//    }//end func
//    
//    
//    //MARK: - func dateTime Parses
//    
//    private func dateTimeParseT(_ str: String) -> Date {
//        let dateTime = str.components(separatedBy: "T")
//        if dateTime.count != 2 {
//            print("⛔️ TrkLog.init#\(#line) Error from dateTimeParseT. Could not translate: \(str)")
//        }
//        let rfc3339DateFormatter = DateFormatter()
//        rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//        /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
//        let date = rfc3339DateFormatter.date(from: str)
//        
//        return date ?? Date.distantPast       //????? Add logic here
//    }
//    
//    //2020-11-18 SR22
//    private func dateTimeParseWithZone(dateStr: String, timeStr: String, zoneStr: String) -> Date {
//        let str = "\(dateStr) \(timeStr)\(zoneStr)"
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
//        //dateFormatter.timeZone = TimeZone(abbreviation: "GMT\(zoneStr)") //Current time zone
//        let date = dateFormatter.date(from: str)
//        return date ?? Date.distantPast       //????? Add logic here
//    }
//    
//    //MARK: - Extract TimeZone Offset from "-hh:mm"
//    private func extractTimeZoneOffset(_ str: String) -> Double? {
//        // let comps    = str.components(separatedBy: ",")
//        let offsetStr = str.trim
//        if !offsetStr.isEmpty {
//            let halfs = offsetStr.components(separatedBy: ":")
//            return Double(halfs[0])
//        }
//        return nil
//    }
    
    
}//end struct
