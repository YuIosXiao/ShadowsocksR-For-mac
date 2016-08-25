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
    var ss_thread:NSThread? = nil


    func start_ss(){
        ss_thread = NSThread(target: self, selector: #selector(ServiceHandler.ss_run_on_therad), object: nil)
        ss_thread?.start()

    }

    func stop_ss(){
//  how? exit?
    }



    func sync_ss(){
        stop_ss()
        ServiceHandler.instance.sync_proxy_mode()
        if inf.shared.isOn{
            start_ss()
        }
        
    }

    func ss_run_on_therad(){
        NSLog("start shadowsock on thread \(NSThread.currentThread().description)")

        proxyMgr.startShadowsocks { (port, error) in
            if error != nil{
                print(error.description)
                self.stop_ss()
                self.ss_exit_lock.unlock()
                return
            }
            print(port)

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
            try webServer.startWithOptions(["BindToLocalhost":true,"Port":1091])
            NSLog("pac Httfp Server Started")
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

    func sync_proxy_mode(){
        stop_pac_server()
        if !inf.shared.isOn{return}
        switch inf.shared.ProxyMode {
        case .Gfwlist:
            start_pac_server()
            ProxyConfHelper.enablePACProxy()
        case .Global:
            ProxyConfHelper.enableGlobalProxy()
        case .Manual:
            ProxyConfHelper.disableProxy()
        default:
            break
        }
    }

}