//
//  Utils.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import SwiftUI

@MainActor
public var maxWidth = UIScreen.main.bounds.width * 0.9

@MainActor
public func getWidthByPercent(percent: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.width * percent
}

@MainActor
public func getHeightByPercent(percent: CGFloat) -> CGFloat {
    return UIScreen.main.bounds.height * percent
}

private func deliverToMain(_ work: @escaping () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}
