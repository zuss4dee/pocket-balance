//
//  AppConfig.swift
//  Pocket Balance
//
//  Secure configuration for app credentials
//

import Foundation

struct AppConfig {
    // MARK: - Supabase Configuration
    static let supabaseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String else {
            fatalError("SUPABASE_URL not found in Info.plist")
        }
        return url
    }()
    
    static let supabaseAnonKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY not found in Info.plist")
        }
        return key
    }()
    
    static let supabaseServiceRoleKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_SERVICE_ROLE_KEY") as? String else {
            fatalError("SUPABASE_SERVICE_ROLE_KEY not found in Info.plist")
        }
        return key
    }()
    
    // MARK: - Google Sign-In Configuration
    static let googleClientID: String = {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("GoogleService-Info.plist not found or CLIENT_ID missing")
        }
        return clientId
    }()
}
