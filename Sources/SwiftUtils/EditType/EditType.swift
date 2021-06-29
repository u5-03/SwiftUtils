//
//  EditType.swift
//  
//
//  Created by 杉山優悟 on 2021/02/02.
//

import Foundation

public enum EditType<T: Identifiable>: Identifiable where T.ID == String {
    case create
    case edit(data: T)

    public var id: T.ID {
        switch self {
        case .create: return UUID().uuidString
        case .edit(let data): return data.id
        }
    }

    public var isEdit: Bool {
        switch self {
        case .create: return false
        case .edit: return true
        }
    }

    public static func == (lhs: EditType<T>, rhs: EditType<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.edit(lhsData), .edit(rhsData)): return lhsData.id == rhsData.id
        case (.create, .create): return true
        default: return false
        }
    }
}
