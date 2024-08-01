//
//  FileHandler.swift
//  Garmitrk
//
//  Created by George Bauer on 11/15/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import Foundation

struct FileHandler {

    //MARK: - File handling

    //---- fileExists -
    ///Determine if a file exists
    /// - Parameter url: file URL
    /// - Returns:  true if exists
    static func fileExists(url: URL) -> Bool {
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        return fileExists
    }

    //---- DirectoryExists -
    ///Determine if a Directory exists
    /// - Parameter url: Directory URL
    /// - Returns:  true if exists
    static func directoryExists(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let dirExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return dirExists
    }

    static func shortenPathName(url: URL) -> String {
        var str = url.path
        let comps = str.components(separatedBy: "/")
        if comps[1] == "Users" {
            str = ""
            for i in 3..<comps.count {
                str += "/" + comps[i]
            }
        }
        return str
    }

    // Save Temporary File to one with newExtension, Optionally saving a backup file
    static func saveWithBak(tmpURL: URL, newExt: String, bakExt: String = "bak") -> Bool {
        let fileManager = FileManager()
        let newFileURL = tmpURL.deletingPathExtension().appendingPathExtension(newExt)
        let bakFileURL = tmpURL.deletingPathExtension().appendingPathExtension(bakExt)
        if fileManager.fileExists(atPath: newFileURL.path) {
            var response = MsgBoxs.Response.yes
            if !Gcc.isUnitTesting {
                response = MsgBoxs.yesNo(newFileURL.lastPathComponent + " already exists. Overwrite?")
            }
            if response == MsgBoxs.Response.yes {
                if !bakExt.isEmpty {
                    do {                // Do Overwrite
                        if !bakExt.isEmpty && fileManager.fileExists(atPath: bakFileURL.path) {
                            try FileHandler.deleteFile(url: bakFileURL, ext: bakExt)
                        }
                        if bakExt.isEmpty {
                            try deleteFile(url: newFileURL, ext: newExt)
                        } else {
                            try fileManager.moveItem(at: newFileURL, to: bakFileURL)
                        }
                    } catch let error {
                        let msg = "😡 FileHandler#\(#line) Could not delete \(bakFileURL.lastPathComponent))\n \(error.localizedDescription)"
                        print(msg)
                    }
                }
            } else {                // Don't Overwrite
                return false
            }//endif Overwrite or not
        }//endif file already exists

        do {    // Rename tempFilePath to newFilePath (".temp" to ".txt")
            try fileManager.moveItem(at: tmpURL, to: newFileURL)
        } catch {
            print("😡 FileHandler#\(#line) Could not rename \(tmpURL.lastPathComponent) to \(newFileURL.lastPathComponent)")
            print("😡 Error: \(error.localizedDescription)")
            return false
        }
        return true
    }//end func saveWithBak


    //------ getContentsOf(directoryURL:)
    ///Get URLs for Contents Of DirectoryURL
    /// - Parameter dirURL: DirectoryURL (URL)
    /// - Returns:  Array of URLs
    static func getContentsOf(dirURL: URL) -> [URL] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            return urls
        } catch {
            return []
        }
    }

    /// Replace one file extension with another
    ///
    /// - Parameters:
    ///   - url: old URL
    ///   - newExtension: new file extension
    /// - Returns: new URL
    static func changeExtension(url: URL, newExtension: String) -> URL {
        let bareURL = url.deletingPathExtension()
        let newURL = bareURL.appendingPathExtension(newExtension)
        return newURL
    }


    /// Read a Text file
    ///
    /// - Parameters:
    ///   - url: file URL
    /// - Returns: array of lines
    static func readFileLines(url: URL) -> [String] {
        var buffer = ""
        do {
            buffer = try String(contentsOf: url, encoding: .macOSRoman)
        } catch {
            return ([])        // Exit with error
        }
        buffer = buffer.replacingOccurrences(of: "\r", with: "")
        let lines = buffer.components(separatedBy: "\n")
        return lines
    }


    // ---------- Safely Delete a file ---------------
    static func deleteFile(url: URL, ext: String) throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        let fileExists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)

        if !fileExists {
            throw "Attempt to delete \(url.lastPathComponent), but it does not exist."
        }
        if isDirectory.boolValue {    // if url.hasDirectoryPath {
            throw "Attempt to delete a directory: (\(url.lastPathComponent))."
        }
        if ext.isEmpty {
            throw "Attempt to delete \(url.lastPathComponent), but no extension specified."
        }
        if url.pathExtension != ext {
            throw "Attempt to delete a file (\(url.lastPathComponent)), which does not match extension \(ext)"
        }

        // OK, Delete the damn file
        do {
            try fileManager.trashItem(at:url, resultingItemURL: nil)
        } catch let error {
            throw error.localizedDescription
        }
    }//end func

}//end struct FileHandler

/*
 ---- For each error type return the appropriate localized description ----
extension FileHandlerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .isDir:
            return NSLocalizedString("Attempt to modify a directory.", comment: "Directory")
        case .noExt:
            return NSLocalizedString("Attempt to modify a file with no extension.", comment: "No Extension")
        case .wrongExt:
            return NSLocalizedString("File extention does not match.", comment: "Extension Mismatch")
        }
    }
}//end extension CustomError


 enum FileHandlerError: LocalizedError {
    case noExt(fileName: String, ext: String)
 }
 extension FileHandlerError {
    public var errorDescription: String? {
        switch self {
        case let .wrongExt(fileName, ext):
            return "Error, fileName \(fileName) does not have extension \(ext)"
        }
    }
 }


 --- Delegate called by FileManager ---
 optional func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool

 --- Use trashItem rather than removeItem ---
 trashItem(at url: URL,resultingItemURL outResultingURL: AutoreleasingUnsafeMutablePointer<NSURL?>?) throws
 try fileManager.trashItem(at:bakFileURL, resultingItemURL: nil)

 --- Check for Directory ---
 url.hasDirectoryPath is only reliable for URLs created with the FileManager API, which ensures that the string path of a dictionary ends with a slash.

 For URLs created with custom literal string paths reading the resource value isDirectory is preferable.

 let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

 extension URL {
 var isDirectory: Bool {
 return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
 }
 }
 */

