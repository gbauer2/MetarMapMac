//
//  OtherExtensions.swift
//  Weather Central
//
//  Created by George Bauer on 12/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import Foundation

//print("double:\(lat.format(".3"))")
extension Double {

    func formatDbl(_ fmt: String) -> String {
        return String(format: "%\(fmt)f", self)
    }

    func formatPct() -> String {
        let pct = String(Int(self * 100 + 0.5)) + "%"
        return pct.PadLeft(4) //width: 4)
    }

}//Double



extension String {

    ///returns a Date from a String e.g. "2020-06-05 17:05:06"
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self) ?? Date.distantPast
        return date
    }

    ///returns a Date from a String e.g. "2020-06-05T17:05:06"
    func toDateISO8601() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: self)
        return date
    }

}

