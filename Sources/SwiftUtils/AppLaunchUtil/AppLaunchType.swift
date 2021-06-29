//
//  AppLaunchType.swift
//  ReptyShare
//
//  Created by Yugo Sugiyama on 2020/12/26.
//  Copyright © 2020 yugo.sugiyama. All rights reserved.
//

import UIKit

public enum AppKind: Equatable {
    case app(launchType: AppLaunchType)
    case appClip(launchType: AppLaunchType)

    public var launchType: AppLaunchType {
        switch self {
        case .app(let launchType): return launchType
        case .appClip(let launchType): return launchType
        }
    }

    public var isAppClip: Bool {
        switch self {
        case .appClip: return true
        default: return false
        }
    }

    public func launchTypeSwitched(launchType: AppLaunchType) -> AppKind {
        switch self {
        case .app:  return .app(launchType: launchType)
        case .appClip: return .appClip(launchType: launchType)
        }
    }
}

public enum AppLaunchType: Equatable {
    case normal
    case reactivate
    case onboarding
    case remoteNotification(notification: UNNotification)
    case localNotification(notification: UNNotification)
    case deepLink(URL: URL)
}
