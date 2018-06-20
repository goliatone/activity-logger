//
//  KeyloggerSession.swift
//  Keylogger
//
//  Created by Emiliano Burgos on 6/19/18.
//  Copyright © 2018 Skrew Everything. All rights reserved.
//

import Foundation

struct KeyloggerSession {
    
    let start: Date
    var end: Date
    
    let startTs: Int
    
    var applications: [ApplicationSession]
    
    //How many times do we switch between applications
    // this is actually applications.length
    var contextSwitch: Int
    
    var application: ApplicationSession
    var timer: Timer?
    
    init(timer: Timer?) {
        start = Date()
        end = start
        startTs =  Int(start.timeIntervalSince1970 * 1000)
        applications = []
        contextSwitch = 0
        application = ApplicationSession(name: "__nop__")
        self.timer = timer
    }
    
    /**
     * Session will switch application.
     * On first run, name might be undefined.
     */
    mutating func switchApplication(name: String) {
        application.end = Date()
        print("Swith application: \(application.name) count \(application.characters.count)")
        application = ApplicationSession(name: name)
        applications.append(application)
    }
    
    mutating func update(ch:Int) {
        application.addCharacter(ch: ch)
        timer?.invalidate()
    }
    
    
    
    /**
     * Helper function to see elapsed time.
     * This is just filler text, remove later, we are
     * trying to see if we can get some information
     * going on... ideally we could see now that there
     * would be something happening in the LED screen.
     * How can we emit events from the keylogger!?
     */
    func elapsedTime() -> Int {
        let s = Int(start.timeIntervalSince1970 * 1000)
        let e = Int(Date().timeIntervalSince1970 * 1000)
        return e - s
    }
}

struct ApplicationSession {
    
    let name: String
    let start: Date
    var end: Date
    var characters: [Int]
    
    init(name:String) {
        self.name = name.convertedToSlug() ?? "empty"
        start = Date()
        end = start
        characters = []
    }
    
    mutating func addCharacter(ch:Int) {
        characters.append(ch)
    }
}
