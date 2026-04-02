//
//  AuthManager.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 27/03/26.
//

import Foundation

public protocol AuthManagerDelegate {
    func tokenResponseSaved(user: CuroUser, isLoggedIn: Bool)
    func logoutUser()
}

@MainActor
public final class AuthManager {
    public static let shared = AuthManager()
    init() { }
    
    public var delegate: AuthManagerDelegate?
    private var isRefreshing = false
    
    func getValidAccessToken() async throws -> String? {
        return await TokenStore.shared.getAccessToken()
    }
    
    public func refreshTokenIfNeeded() async throws -> String {
        if isRefreshing {
            try await Task.sleep(nanoseconds: 500_000_000)
            return await TokenStore.shared.getAccessToken() ?? ""
        }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        guard let refreshToken = await TokenStore.shared.getRefreshToken() else {
            throw NetworkError.unauthorized
        }
        
        // Call refresh API
        let response = try await APIClient.shared.send(
            RefreshTokenRequest(request: RefreshTokenRequestBody(refresh: refreshToken))
        )
        
        await saveTokenResponse(access: response.accessToken, refresh: response.refresh, stream: response.streamToken, user: response.user)
        
        return response.accessToken
    }
    
    public func saveTokenResponse(access: String, refresh: String, stream: String, user: CuroUser) async {
        await TokenStore.shared.setTokens(
            access: access,
            refresh: refresh,
            stream: stream
        )
        
        delegate?.tokenResponseSaved(user: user, isLoggedIn: true)
//        Router.appState.currentUser = user
//        Router.appState.isLoggedIn = true
    }
    
    public func handleLogout() async {
        await TokenStore.shared.clear()
        delegate?.logoutUser()
        
//        DispatchQueue.main.async {
//            Router.appState.currentUser = nil
//            Router.appState.isLoggedIn = false
//            
//            Router.shared.reset(to: .welcome)
//        }
    }
}
