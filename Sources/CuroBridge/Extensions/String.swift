//
//  OtherExtensions.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 07/04/25.
//

import Foundation

public extension String {
    func starts(withHexPrefix prefix: String) -> Bool {
        guard let range = self.range(of: prefix, options: .caseInsensitive) else {
            return false
        }
        return range.lowerBound == self.startIndex
    }
    
    func toData() -> Data {
        self.data(using: .utf8)!
    }
}
