//
//  ServiceHandler.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/24.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Foundation

class ServiceHandler:NSObject{
    static let instance:ServiceHandler = ServiceHandler()

    let proxyMgr = ProxyManager.sharedManager()
    var ss_exit_lock:NSCondition = NSCondition()

    func start_ss(){
        NSThread.detachNewThreadSelector(#selector(ServiceHandler.ss_run_on_therad), toTarget: self, withObject: nil)

    }

    func stop_ss(){
        ss_exit_lock.signal()
        print("signal")
    }

    func ss_run_on_therad(){
        print("start")
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
            NSThread.exit()
        }
    }

}