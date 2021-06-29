//
//  AppLaunchUtil.swift
//  
//
//  Created by Yugo Sugiyama on 2020/12/26.
//

import UIKit

public final class AppLaunchUtil {
    public static let shared = AppLaunchUtil()
    private init() {}

    public func parseEvent(kind: EventAppKind) -> AppKind {
        let launchType: AppLaunchType
        switch kind.event {
        case .normal: launchType = .normal
        case .notification(let notification):
            if notification.request.trigger is UNPushNotificationTrigger {
                launchType = .remoteNotification(notification: notification)
            } else if notification.request.trigger is UNLocationNotificationTrigger {
                launchType = .localNotification(notification: notification)
            } else {
                launchType = .normal
            }
        case .URL(let URL):
            launchType = .deepLink(URL: URL)
        }
        switch kind {
        case .app: return .app(launchType: launchType)
        case .appClip: return .appClip(launchType: launchType)
        }
    }

    public func handleLaunch(launchType: AppLaunchType) {
//        switch launchType {
//        case .normal: break
//        case .reactivate: break
//        case .onboarding: showAccountNavigation()
//        case .remoteNotification(let notification):
//        case .localNotification(let notification):
//        case .deepLink(let URL):
//        }
    }

    public func isLaunchByNormalLaunch(launchOption: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let launchOption = launchOption else { return true }
        if isLaunchedByRemoteNotification(launchOptions: launchOption) || isLaunchedByURLScheme(launchOptions: launchOption) {
            return false
        } else {
            return true
        }
    }

    public func isLaunchedByRemoteNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let launchOptions = launchOptions else { return false }
        return launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] != nil
    }

    public func isLaunchedByURLScheme(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let launchOptions = launchOptions else { return false }
        return launchOptions[UIApplication.LaunchOptionsKey.url] != nil
    }
}
