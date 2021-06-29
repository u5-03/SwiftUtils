//
//  File.swift
//  
//
//  Created by 杉山優悟 on 2021/06/28.
//

import Foundation

public protocol UtilsErrorProtocol: Error {
    var message: String { get }
}

public enum UtilsErrorConstants: UtilsErrorProtocol {
    case failToOpenLink
    case timeout

    public var message: String {
        switch self {
        case .failToOpenLink:
            return NSLocalizedString("error.invalide.link", comment: "")
        case .timeout:
            return NSLocalizedString("error.timeout", comment: "")
        }
    }
}
