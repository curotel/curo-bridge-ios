//
//  MJPEGStreamManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 12/04/26.
//

import SwiftUI
import Combine

@MainActor
public final class MJPEGStreamManager: NSObject, ObservableObject {

    public static let shared = MJPEGStreamManager()

    @Published public var image: UIImage?
    @Published public var isLoading: Bool = false

    private var buffer = Data()
    private var session: URLSession!
    private var dataTask: URLSessionDataTask?

    private override init() {
        super.init()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )
    }

    // MARK: - Start

    public func start(
        url: URL,
        headers: [String: String] = [:]
    ) {
        stop()

        isLoading = true
        buffer.removeAll()

        var request = URLRequest(url: url)
        request.timeoutInterval = .infinity

        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }

    // MARK: - Stop

    public func stop() {
        dataTask?.cancel()
        dataTask = nil
        buffer.removeAll()
    }

    // MARK: - Restart

    public func restart(
        url: URL,
        headers: [String: String] = [:]
    ) {
        stop()
        start(url: url, headers: headers)
    }

    // MARK: - Frame Extraction

    private func extractFrames() {
        while true {

            guard let start = buffer.range(of: Data([0xFF, 0xD8])),
                  let end = buffer.range(
                    of: Data([0xFF, 0xD9]),
                    in: start.lowerBound..<buffer.endIndex
                  ),
                  end.upperBound <= buffer.endIndex
            else { return }

            let frameData = Data(buffer[start.lowerBound..<end.upperBound])
            buffer.removeSubrange(..<end.upperBound)

            if let img = UIImage(data: frameData) {
                self.image = img
                self.isLoading = false
            }
        }
    }
}

// MARK: - URLSession Delegate

extension MJPEGStreamManager: URLSessionDataDelegate {

    nonisolated public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        Task { @MainActor in
            buffer.append(data)
            extractFrames()
        }
    }
}
