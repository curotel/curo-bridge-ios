//
//  AnyEncodable.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 27/03/26.
//

import Foundation

public struct AnyEncodable: Encodable {
    private let encodeFunc: @Sendable (Encoder) throws -> Void
    
    public init<T: Encodable & Sendable>(_ value: T) {
        self.encodeFunc = value.encode
    }
    
    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
