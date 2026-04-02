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
    
    func setTokens(access: String, refresh: String, stream: String) async {
        KeychainHelper.shared.save(key: accessKey, value: access)
        KeychainHelper.shared.save(key: refreshKey, value: refresh)
        KeychainHelper.shared.save(key: streamKey, value: stream)
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
    
    func clear() async {
        KeychainHelper.shared.delete(key: accessKey)
        KeychainHelper.shared.delete(key: refreshKey)
        KeychainHelper.shared.delete(key: streamKey)
    }
}
