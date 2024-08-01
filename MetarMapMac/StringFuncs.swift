//
//  StringFuncs.swift
//  WeatherKitDemo
//
//  Created by user on 7/24/23.
//

import Cocoa
import WeatherKit

//MARK: --- Format Fuctions ---

//func formatPct(_ dbl: Double) -> String {
//    let pct = String(Int(dbl * 100 + 0.5)) + "%"
//    return pct.PadLeft(4) //width: 4)
//}

func formatDate(_ date: Date, format: String = "MM/dd/yyyy") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    let dateStr = dateFormatter.string(from: date)
    return dateStr
}

func formatExpiration(metadata: WeatherMetadata?) -> String {
    let expirationDate = metadata?.expirationDate ?? Date.distantPast
    let dataSentDate   = metadata?.date ?? Date.distantPast
    let metaStr = "   Data sent \(formatDate(dataSentDate  , format: "HH:mm:ss")),  Expires \(formatDate(expirationDate, format: "HH:mm:ss"))"
    return metaStr
}

/*
 func getWxStatusImage(status: City.WxStatus) -> UIImage {
 let questionMark = UIImage(systemName:"questionmark.square.fill") ?? UIImage(imageLiteralResourceName: "QuestionMark")
 switch status {
 case .unknown:
 return UIImage(systemName:"questionmark.square.fill") ?? questionMark
 case .current:
 return UIImage(systemName:"checkmark.square.fill") ?? questionMark
 case .expired:
 return UIImage(systemName:"xmark.square.fill") ?? questionMark
 case .error:
 return UIImage(systemName:"xmark.square.fill") ?? questionMark
 }
 }

 func printWeather(wx: Weather) {
 let cw = wx.currentWeather
 let fmd = "yyyy-MM-dd HH:mm:ss"
 print("Current: date \(cw.date.ToString(fmd))ET  metaDate \(cw.metadata.date.ToString(fmd))ET  metaExpire\(cw.metadata.date.ToString(fmd))ET")
 print("\(cw.condition)  Temp \(cw.temperature) FeelsLike \(cw.apparentTemperature)  Vis \(cw.visibility) ")
 let hourlyCount = wx.hourlyForecast.forecast.count
 print("\(wx.hourlyForecast.forecast.count) hourlyForecasts")
 let h0 = wx.hourlyForecast.forecast[0]
 print("First \(h0.date.ToString(fmd))ET \(h0.condition)  Temp \(h0.temperature)  FeelsLike \(h0.apparentTemperature)  Vis \(h0.visibility) ")
 let hx = wx.hourlyForecast.forecast[hourlyCount-1]
 print("Last  \(hx.date.ToString(fmd))ET \(hx.condition)  Temp \(hx.temperature)  FeelsLike \(hx.apparentTemperature)  Vis \(hx.visibility) ")
 }
 */

//MARK: - Other funcs

func strHasNoDigits( str: String) -> Bool {
    return str.allSatisfy { !$0.isNumber }
}

