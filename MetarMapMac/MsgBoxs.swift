//
//  MsgBoxs.swift
//  Garmitrk
//
//  Created by George Bauer on 12/4/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import Cocoa

public struct MsgBoxs {

    public enum Response {
        case none
        case yes
        case no
        case ok
        case cancel
    }

    //---- alertOKCancel - OKCancel dialog box. Returns true if OK
    static func okCancel(_ question: String, text: String = "") -> Response {
        let alert = NSAlert()
        alert.messageText       = question
        alert.informativeText   = text
        alert.alertStyle        = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            return .ok
        } else {
            return .cancel
        }
    }

    //---- alertYesNo - YesNo dialog box. Returns true? if Yes
    static func yesNo(_ question: String, text: String = "") -> Response {
        let alert = NSAlert()
        alert.messageText       = question
        alert.informativeText   = text
        alert.alertStyle        = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let btn = alert.runModal()
        if btn == .alertFirstButtonReturn {
            return .yes
        } else if btn == .alertSecondButtonReturn {
            return .no
        } else {
            return .cancel
        }
    }

    //---- InputBox - returns text
    func inputBox(_ msg: String) -> String {
        let alert = NSAlert()
        alert.messageText = msg
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        let input = NSTextField(frame: NSMakeRect(0, 0, 60, 30))
        input.stringValue = ""
        input.font = NSFont(name: "HelveticaNeue-Bold", size: 16) ?? NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        alert.accessoryView = input
        //alert.accessoryView?.window!.makeFirstResponder(input)
        //self.view.window!.makeFirstResponder(input)               //????? How do I make "input" the FirstResponder
        //input.becomeFirstResponder()
        let button: NSApplication.ModalResponse = alert.runModal()
        alert.buttons[0].setAccessibilityLabel("InputBox OK")

        //input.becomeFirstResponder()
        if button == .alertFirstButtonReturn {
            let str = input.stringValue
            return str
        }
        return ""                               // anything else
    }

}//end  struct MsgBoxs
