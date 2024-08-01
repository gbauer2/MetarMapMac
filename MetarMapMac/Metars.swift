//
//  Metars.swift
//  MetarMac101
//
//  Created by George Bauer on 2024-07-30.
//

import Foundation

struct Metars {
    let cMeterToFeet = 3.28084
    let cMetersToNM  = 0.000539957

    var fileURL     = URL(fileURLWithPath: "Missing URL")
    var fileDate    = Date.distantPast
    var all         = [Metar]()
    var dictByID    = [String: Metar]()
    var errStr      = ""
    var lineErrs    = [String]()
    var fileName: String { fileURL.lastPathComponent }
    var count: Int { all.count }
    

    init(url: URL) {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: url.path) {
            print("⛔️ Metars#\(#line) \(url.path) does not exist.")
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

        for (idx, line) in sourceLines.enumerated() {
            if line.isEmpty { continue }
            if idx < 7      { continue }
            let items = line.components(separatedBy: ",")
            if items.count < 8 {
                lineErrs.append("<8 items in line #\(lineErrs.count) \(line)")
                errStr = "\(lineErrs.count) line errors"
                continue
            }
            let metar = Metar(csvStr: line)
            all.append(metar)
        }

    }//init



}//struct Metars
