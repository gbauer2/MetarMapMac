//
//  GbDate.swift
//  Garmitrk
//
//  Created by George Bauer on 12/12/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import Foundation

public struct GbDate {
    
//    //MARK: - DATE
//
//    // Make Date from str: Year Only, mm/dd/yy, mm/dd, yy-mm-dd, yy-mm
//    static func makeDate(_ text: String, isFirst: Bool) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy"
//        let text = text.trim
//        var dateStr = ""
//        if Gb.isNumeric(text) {                        // Year Only
//            guard var yr = Int(text) else { return nil }
//            if yr >= 80 && yr <= 99 { yr += 1900 }  // 80-99 -> 1980-1999
//            if yr >= 00 && yr <= 45 { yr += 2000 }  // 00-45 -> 2000-2045
//            if isFirst {
//                dateStr = "01/01/\(yr)"
//            } else {
//                dateStr = "12/31/\(yr)"
//            }
//        } else {
//            let slashComps = text.components(separatedBy: "/")
//            if slashComps.count == 3 {              // mm/dd/yy
//                dateStr = GbDate.fix2DigitDateStr(text)
//            } else if slashComps.count == 2 {       // mm/dd
//                let thisYrStr = dateFormatter.string(from: Date())
//                dateStr = text + "/" + thisYrStr
//            } else {
//                let dashComps = text.components(separatedBy: "-")
//                if dashComps.count == 3 {           //yy-mm-dd
//                    let dashText = "\(dashComps[1])/\(dashComps[2])/\(dashComps[0])"
//                    dateStr = GbDate.fix2DigitDateStr(dashText)
//                } else if dashComps.count == 2 {    //yy-mm
//                    let dayStr: String
//                    if isFirst {
//                        dayStr = "01"
//                    } else {
//                        guard let mo = Int(dashComps[1]) else { return nil }
//                        switch mo {
//                        case 9,4,6,11:
//                            dayStr = "30"
//                        case 2:
//                            dayStr = "28"
//                        default:
//                            dayStr = "31"
//                        }
//                    }
//                    let dashText = "\(dashComps[1])/\(dayStr)/\(dashComps[0])"
//                    dateStr = GbDate.fix2DigitDateStr(dashText)
//                }
//            }
//        }
//        //            print("FilterTrkFileVC#\(#line) makeDate - dateStr =", dateStr)
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        guard let date = dateFormatter.date(from: dateStr) else { return nil }
//        if date < Date.init(timeIntervalSince1970: 0) {
//            return nil
//        }
//        return date
//    }
//
//
//    //------ decodeYYYY_MM_dd - Convert "YYYY-MM-dd' to Date
//    static func decodeYYYY_MM_dd(_ str: String) -> Date {
//        let comps = str.components(separatedBy: "-")
//        if comps.count < 3 { return  Date.distantPast }
//        let newStr = comps[1] + "/" + comps[2] + "/" + comps[0]
//        return cDate(newStr)
//    }
//    
//    //---- fix2DigitDateStr - change "1/1/6" or "1/1/06" to "1/1/2006"; change "1/1/96" to "1/1/1996" (80-99)
//    static func fix2DigitDateStr(_ str: String) -> String {
//        var dateComps = str.components(separatedBy: "/")
//        if dateComps.count != 3      { return str }
//        let yr2 = dateComps[2]
//        if yr2.count > 2             { return str }
//        guard let yr = Int(yr2) else { return str }
//        if yr < 80 {
//            dateComps[2] = String(2000 + yr)
//        } else {
//            dateComps[2] = String(1900 + yr)
//        }
//        return dateComps.joined(separator: "/")
//    }//end func
//    
//    /// Translate '05-AUG-97 13:50' to a Date
//    static func cDatePlus(_ str: String) -> Date {
//        //cDate could not translate '05-AUG-97 13:50'
//        let newStr: String
//        if str[2] == "-" &&  str[6] == "-" {
//            let mo    = decode3LetterMon(monthStr: str.substring(begin: 3, length: 3) )
//            let da    = str.prefix(2)
//            let yrStr = str.substring(begin: 7, length: 2)
//            var yr    = (Int(yrStr) ?? -100) + 1900
//            if yr < 1970 { yr += 100 }
//            var time  = ""
//            if str.count > 11 { time = str.substring(begin: 9) }
//            newStr = "\(mo)/\(da)/\(yr)\(time)"
//        } else {
//            newStr = str
//        }
//        return cDate(newStr)
//    }//end func
//    
//    static func isDate(_ dateStr: String) -> Bool {
//        let dateStr = dateStr.trim
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        guard let _ = dateFormatter.date(from: dateStr) else { return false }
//        return true
//    }
//    
//    /// Converts "MM/dd/yyyy" or "MM/dd/yyyy hh:mm:ss a" to Date
//    ///
//    /// Caution: returns 11/11/1111 if nil
//    ///       Only works if default (local computer) Timezone same as str
//    /// - Parameter str: String to be converted
//    /// - Returns: Date
//    static func cDate(_ str: String) -> Date {
//        let dateStr = str.trim
//        let len = dateStr.count
//        let dateFormatter = DateFormatter()
//        let nilDate = Date.distantPast
//        if len <= 10 {
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let optionalDate: Date? = dateFormatter.date(from: dateStr)
//            if let date = optionalDate { return date }
//        } else if len >= 17 {                                           // was 19: fix for "8/09/1995 16:19:52"
//            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"          // fix for "8/09/1995 16:19" len=12
//            var optionalDate: Date? = dateFormatter.date(from: dateStr)
//            if optionalDate == nil {                                    // fix for "8/09/1995 16:19:52"
//                dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"        // fix for "8/09/1995 16:19:52"
//                optionalDate = dateFormatter.date(from: dateStr)        // fix for "8/09/1995 16:19:52"
//            }
//            if optionalDate == nil {                                    // fix for "7/31/2005 2:58 PM"
//                dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"         // fix for "7/31/2005 2:58 PM"
//                optionalDate = dateFormatter.date(from: dateStr)        // fix for "7/31/2005 2:58 PM"
//            }
//            if let date = optionalDate { return date }
//        } else if len >= 12 {               //was 14: fix for "8/09/1995 16:19" len=12
//            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
//            //dateFormatter.timeZone = NSTimeZone.init(forSecondsFromGMT: 0) as TimeZone?
//            
//            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
//            let optionalDate: Date? = dateFormatter.date(from: dateStr)
//            if let date = optionalDate {
//                var dc = date.getComponents()
//                guard var yr = dc.year else { return Date.distantPast }
//                if yr < 100 {
//                    if yr < 80 { yr += 2000 } else { yr += 1900 }
//                    dc.year = yr
//                    guard let retDate = dc.date else { return Date.distantPast }
//                    return retDate
//                }
//                return date
//            }
//        }
//        return nilDate
//    }
//    
//    static func cDate(str: String, format: String) -> Date {
//        var dateStr = str.trim
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        if dateStr.hasSuffix("Z") || dateStr.hasSuffix("GMT") || dateStr.hasSuffix("UTC") {
//            dateStr = dateStr.replacingOccurrences(of: "Z", with: "")
//            dateStr = dateStr.replacingOccurrences(of: "GMT", with: "")
//            dateStr = dateStr.replacingOccurrences(of: "UTC", with: "")
//            dateStr = dateStr.trim
//            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//        }
//        //rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//        let optionalDate: Date? = dateFormatter.date(from: dateStr)
//        guard let date = optionalDate else { return Date.distantPast }
//        return date
//    }
//    
//    
//    /// Converts MM,dd,yyyy to Date
//    ///
//    /// - Parameters:
//    ///   - month: month Int
//    ///   - day:   day Int
//    ///   - year:  4-digit year Int
//    /// - Returns: Date
//    static func cDate(month: Int, day: Int, year: Int) -> Date {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        let dateStr = "\(month)/\(day)/\(year)"
//        guard let date = dateFormatter.date(from: dateStr) else { return Date.distantPast }
//        return date
//    }
//    
//    //Gets Month, Day, Year from a text  "23-JUL-97" or "01/19/1996"
//    static func decodeDate(str: String) -> (year: Int, mon: Int, day: Int, err: String) {
//        var nYear  = 0
//        var nMonth = 0
//        var nDay   = 0
//        if str.contains("-") {                                  // --------------------
//            //decodeDate = str                                  // 23-JUL-97  dd-MMM-yy
//            nDay   = Int(str.prefix(2).trim) ?? 0
//            nMonth = decode3LetterMon(monthStr: str.substring(begin: 3, length: 3))
//            nYear  = Int(str.substring(begin: 7).trim) ?? 0
//        } else if str.firstIntIndexOf("/") >= 1 {               // -------------------
//            let comps = str.components(separatedBy: "/")        // 1st "/"
//            if comps.count < 3 { return (0, 0, 0, "missing slash") }
//            nMonth = Int(comps[0].trim) ?? 0
//            nDay   = Int(comps[1].trim) ?? 0
//            nYear  = Int(comps[2].trim) ?? 0
//        } else {
//            return (0, 0, 0, "bad format")
//        }
//        
//        if nYear < 100 {
//            if nYear > 80 {
//                nYear = nYear + 1900
//            } else {
//                nYear = nYear + 2000
//            }
//        }
//        return (nYear, nMonth, nDay, "")
//    }//end func decodeDate
//    
//    
//    /// returns true if Daylight Savings Time in US on a particular Month,Day,Year (Fixed for post 2007 rules)
//    ///
//    /// - Parameters:
//    ///   - date:  Date
//    /// - Returns: true if Daylight Savings Time in US
//    static func isDayLite(date: Date) -> Bool {
//        let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone, .weekday]
//        let dateComponents = Calendar.current.dateComponents(unitFlags, from: date)
//        
//        guard let iMonth = dateComponents.month,
//              let iDay   = dateComponents.day,
//              let iYear  = dateComponents.year,
//              let weekday = dateComponents.weekday else {
//                  print("\n⛔️ GBisDaylite could not translate the date \(date.ToString(""))\n")
//                  return false
//              }
//        let dayofWeek = weekday - 1
//        //let dayofWeek = Weekday(Date.distantPastDate(iMonth, iDay, iYear)) - 1
//        
//        if iYear < 2007 {       //************ old rules up to 2007
//            if iMonth > 4 && iMonth < 10 {
//                return true                         // 5,6,7,8,9
//            } else if iMonth < 4 || iMonth > 10 {
//                return false                        // 1,2,3, 11,12
//            }//endif
//            
//            // Starts first Sunday in Apr
//            if iMonth == 4 && iDay - dayofWeek > 0   { return true }
//            // Ends last Sunday of Oct
//            if iMonth == 10 && iDay - dayofWeek < 25 { return true }
//            
//        } else {                //************ new rules starting 2007
//            if iMonth > 3 && iMonth < 11 {
//                return true                         // 4,5,6,7,8,9,10
//            } else if iMonth < 3 || iMonth > 11 {
//                return false                        // 1,2, 12
//            }//endif
//            
//            // Starts 2nd Sunday of March
//            if iMonth == 3 {
//                if iDay - dayofWeek > 7  { return true }
//            } else if iMonth == 11 {
//                // Ends 1st Sunday of November
//                if iDay - dayofWeek <= 0 { return true }
//            }
//        }
//        return false
//    }//end func isDayLite
//    
//    
//    /// Return formatted String of today's date
//    /// - Parameters:
//    ///   - format: String e.g. "MM/dd/yyyy"
//    /// - Returns: String
//    static func todayStr(format: String = "MM/dd/yyyy") -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        let dateStr = dateFormatter.string(from: Date())
//        return dateStr
//    }
//    
//    /// Format a Date using a format String.
//    ///
//    /// - Parameters:
//    ///   - date: Date to be formatted
//    ///   - format: e.g. \"E MM/dd/yyyy hh:mm:ss a\"
//    /// - Returns: String
//    static func format(date: Date, format: String = "MM/dd/yyyy") -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = format
//        let dateStr = dateFormatter.string(from: date)
//        return dateStr
//    }
//    
//    /// Make "hh:mm" from hr.  Truncates seconds.
//    ///
//    /// - Parameters:
//    ///   - hr:      Double
//    ///   - fillChr: fill char for hr 1-9 "0" or " ", defaults to none
//    /// - Returns: String like "9:23"
//    static func hourMin24(hr: Double, fillChr: String = "") -> String {
//        let iHour   = Int(hr)
//        let iMin    = Int((hr - Double(iHour)) * 60.0)
//        let strLeft = String("\(fillChr)\(iHour)".suffix(2))
//        let strRght = String("0\(iMin)".suffix(2))
//        return strLeft + ":" + strRght
//    }//end func hourMin24
//    
//    /// Converts "Jan" to 1, etc.
//    ///
//    /// If 1st 3 chars don't match: return 0
//    static func decode3LetterMon(monthStr: String) -> Int {
//        if monthStr.count >= 3 {
//            switch monthStr.prefix(3).uppercased() {
//            case "JAN":
//                return 1
//            case "FEB":
//                return 2
//            case "MAR":
//                return 3
//            case "APR":
//                return 4
//            case "MAY":
//                return 5
//            case "JUN":
//                return 6
//            case "JUL":
//                return 7
//            case "AUG":
//                return 8
//            case "SEP":
//                return 9
//            case "OCT":
//                return 10
//            case "NOV":
//                return 11
//            case "DEC":
//                return 12
//            default:
//                return 0
//            }//end Select
//        }//endif
//        return 0
//    }//end func deCode3LetterMon
//    
//    /// Convert Month# to text (n letters long)
//    ///
//    /// If length=0: use actual length.
//    ///
//    ///If length=4: put period at end of most.
//    ///
//    /// Jan, Jan., Janu, Janua
//    ///
//    /// - Parameters:
//    ///   - month: Numerical Month
//    ///   - length: Number of Characters in output (up to 9)
//    /// - Returns: String
//    static func monthToText(monthInt: Int, length: Int = 0) -> String {
//        var name: String
//        
//        switch monthInt {
//        case 1:
//            name = "January  "
//        case 2:
//            name = "February "
//        case 3:
//            name = "March    "
//        case 4:
//            name = "April    "
//        case 5:
//            name = "May      "
//        case 6:
//            name = "June     "
//        case 7:
//            name = "July     "
//        case 8:
//            name = "August   "
//        case 9:
//            name = "September"
//        case 10:
//            name = "October  "
//        case 11:
//            name = "November "
//        case 12:
//            name = "December "
//        default:
//            name = "?\(monthInt)?"
//        }//end Select
//        if length > 0 {
//            if length == 4 {                     // n = 4
//                switch monthInt {
//                case 5,6,7,9:
//                    name = name.left(4)
//                default:
//                    name = name.left(3) + "."
//                }
//            } else {
//                name = String(name.prefix(length))        // n = 1,2,3,  5,6,7,...
//            }//endif
//        } else {
//            name = name.trimmingCharacters(in: .whitespacesAndNewlines)              // n <= 0
//        }//endif
//        return name
//    }//end func monthToText
//
//    //MARK: - Date Math
//
//    // ---- isSameDay ----
//    /// Returns true if the date portion of 2 Dates is the same
//    /// - Parameter date1: The first Date
//    /// - Parameter date2: The second Date
//    /// - Returns: Bool
//    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
//        let dateC1 = date1.getComponents()
//        let dateC2 = date2.getComponents()
//        let sameDay = dateC1.day == dateC2.day && dateC1.month == dateC2.month && dateC1.year == dateC2.year
//        return sameDay
//    }
//    
//    /// Calculate time dif between 2 Dates in secs. Negative if Date2 < Date1
//    /// - Parameter date1: The first Date
//    /// - Parameter date2: The second Date
//    /// - Returns: Double: Difference in seconds
//    static func timeDiffSecs(date1: Date, date2: Date) -> Double {
//        let difference = date2.timeIntervalSince(date1)
//        return difference
//    }
    
}//end struct GbDate
