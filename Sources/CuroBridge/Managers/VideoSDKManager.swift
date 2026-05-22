//
//  VideoSDKManager.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 01/04/26.
//

import StreamVideo
import SwiftUI
import Combine
import StreamVideoSwiftUI

@MainActor
public final class VideoSDKManager: ObservableObject {
    public static let shared = VideoSDKManager()
    @Published public var isSDKReady = false
    
    private var streamVideoClient: StreamVideo?
    var callViewModel: CallViewModel?
    
    private let apiKey: String = "8knaahus73v8"
    
    public func getStreamToken() async throws -> UserToken {
        let response = try await APIClient.shared.send(GetstreamTokenRequest())
        return UserToken(rawValue: response.streamToken)
    }
    
    public func getStreamVideoClient() async throws -> StreamVideo {
        guard let streamVideoClient = streamVideoClient else { throw NSError(domain: "No stream video client", code: 0, userInfo: nil) }
        
        return streamVideoClient
    }
    
    public func getCallViewModel() -> CallViewModel {
        if let callViewModel {
            return callViewModel
        }
        guard streamVideoClient != nil else {
            fatalError("Stream Video client not configured. Call setupGetstreamVideoClient first.")
        }
        let viewModel = CallViewModel()
        callViewModel = viewModel
        return viewModel
    }
    
    /// Restores the Stream client from keychain credentials so CallKit can handle VoIP pushes on cold start.
    @discardableResult
    public func restoreSessionForIncomingCalls() async -> Bool {
        guard streamVideoClient == nil else { return true }
        guard
            let streamToken = await TokenStore.shared.getStreamToken(),
            let curoUser = await TokenStore.shared.getUser()
        else {
            return false
        }
        await configureStreamVideoClient(curoUser: curoUser, streamToken: streamToken)
        return streamVideoClient != nil
    }
    
    public func setupGetstreamVideoClient(curoUser: CuroUser) async {
        guard streamVideoClient == nil else { return }
        guard let streamToken = await TokenStore.shared.getStreamToken() else { return }
        await configureStreamVideoClient(curoUser: curoUser, streamToken: streamToken)
    }
    
    private func configureStreamVideoClient(curoUser: CuroUser, streamToken: String) async {
        
        let newVideoClient = StreamVideo(
            apiKey: apiKey,
            user: User(
                id: curoUser.id,
                name: curoUser.name,
                imageURL: .init(string: curoUser.profilePic ?? "")
            ),
            token: .init(stringLiteral: streamToken),
            pushNotificationsConfig: PushNotificationsConfig(
                pushProviderInfo: PushProviderInfo(name: "curotel-patients", pushProvider: .apn),
                voipPushProviderInfo: PushProviderInfo(name: "curotel-patients", pushProvider: .apn)
            ),
            tokenProvider: { [weak self] result in
                Task {
                    do {
                        guard let self else { return }
                        let token = try await self.getStreamToken()
                        result(.success(token))
                    } catch {
                        print("Stream token error:", error)
                        result(.failure(error))
                    }
                }
            },
        )
        self.streamVideoClient = newVideoClient
        self.callViewModel = CallViewModel()

        Task {
            for await clientEvent in newVideoClient.subscribe() {
                switch clientEvent {
                case .typeHealthCheckEvent(let check):
                    print("Client event: health", check.type)
                case .typeConnectedEvent( _):
                    self.isSDKReady = true
                default:
                    print("Client event", clientEvent.type, clientEvent.rawValue)
                }
            }
        }
    }
    
    public func startCalling(callType: String, callId: String, remoteUser: User) {
        getCallViewModel().startCall(callType: callType, callId: callId, members: [
            Member(user: remoteUser)
        ], ring: true)
    }
    
    public func joinCall(callType: String, callId: String) {
        getCallViewModel().joinCall(callType: callType, callId: callId)
    }
    
    public func endCall(call: Call) {
        Task {
            try await getCallViewModel().call?.end()
        }
    }
    
    public func resetSession() {
        streamVideoClient = nil
        callViewModel = nil
        isSDKReady = false
    }
}

//public extension VideoSDKManager {
//    public func setDeviceTokens(push: String, voip: String) async throws {
//        try await streamVideoClient?.setDevice(id: push)
//        try await streamVideoClient?.setVoipDevice(id: voip)
//    }
//    
//    public func setVideoTokenRequest(device: String, voip: String) async {
//        do {
//            let _ = try await APIClient.shared.send(
//                SetDeviceTokenRequest(request: SetDeviceTokenRequestBody(voipToken: voip, provider: "apn", providerName: "curotel-patients"))
//            )
//        } catch {
//            print("setVideoTokenRequest error:", error)
//        }
//    }
//}
