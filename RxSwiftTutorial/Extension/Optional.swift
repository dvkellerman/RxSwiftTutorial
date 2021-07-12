//
//  Optional.swift
//  RxSwiftTutorial
//
//  Created by Dmitry Keller on 12.07.2021.
//

import Foundation

public extension Swift.Optional {
    func take(_ action:(Wrapped)->()) {
        switch self {
        case .some(let wrappedValue) : action(wrappedValue)
        case .none: break
        }
    }
}
