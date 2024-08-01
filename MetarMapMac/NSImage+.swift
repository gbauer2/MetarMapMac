//
//  NSImage+.swift
//  Garmitrk
//
//  Created by Dustin Howell on 7/17/18.
//  Copyright © 2018-2021 GeorgeBauer. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
    func resize(wid: Int, hgt: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(wid), CGFloat(hgt))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, size.width, size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return newImage
//        return NSImage(data: newImage.tiffRepresentation!)!
    }
}
