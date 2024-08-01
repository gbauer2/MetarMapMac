//
//  Gb.swift
//  Garmitrk
//
//  Created by George Bauer on 8/1/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import AppKit

public struct Gb {
    
    //MARK: - Constants
    static let cMeterToFeet = 3.28084
    static let cDegToRad    = 3.1416 / 180.0
    static let cRadToDeg    = 57.2957795
    static let cNMtoMeters  = 1852.0
    static let cMetersToNM  = 0.000539957
    
    //MARK: - Int & Double
    ///Use 'Int(Double(str.rounded() )' instead
    static func int(str: String, round: Bool = true) -> Int {
        let dbl = Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
        let ret: Int
        if round {
            ret = Int(dbl.rounded())
        } else {
            ret = Int(dbl)
        }
        return ret
    }

//    ///Use 'Int(dbl.rounded() )' instead
//    static func int(dbl: Double, round: Bool = true) -> Int {
//        if round {
//            return Int(dbl.rounded())
//        } else {
//            return Int(dbl)
//        }
//    }

    ///Use 'Int(str) ?? 0' instead
    static func cInt(_ str: String) -> Int {
        return Int(str) ?? 0
    }

    /// Use 'Double(str.trim) ?? 0' instead
    static func dbl(str: String) -> Double {
        return Double(str.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0.0
    }


    // ---- Test if a String is a valid Number ---
    /// true if String converts to Double
    /// - Parameter str: The String to be tested.
    /// - Returns: Bool
    static func isNumeric(_ str: String) -> Bool {
        return Double(str.trimmingCharacters(in: .whitespaces)) != nil
    }

    /// - Parameters:
    ///   - dbl: Double to be rounded
    ///   - places: Number of decimal places in returned value
    /// - Returns: Double
    static func roundTo(dbl: Double, places: Int) -> Double {
        let numberOfPlaces: Double = Double(places)
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(dbl * multiplier) / multiplier
        return rounded
    }

    //MARK: - String
    
    //------ replaceStr - String, index into str(base 0), number of chars to delete, String to insert
    static func replaceStr(str: String, idx: Int, len: Int, newStr: String) -> String {
        //"01234567", idx=3, len=2, "ab"
        //"012ab567"
        let left = str.prefix(idx)
        let rght = str.suffix(str.count - idx - len)
        let returnStr = left + newStr + rght
        return String(returnStr)
    }

    //Remove Leading and Trailing Quotes (") and Spaces
    static func removeQuotes(_ str: String) -> String {
        var newStr = str.trim
        if newStr.hasPrefix("\"") {
            newStr = String(newStr.dropFirst())
        }
        if newStr.hasSuffix("\"") {
            newStr = String(newStr.dropLast())
        }
        return newStr
    }//end func

    


    //-----------------------------------------------------------------------------------------------
    //MARK: - Lat/Lon (4 funcs)

    /// Convert a "Ndd mm.mm" string into a Real number
    ///
    /// North is positive, East is positive
    /// - Parameter strDegMin: String like "N28 33.5"
    /// - Returns: Double like 28.55
    static func decodeDegMin(strDegMin: String) -> Double {
        let errorVal = 0.0                          //??? Change to -999 for error detection
        var str = strDegMin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if str.count < 2 { return errorVal }

        let a1 =  String(str.prefix(1))
        var multiplier = 1.0
        if "-NSEW".contains(a1){
            str = String(str.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
            if a1 == "S" || a1 == "W"  || a1 == "-" { multiplier = -1.0 }
        }

        let separators = CharacterSet(charactersIn: " °\"'")            // space and chars for deg,min,sec as seperators
        let comps = str.components(separatedBy: separators)             // Separate the components
        let components = comps.filter { (x) -> Bool in !x.isEmpty }     // Use filter to eliminate empty strings.
        let nComponents = components.count

        let aDeg = components[0]
        guard let valDeg = Double(aDeg) else { return errorVal }
        if nComponents < 2 { return multiplier * valDeg }               // 1 component  (deg)

        let aMin = components[1]
        guard let valMin = Double(aMin) else { return errorVal }
        if nComponents < 3 { return multiplier * (valDeg + valMin/60) } // 2 components (deg min)

        let aSec = components[2]
        guard let valSec = Double(aSec) else { return errorVal }
        return multiplier * (valDeg + valMin/60 + valSec/3600)          // 3 components (deg min sec)
    }//end func decodeDegMin

    /// Convert Latitude Degrees into "NDD MM.Mmmm" or "SDD MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func latText(deg: Double, res: Int = 1) -> String {
        //Calls LLtest
        var str: String
        if deg < 0.0 {
            str = "S" + latlonText(deg, res)
        } else {
            str = "N" + latlonText(deg, res)
        }
        return str
    }//end func latText

    /// LonText - Convert Numerical Deg into "EDD MM.Mmmm" or "WDD MM.Mmmm" format - Lon sign is correct
    /// Convert Longitude Degrees into "EDD MM.Mmmm" or "WDD MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func lonText(deg: Double, res: Int = 1) -> String {
        //Calls LLtest
        let str: String
        if deg < 0.0 {
            str = "W" + latlonText(deg, res)
        } else {
            str = "E" + latlonText(deg, res)
        }
        return str
    }//end func

