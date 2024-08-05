//
//  DecompressGZip.swift
//  MetarMapMac
//
//  Created by George Bauer on 2024-08-04.
//

import Foundation
import Compression

func decompressGzipFile(at sourceURL: URL, to destinationURL: URL) {
    let codeFile = "DecompressGZip"

    let bufferSize = 32_768

    // Open the source file for reading
    guard let sourceFile = try? FileHandle(forReadingFrom: sourceURL) else {
        print("⛔️ \(codeFile)#\(#line) Failed to open source file")
        return
    }

    // Open the destination file for writing
    guard FileManager.default.createFile(atPath: destinationURL.path, contents: nil, attributes: nil),
          let destinationFile = try? FileHandle(forWritingTo: destinationURL) else {
        print("⛔️ \(codeFile)#\(#line) Failed to create destination file")
        return
    }

    defer {
        sourceFile.closeFile()
        destinationFile.closeFile()
    }

    // Setup the compression stream
    var stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
    var status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
    guard status != COMPRESSION_STATUS_ERROR else {
        print("⛔️ \(codeFile)#\(#line) Failed to initialize compression stream")
        return
    }
    defer {
        compression_stream_destroy(&stream)
    }

    let sourceBuffer      = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer {
        sourceBuffer.deallocate()
        destinationBuffer.deallocate()
    }

    // Read from the source file and write to the destination file
    while true {
//        let bytesRead = sourceFile.read(into: sourceBuffer, maxLength: bufferSize) // Creates Errors
        let data =  try! sourceFile.read(upToCount: bufferSize) //GB
        guard let data = data else{
            print("⛔️ \(codeFile)#\(#line) data is nil!!!")
            return
        }
     
        data.withUnsafeBytes { (unsafePointer: UnsafeRawBufferPointer) in
            if let baseAddress = unsafePointer.baseAddress {
                let unsafePointer = baseAddress.assumingMemoryBound(to: UInt8.self)
            }
        }
        let bytesRead = data.count      //GB
        if bytesRead == 0 {
            break                       // We're Done
        }

        stream.src_ptr  = UnsafePointer<UInt8>(sourceBuffer)
        stream.src_size = bytesRead
        stream.dst_ptr  = destinationBuffer
        stream.dst_size = bufferSize

        repeat {
            status = compression_stream_process(&stream, 0)
            switch status {
            case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                let bytesWritten = bufferSize - stream.dst_size
                destinationFile.write(Data(bytesNoCopy: destinationBuffer, count: bytesWritten, deallocator: .none))
                stream.dst_ptr = destinationBuffer
                stream.dst_size = bufferSize
            case COMPRESSION_STATUS_ERROR:
                print("Compression error")
                return
            default:
                break
            }
        } while stream.src_size > 0

    }//loop

    print("🤣 \(codeFile)#\(#line) Decompression completed successfully.")
}

func sampleDecompress() {
    let codeFile = "DecompressGZip"

    // Example usage
    let fileManager = FileManager.default

    guard let downloadURL = try? fileManager.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
        fatalError("⛔️ \(codeFile)#\(#line) Unable to access document directory.")
    }

    let sourceURL      = downloadURL.appendingPathComponent("metar.gz")
    let destinationURL = downloadURL.appendingPathComponent("metar.txt")

    decompressGzipFile(at: sourceURL, to: destinationURL)

}
