//
//  Metar.swift
//  MetarMac101
//
//  Created by George Bauer on 2024-07-30.
//

import Foundation

struct Metar {
    let rawData:    String
    let ID:         String
    //let date:       Date
    let lat:        Double
    let lon:        Double
    var tempC:      Double = -999
    var dewPtC:     Double = -999
    var windDir:    Int = -1
    var windKt:     Int = -1
    var wGustKt:    Int = -1
    var visMi:      Double = -1
    var altim:      Double = 0

    var flightCat:  String = ""

    var errMsg      = ""


//    raw_text,station_id,observation_time,latitude,longitude,temp_c,dewpoint_c,wind_dir_degrees,wind_speed_kt,wind_gust_kt,visibility_statute_mi,altim_in_hg,sea_level_pressure_mb,corrected,auto,auto_station,maintenance_indicator_on,no_signal,lightning_sensor_off,freezing_rain_sensor_off,present_weather_sensor_off,wx_string,sky_cover,cloud_base_ft_agl,sky_cover,cloud_base_ft_agl,sky_cover,cloud_base_ft_agl,sky_cover,cloud_base_ft_agl,flight_category,three_hr_pressure_tendency_mb,maxT_c,minT_c,maxT24hr_c,minT24hr_c,precip_in,pcp3hr_in,pcp6hr_in,pcp24hr_in,snow_in,vert_vis_ft,metar_type,elevation_m
//    UWSG 261228Z 06009G15MPS 9000 -SHRA BKN035CB 20/10 Q1007 R08/CLRD70 NOSIG RMK QFE753/1004,

/*
 EKYT,2024-07-26T12:27:00Z,57.093,9.879,18,17,130,7,,4.35,29.70,,,TRUE,,,,,,,RA,OVC,1000,,,,,,,MVFR,,,,,,,,,,,,SPECI,2
  0 rawData,
  1 id,
  2 time,
  3 lat,
  4 lon,
  5 tempC,
  6 DP_c,
  7 windDir,
  8 kt,
  9 gust,
 10 vis,
 11 altim,
 12 pressure_mb,
 13 corrected,
 14 auto,
 15 auto_station,
 16 maintenance_indicator_on,
 17 no_signal,
 18 lightning_sensor_off,
 19 freezing_rain_sensor_off,
 20 present_weather_sensor_off,
 21 wx_string,
 22 sky_cover,
 23 cloud_base_ft_agl,
 24 sky_cover,
 25 cloud_base_ft_agl,
 26 sky_cover,
 27 cloud_base_ft_agl,
 28 sky_cover,
 29 cloud_base_ft_agl,
 30 flight_category,
 31 three_hr_pressure_tendency_mb,
 32 maxT_c,
 33 minT_c,
 34 maxT24hr_c,
 35 minT24hr_c,
 36 precip_in,
 37 pcp3hr_in,
 38 pcp6hr_in,
 39pcp24hr_in,
 40 snow_in,
 41 vert_vis_ft,
 42 metar_type,
 43 elevation_m
 */
    init(csvStr: String){
        let items = csvStr.components(separatedBy: ",")
        let itemCount = items.count
        if itemCount < 44 {
            errMsg = "Metar#\(#line) Only \(itemCount) items in METAR"
        }
        rawData = items[0]
        if itemCount < 5 {
            errMsg = "Metar#\(#line) Only \(itemCount) items in METAR"
            ID = "????"
            lat = -999
            lon = -999
            return
        }

        ID      = items[1]
        lat     = Double(items[3]) ?? -999
        lon     = Double(items[4]) ?? -999


        tempC   = Double(items[5]) ?? -999
        dewPtC  = Double(items[6]) ?? -999
        windDir = Int(items[7]) ?? -999
        windKt  = Int(items[9]) ?? -999
        wGustKt = Int(items[10]) ?? -999
        visMi   = Double(items[10]) ?? -999
        altim   = Double(items[11]) ?? -999

        flightCat   = items[30]
    }//init

}//Metar
