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
    
    public func getStreamVideoClient() throws -> StreamVideo {
        guard let streamVideoClient = streamVideoClient else { throw NSError(domain: "No stream video client", code: 0, userInfo: nil) }

        return streamVideoClient
    }
    
    public func getCallViewModel() -> CallViewModel {
        if callViewModel == nil {
            print("Call view model is nil. Starting a new one.")
            callViewModel = CallViewModel()
        }
        return callViewModel!
    }

    public func setupGetstreamVideoClient(curoUser: CuroUser) async {
//        guard let curoUser = Router.appState.currentUser else { return }
        guard let streamToken = await TokenStore.shared.getStreamToken() else { return }
        
        let newVideoClient = StreamVideo(
            apiKey: apiKey,
            user: User(
                id: curoUser.id,
                name: curoUser.name,
                imageURL: .init(string: curoUser.profilePic ?? "")
            ),
            token: .init(stringLiteral: streamToken),
            pushNotificationsConfig: PushNotificationsConfig(
                pushProviderInfo: PushProviderInfo(name: "apn", pushProvider: .apn),
                voipPushProviderInfo: PushProviderInfo(name: "voip", pushProvider: .apn)
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
        self.callViewModel = .init()
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
}
