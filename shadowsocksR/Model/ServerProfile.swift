//
//  ServerProfile.swift
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 16/6/6.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

import Cocoa



class ServerProfile: NSObject {
    var uuid: String
    
    var serverHost: String = ""
    var serverPort: uint16 = 8379
    var method:String = "aes-256-cfb"
    var password:String = ""
    var remark:String = ""


    var obfs:String = "plain"
    var obfspara:String = ""
    var protocols:String = "origin"

    override init() {
        uuid = NSUUID().UUIDString
    }
    
    init(uuid: String) {
        self.uuid = uuid
    }
    
    static func fromDictionary(data:[String:AnyObject]) -> ServerProfile {
        let cp = {
            (profile: ServerProfile) in
            profile.serverHost = data["ServerHost"] as! String
            profile.serverPort = (data["ServerPort"] as! NSNumber).unsignedShortValue
            profile.method = data["Method"] as! String
            profile.password = data["Password"] as! String

            profile.obfs = data["obfs"] as! String
            profile.protocols = data["protocol"] as! String

            if let remark = data["Remark"] {
                profile.remark = remark as! String
            }

            if let obfspara = data["obfspara"] {
                profile.obfspara = obfspara as! String
            }

        }
        
        if let id = data["Id"] as? String {
            let profile = ServerProfile(uuid: id)
            cp(profile)
            return profile
        } else {
            let profile = ServerProfile()
            cp(profile)
            return profile
        }
    }
    
    func toDictionary() -> [String:AnyObject] {
        var d = [String:AnyObject]()
        d["Id"] = uuid
        d["ServerHost"] = serverHost
        d["ServerPort"] = NSNumber(unsignedShort:serverPort)
        d["Method"] = method
        d["Password"] = password
        d["Remark"] = remark
        d["obfs"] = obfs
        d["protocol"] = protocols
        d["obfspara"] = obfspara
        return d
    }
    
    
    func isValid() -> Bool {
        func validateIpAddress(ipToValidate: String) -> Bool {
            
            var sin = sockaddr_in()
            var sin6 = sockaddr_in6()
            
            if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
                // IPv6 peer.
                return true
            }
            else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
                // IPv4 peer.
                return true
            }
            
            return false;
        }
        
        func validateDomainName(value: String) -> Bool {
            let validHostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
            
            if (value.rangeOfString(validHostnameRegex, options: .RegularExpressionSearch) != nil) {
                return true
            } else {
                return false
            }
        }
        
        if !(validateIpAddress(serverHost) || validateDomainName(serverHost)){
            return false
        }
        
        if password.isEmpty {
            return false
        }
        
        return true
    }

    func base64(string:String,url_safe:Bool=true)->String{

        var encode_str = string.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        if(url_safe){
            encode_str = encode_str.stringByReplacingOccurrencesOfString("+", withString: "-")
            encode_str = encode_str.stringByReplacingOccurrencesOfString("/", withString: "_")
            encode_str = encode_str.stringByReplacingOccurrencesOfString("=", withString: "");
        }
        return encode_str
    }
    
    func URL() -> NSURL? {
//        服务器:端口:协议:加密方式:混淆方式:base64（密码）？obfsparam= Base64(混淆参数)&remarks=Base64(备注)
        if obfs == "plain" && protocols == "origin"{
            let parts = "\(method):\(password)@\(serverHost):\(serverPort)"
            return NSURL(string: "ss://\(base64(parts,url_safe: false))")
        }
        let parts = "\(serverHost):\(serverPort):\(protocols):\(method):\(obfs):\(base64(password))?obfsparam=\(base64(obfspara))&remarks=\(base64(remark))"
            return NSURL(string: "ssr://\(base64(parts))")
    }
}
