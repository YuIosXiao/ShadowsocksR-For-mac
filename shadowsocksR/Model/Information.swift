//
//  Information.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/24.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Foundation


enum ProxyModes:Int {
    case Gfwlist = 0
    case Bypasschina = 1
    case Global = 2
    case Manual = 3
}

class inf {
    static let shared = inf()

    init() {
        let x = NSUserDefaults.standardUserDefaults()

        if let xx = x.objectForKey("isOn") as? Bool {isOn = xx}else {isOn = false }
        if let xx = x.objectForKey("ProxyModes") as? Int {ProxyMode = ProxyModes(rawValue: xx)!}else { ProxyMode = .Gfwlist }
        if (x.objectForKey("LocalSocks5.ListenPort") as? Int) == nil {socket5_port = 1090 }
        if (x.objectForKey("HttpServer.ListenPort") as? Int) == nil {httpServer_port = 1091 }


    }

    var isOn:Bool
    var ProxyMode:ProxyModes = .Gfwlist
    var socket5_port:Int{
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "LocalSocks5.ListenPort")
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("LocalSocks5.ListenPort")
        }
    }

    var httpServer_port:Int{
        set{
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "HttpServer.ListenPort")
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("HttpServer.ListenPort")
        }
    }


    func save(){
        let x = NSUserDefaults.standardUserDefaults()
        x.setBool(isOn, forKey: "isON")
        x.setObject(ProxyMode.rawValue, forKey: "ProxyModes")
    }
}