//
//  ServiceHandler.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/24.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Foundation
import GCDWebServer


class ServiceHandler:NSObject{
    static let instance:ServiceHandler = ServiceHandler()

    let proxyMgr = ProxyManager.sharedManager()
    var ss_exit_lock:NSCondition = NSCondition()
    let webServer = GCDWebServer()


    func start_ss(){
        NSThread.detachNewThreadSelector(#selector(ServiceHandler.ss_run_on_therad), toTarget: self, withObject: nil)
    }

    func stop_ss(){
        ss_exit_lock.signal()
    }

    func sync_ss(){
        stop_ss()
        if inf.shared.isOn{
            start_ss()
        }
    }

    func ss_run_on_therad(){
        NSLog("start shadowsock on thread \(NSThread.currentThread().description)")
        ss_exit_lock.lock()

        proxyMgr.startShadowsocks { (port, error) in
            if error != nil{
                print(error.description)
                self.stop_ss()
                self.ss_exit_lock.unlock()
                return
            }
            print(port)
            self.ss_exit_lock.wait()
            self.ss_exit_lock.unlock()
            NSLog("stop shadowsock on thread \(NSThread.currentThread().description)")
            NSThread.exit()
        }
    }

    func start_pac_server(forceReloadPac:Bool=false){
        stop_pac_server()

        let pacData:NSData!
        if let x = PacMgr.shared.sync_pac(forceReloadPac){
            pacData = x.copy() as! NSData
        }else{
            let file = PacMgr.shared.PACFilePath
            pacData = NSData(contentsOfFile: file)
        }
        
        GCDWebServer.setLogLevel(4)

        webServer.addHandlerForMethod("GET",path: "/pac", requestClass: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(data: pacData, contentType: "application/x-ns-proxy-autoconfig")
        })
        do {
            try webServer.runWithOptions(["BindToLocalhost":true,"Port":1091])
            NSLog("pac Http Server Started")
        }catch{
            NSLog("Start pac Http Server Fail")
        }
    }

    func stop_pac_server(){
        NSLog("pac Http Server is not running!")
        if webServer.running{
            NSLog("pac Http Server Stopped")
            webServer.stop()
        }

    }

}