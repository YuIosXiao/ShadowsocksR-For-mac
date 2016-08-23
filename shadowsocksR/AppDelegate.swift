//
//  AppDelegate.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/23.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func buttonTap(sender: AnyObject) {
        print("1111")
        let handler = ProxyManager.sharedManager()
        handler.startShadowsocks { (g, error) in
            print("2222")

        }
    }

    func start_SS_local(){
        
    }

}

