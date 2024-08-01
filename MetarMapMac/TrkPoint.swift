//
//  ReadTrkFile.swift
//  Garmitrk
//
//  Created by George Bauer on 4/17/18.
//  Copyright © 2018-2021 GeorgeBauer. All rights reserved.
//

import Foundation

//MARK: - TrkPoint struct
public struct TrkPoint: Equatable {
    var isGood          = false
    var lat             = 0.0               // Lat(deg)
    var lon             = 0.0               // Lon(deg)
    var alt             = 0                 // Alt(ft)
    var date            = Date.distantPast  // Date/Time (Date)
    var lineSegDist     = 0.0               // LineSegment Length (NM) not used
    var lineSegKts      = 0                 // LineSegment Speed (Kts)
    var lineSegSec      = 0                 // LineSegment Time (sec)
    var lineSegDir      = 0                 // LineSegment Direction (deg)
    var lineSegAltDif   = 0                 // LineSegment Alt dif (ft)
    var lineSegClimbRate = 0                // LineSegment Rate-of-Climb (ft/min)
    var isFlying        = false             // Phase was Flying (not taxi)
    var flightSegID     = 0                 // flightSegID Number
    var trkIDfromFile   = 0                 // trkID from BaseCamp or generated
    var sequence        = 0                 // point sequence number
    var trkType         = TrkType.unknown   // enum below
    var timeZoneHr: Double?                 // Timezone offset from UTC

    init() { }
    
//    init(isGood: Bool, lat: Double, lon: Double, alt: Int, date: Date, flightSegID: Int) {
//        self.isGood = isGood
//        self.lat    = lat
//        self.lon    = lon
//        self.alt    = alt
//        self.date   = date
//        self.flightSegID = flightSegID
//    }

}//end struct TrkPoint

//MARK: - Track Type eNum
//
public enum TrkType {
    case unknown    // Cannot be determined
    case pcx5AVD    // PCX5AVD was the original Garmin program for (90,Pilot-III) Ver 2 has some Alts
    case mapSource  // MapSource a later Garmin program (296, 396, 496, 696) - has alt
    case baseCamp   // BaseCamp is current? Garmin software (496, 696) (as of Sept 2021)
    case sr22Log    // 2020-11-18 Cirrus SR22 log from Perspective+ avionics.
    case foreflight // 2021-07-31 Foreflight TrackLog from plan.foreflight.com
}//end enum

