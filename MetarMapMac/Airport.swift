//
//  Airport.swift
//  WeatherKitDemo
//
//  Created by George Bauer on 2024-07-14.
//

import Foundation

public struct Airport {
    var ID       = ""
    var city     = ""
    var name     = ""
    var state    = ""
    var country  = ""
    var apType   = ""       // S,M,L,W
    var priv     = false    // 1 128=PrivOwn,64=Fee,16=Twr,8=PrivUse,4=Mil
    var customs  = 0
    var lat      = 0.0
    var lon      = 0.0
    var elev     = 0
    var longest  = 0
    var freqCTAF = 0
    var freqATIS = 0
    var nRWYs    = 0
    var dist     = 0.0
}//struct Airport

extension Airport: CustomDebugStringConvertible {
    public var debugDescription: String {
        let cityX = city.isEmpty ? "xxxx" : city
        return "\(ID) \"\(apType)\" \(name) \(cityX),\(state) \(lat.formatDbl(".2")) \(lon.formatDbl(".2"))"
    }

}//extension
