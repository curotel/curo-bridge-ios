//
//  Image.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import SwiftUI

public extension Image {
    public init(_ asset: IconAsset) {
        self.init(asset.rawValue, bundle: .module)
    }
    
    public init(_ asset: ImageAsset) {
        self.init(asset.rawValue, bundle: .module)
    }
}