    /// Convert dblDeg into "DD°MM.Mmmm" format
    ///
    /// - Parameters:
    ///   - deg: Latitude - degrees
    ///   - res: Decimal places in Minutes
    /// - Returns: String
    static func latlonText(_ dblDeg: Double, _ res: Int = 1) -> String {
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
        return "\(intDeg)° \(formattedMin)'"
    }//end func latlonText

    //------------------------------------------------------------------------------------------------------

    
    //MARK: - Formatting

    /// Integer format "00", "###000"
    static func format(int: Int, format: String) -> String {
        let fieldLen = format.count
        var zeros = 0
        for char in format {
            if char == "0" { zeros += 1 }
        }
        var str = "\(int)"
        if str.count < zeros {
            str = String(repeating: "0", count: zeros - str.count) + str
        }
        if str.count < fieldLen {
            str = String(repeating: " ", count: fieldLen - str.count) + str
        }
        return str
    }

    //Make Format #### work like it should (maintain leading spaces)
    static func formatD(_ integer: Int, _ myFormat: String, _ zeroSubstitute: String = "") -> String {
        let fieldLen = myFormat.count
        let str: String
        if zeroSubstitute.isEmpty || integer != 0 {
            str = format(int: integer, format: myFormat)
        } else {
            str = zeroSubstitute
        }
        let spaces  = fieldLen - str.count
        let frmat: String
        if spaces >= 0 {
            frmat   = String(repeating: " ", count: spaces) + str
        } else {
            frmat   = String(repeating: "%", count: fieldLen)
        }
        return frmat
    }//end func

    //Make Format ###0.00 work like it should (maintain leading spaces)
    //print(String(format: "%.3f", totalWorkTimeInHours))
    static func formatF(_ val: Double, _ myFormat: String, _ zeroSubstitute: String = "") -> String {
        let parts   = myFormat.components(separatedBy: ".")
        var places  = 0
        if parts.count == 2 { places = parts[1].count }
        var frmat   = ""
        let str       = String(format: "%.\(places)f",val)
        let spaces  = myFormat.count - str.count
        if spaces >= 0 {
            frmat   = String(repeating: " ", count: spaces) + str
        } else {
            frmat   = str.substring(begin: 0, length: myFormat.count)
        }
        if !zeroSubstitute.isEmpty {
            if val == 0.0 {
                frmat = String(repeating: " ", count: myFormat.count)
                let zSub = String(zeroSubstitute.prefix(frmat.count))
                let idx = frmat.count - zSub.count
                frmat = Gb.replaceStr(str: frmat, idx: idx, len: zSub.count, newStr: zSub)
            }
        }
        return frmat
    }

    static func formatIntComma(number: Int, fieldLen: Int) -> String {
        let str1 = formatComma(int: number)
        let str2 = str1.PadLeft(fieldLen)
        return str2
    }

    static func formatComma(int: Int) -> String {
        let formater = NumberFormatter()
        formater.numberStyle = .decimal
        formater.minimumIntegerDigits = 0
        return formater.string(from: NSNumber(value: int)) ?? "\(int)"
    }

    //---- Format an integer with leading zeros e.g. (5, 3) -> "005" ----
    static func formatIntWithLeadingZeros(_ num: Int, width: Int) -> String {
        var str = String(num)
        while str.count < width {
            str = "0" + str
        }
        return str
    }

    //MARK: - Alert
    
    static func alert(_ str: String, title: String = "Alert") {
        //DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = str
            alert.runModal()
        //}//end main
    }//end func

}//end struct Gb

//MARK: - Int extention

extension Int {
    func fmatZeros(wid: Int) -> String {
        let str = Gb.formatIntWithLeadingZeros(self, width: wid)
        return str
    }
}//end extension Int
