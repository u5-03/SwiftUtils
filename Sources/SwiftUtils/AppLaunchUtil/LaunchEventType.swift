//
//  LaunchEventType.swift
//  
//
//  Created by Yugo Sugiyama on 2020/12/26.
//

import UIKit

public enum EventAppKind: Equatable {
    case app(event: LaunchEventType)
    case appClip(event: LaunchEventType)

    public var event: LaunchEventType {
        switch self {
        case .app(let event): return event
        case .appClip(let event): return event
        }
    }

    public var isAppClip: Bool {
        switch self {
        case .appClip: return true
        default: return false
        }
    }
}

public enum LaunchEventType: Equatable {
    case normal
    case notification(notification: UNNotification)
    case URL(URL: URL)
}
