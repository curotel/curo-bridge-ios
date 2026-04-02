//
//  KeychainManager.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 27/03/26.
//

import Foundation
import Security

@MainActor
public final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func save(key: String, value: String) {
        let data = Data(value.utf8)
        
        // Remove existing item first
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
