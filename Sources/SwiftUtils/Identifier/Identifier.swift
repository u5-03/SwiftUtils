//
//  Identifier.swift
//  
//
//  Created by Yugo Sugiyama on 2020/12/28.
//

import Foundation

public struct Identifier<T, RawValue> where RawValue: Equatable {
    public let value: RawValue
    public init(_ value: RawValue) {
        self.value = value
    }
}

extension Identifier: Equatable {
    public static func == (lhs: Identifier<T, RawValue>, rhs: Identifier<T, RawValue>) -> Bool {
        lhs.value == rhs.value
    }
}
