//
//  APS+Fire+Signal.swift
//  
//
//  Created by Tehnichka on 17.11.2025.
//

import DeviceKit
import AdServices
import UIKit
import Foundation
import AppsFlyerLib


class LinkBuilderSKAKGRAY {
    var finalURL: String?
    
    private var apple_id: String?
    private var afid: String?
    private var fcmtoken: String?
    private var afattr: String?
    private var lng: String
    private var firsttime: Int
    private var iuid: String?
    private var device_model: String
    private var os_ver: String
    
    // MARK: - INIT (автоматично отримує всі параметри)
    init(
        afAttribution: [AnyHashable: Any]? = nil,
        fbDeepLink: String? = nil,
        ip: String? = nil
    ) {
        self.apple_id = ConstantSKAKGRAY.appID
        self.afid = AppsFlyerLib.shared().getAppsFlyerUID()
        self.fcmtoken = UserDefaults.standard.string(forKey: "apnToken")
        self.afattr =  UserDefaults.standard.string(forKey: "AFAttr")
        self.lng = Self.getDeviceLanguage()
        self.firsttime = Self.getFirstInstallTime()
        self.iuid = Self.getInternalUUID()
        self.device_model = Self.getDeviceModel()
        self.os_ver = Self.getOSVersion()
        
        print("Final link: " + buildFinalLink(baseURL: ConstantSKAKGRAY.grayLink))
        
        fetchFinalLink(from: buildFinalLink(baseURL: ConstantSKAKGRAY.grayLink)) { link in
            self.finalURL = link
        }
    }
    
    func fetchFinalLink(from urlString: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: urlString) else {
            GrayLogic(grayLink: "error")
            completion("error")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                GrayLogic(grayLink: "error")
                completion("error")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let link = json["url"] as? String, !link.isEmpty {
                    GrayLogic(grayLink: link)
                    completion(link)
                } else {
                    print("❌ JSON parsing error: key 'link' missing or empty")
                    GrayLogic(grayLink: "error")
                    completion("error")
                }
            } catch {
                print("❌ JSON decode exception: \(error.localizedDescription)")
                GrayLogic(grayLink: "error")
                completion("error")
            }
        }
        
        task.resume()
    }
}

extension LinkBuilderSKAKGRAY {
    
    func buildFinalLink(baseURL: String) -> String {
        guard var components = URLComponents(string: baseURL) else {
            return baseURL
        }
        
        var query: [URLQueryItem] = []
        
        func add(_ key: String, _ value: String?) {
            guard let v = value, !v.isEmpty else { return }
            query.append(URLQueryItem(name: key, value: v))
        }
        
        add("apple_id", apple_id)
        add("afid", afid)
        add("fcmtoken", fcmtoken)
        add("afattr", afattr)
        add("lng", lng)
        add("firsttime", "\(firsttime)")
        add("iuid", iuid)
        add("device_model", device_model)
        add("os_ver", os_ver)

        components.queryItems = query
        
        return components.url?.absoluteString ?? baseURL
    }
}

extension LinkBuilderSKAKGRAY {
    static func getInternalUUID() -> String {
        let key = "internal_iuid"
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        let u = UUID().uuidString.lowercased()
        UserDefaults.standard.set(u, forKey: key)
        return u
    }
    
    
    static func getDeviceLanguage() -> String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    static func getFirstInstallTime() -> Int {
        let key = "app_first_install_unix"
        let ud = UserDefaults.standard
        
        if let v = ud.object(forKey: key) as? Int { return v }
        
        let now = Int(Date().timeIntervalSince1970)
        ud.set(now, forKey: key)
        return now
    }
    
    static func getDeviceModel() -> String {
        Device.current.description
    }
    
    static func getOSVersion() -> String {
        UIDevice.current.systemVersion
    }
    
    static func fetchBase64Token() -> String? {
        guard #available(iOS 14.3, *) else { return nil }
        do {
            let token = try AAAttribution.attributionToken()
            return token.data(using: .utf8)?.base64EncodedString()
        } catch {
            return nil
        }
    }
}
