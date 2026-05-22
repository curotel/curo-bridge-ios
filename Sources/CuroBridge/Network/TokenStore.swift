//
//  TokenStore.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

@MainActor
public final class TokenStore {
    static let shared = TokenStore()
    
    private init() {}
    
    private let accessKey = "access_token"
    private let refreshKey = "refresh_token"
    private let streamKey = "stream_token"
    private let userKey = "curo_user"
    
    func setTokens(access: String, refresh: String, stream: String, user: CuroUser) async {
        KeychainHelper.shared.save(key: accessKey, value: access)
        KeychainHelper.shared.save(key: refreshKey, value: refresh)
        KeychainHelper.shared.save(key: streamKey, value: stream)
        if let userData = try? JSONEncoder().encode(user) {
            KeychainHelper.shared.save(key: userKey, value: userData.base64EncodedString())
        }
    }
    
    func getAccessToken() async -> String? {
        KeychainHelper.shared.read(key: accessKey)
    }
    
    func getRefreshToken() async -> String? {
        KeychainHelper.shared.read(key: refreshKey)
    }
    
    func getStreamToken() async -> String? {
        KeychainHelper.shared.read(key: streamKey)
    }
    
    func getUser() async -> CuroUser? {
        guard
            let encoded = KeychainHelper.shared.read(key: userKey),
            let data = Data(base64Encoded: encoded),
            let user = try? JSONDecoder().decode(CuroUser.self, from: data)
        else {
            return nil
        }
        return user
    }
    
    func clear() async {
        KeychainHelper.shared.delete(key: accessKey)
        KeychainHelper.shared.delete(key: refreshKey)
        KeychainHelper.shared.delete(key: streamKey)
        KeychainHelper.shared.delete(key: userKey)
    }
}
