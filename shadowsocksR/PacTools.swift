//
//  PacTools.swift
//  shadowsocksR
//
//  Created by 称一称 on 16/8/25.
//  Copyright © 2016年 yicheng. All rights reserved.
//

import Foundation

class PacMgr:NSObject{
    static let shared = PacMgr()

    let PACRulesDirPath = NSHomeDirectory() + "/.ShadowsocksR/"

    let PACUserRuleFilePath:String
    let PACFilePath:String
    let GFWListFilePath:String


    override init() {
        PACUserRuleFilePath = PACRulesDirPath + "user-rule.txt"
        PACFilePath = PACRulesDirPath + "gfwlist.js"
        GFWListFilePath = PACRulesDirPath + "gfwlist.txt"
        super.init()
    }

    func sync_pac(force:Bool=false)->NSData?{
        var needGenerate = false

        let fileMgr = NSFileManager.defaultManager()
        if !fileMgr.fileExistsAtPath(PACRulesDirPath) || !fileMgr.fileExistsAtPath(PACFilePath) {
            needGenerate = true
        }
        if needGenerate||force {
            return GeneratePACFile()
        }
        return nil
    }

    func GeneratePACFile() -> NSData? {
        let fileMgr = NSFileManager.defaultManager()
        // Maker the dir if rulesDirPath is not exesited.
        if !fileMgr.fileExistsAtPath(PACRulesDirPath) {
            try! fileMgr.createDirectoryAtPath(PACRulesDirPath, withIntermediateDirectories: true, attributes: nil)
        }

        // If gfwlist.txt is not exsited, copy from bundle
        if !fileMgr.fileExistsAtPath(GFWListFilePath) {
            let src = NSBundle.mainBundle().pathForResource("gfwlist", ofType: "txt")
            try! fileMgr.copyItemAtPath(src!, toPath: GFWListFilePath)
        }

        // If user-rule.txt is not exsited, copy from bundle
/*
        if !fileMgr.fileExistsAtPath(PACUserRuleFilePath) {
            let src = NSBundle.mainBundle().pathForResource("user-rule", ofType: "txt")
            try! fileMgr.copyItemAtPath(src!, toPath: PACUserRuleFilePath)
        }
*/

        let socks5Port = inf.shared.socket5_port

        do {
            let gfwlist = try String(contentsOfFile: GFWListFilePath, encoding: NSUTF8StringEncoding)
            if let data = NSData(base64EncodedString: gfwlist, options: .IgnoreUnknownCharacters) {
                let str = String(data: data, encoding: NSUTF8StringEncoding)
                var lines = str!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
/*
                do {
                    let userRuleStr = try String(contentsOfFile: PACUserRuleFilePath, encoding: NSUTF8StringEncoding)
                    let userRuleLines = userRuleStr.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

                    lines += userRuleLines
                } catch {
                    NSLog("Not found user-rule.txt")
                }
*/
                // Filter empty and comment lines
                lines = lines.filter({ (s: String) -> Bool in
                    if s.isEmpty {
                        return false
                    }
                    let c = s[s.startIndex]
                    if c == "!" || c == "[" {
                        return false
                    }
                    return true
                })

                do {
                    // rule lines to json array
                    let rulesJsonData: NSData
                        = try NSJSONSerialization.dataWithJSONObject(lines, options: .PrettyPrinted)
                    let rulesJsonStr = String(data: rulesJsonData, encoding: NSUTF8StringEncoding)

                    // Get raw pac js
                    let jsPath = NSBundle.mainBundle().URLForResource("abp", withExtension: "js")
                    let jsData = NSData(contentsOfURL: jsPath!)
                    var jsStr = String(data: jsData!, encoding: NSUTF8StringEncoding)

                    // Replace rules placeholder in pac js
                    jsStr = jsStr!.stringByReplacingOccurrencesOfString("__RULES__"
                        , withString: rulesJsonStr!)
                    // Replace __SOCKS5PORT__ palcholder in pac js
                    let result = jsStr!.stringByReplacingOccurrencesOfString("__SOCKS5PORT__"
                        , withString: "\(socks5Port)")

                    // Write the pac js to file.
                    let resData = result.dataUsingEncoding(NSUTF8StringEncoding)
                    try resData?.writeToFile(PACFilePath, options: .DataWritingAtomic)
                    print("1111")
                    return resData
                } catch {
                    NSLog("generate pac file fail")
                }
            }
            
        } catch {
            NSLog("Not found gfwlist.txt")
        }
        
        return nil
    }
}