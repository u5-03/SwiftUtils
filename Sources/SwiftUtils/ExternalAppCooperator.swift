//
//  ExternalAppCooperator.swift
//  
//
//  Created by 杉山優悟 on 2021/01/02.
//

import UIKit
import EventKit

public enum AppActionType {
    case link(URL: URL)
    case addEventToCalendars(title: String, startDate: Date, endDate: Date, isAllDay: Bool)
    case openMap(address: String)
    case openAppSetting

    public var URL: URL? {
        switch self {
        case .link(let URL): return URL
        case .addEventToCalendars: return nil
        case .openMap(let address):
            guard let escapedAddress = address.percentEscaped else { return nil }
            return Foundation.URL(string: "http://maps.apple.com/?address=\(escapedAddress)")
        case .openAppSetting:
            return Foundation.URL(string: UIApplication.openSettingsURLString)
        }
    }
}

public final class ExternalAppCooperator {
    public static func open(type: AppActionType, completion: ((Result<Void, Error>) -> Void)? = nil) {
        switch type {
        case .link, .openMap, .openAppSetting:
            guard let URL = type.URL else { return }
            if UIApplication.shared.canOpenURL(URL) {
                UIApplication.shared.open(URL, options: [:]) { completed in
                    if completed {
                        completion?(.success(()))
                    } else {
                        completion?(.failure(UtilsErrorConstants.failToOpenLink))
                    }
                }
            } else {
                if UIApplication.shared.canOpenURL(URL) {
                    UIApplication.shared.open(URL, options: [:]) { completed in
                        if completed {
                            completion?(.success(()))
                        } else {
                            completion?(.failure(UtilsErrorConstants.failToOpenLink))
                        }
                    }
                } else {
                    completion?(.failure(UtilsErrorConstants.failToOpenLink))
                }
            }
        case .addEventToCalendars(let title, let startDate, let endDate, let isAllDay):
            switch EKEventStore.authorizationStatus(for: .event) {
            case .notDetermined, .denied, .restricted:
                let eventStore = EKEventStore()
                eventStore.requestAccess(to: .event) { (granted, error) in
                    if granted {
                        saveEventToCalendar(title: title, startDate: startDate, endDate: endDate, isAllDay: isAllDay, completion: completion)
                    } else {
                        let title = String(format: NSLocalizedString("hello", comment: ""), arguments: [NSLocalizedString("privacy.function.calendar", comment: "")])
                        askPermission(title: title)
                    }
                }
            case .authorized:
                saveEventToCalendar(title: title, startDate: startDate, endDate: endDate, isAllDay: isAllDay, completion: completion)
            @unknown default: break
            }
        }
    }

    private static func askPermission(title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                .addAction(title: NSLocalizedString("common.open.setting.app", comment: ""), style: .default) { _ in
                    ExternalAppCooperator.open(type: .openAppSetting)
                }
                .addAction(title: NSLocalizedString("common.cancel", comment: ""), style: .cancel) { _ in }
            UIApplication.topViewController?.present(alert, animated: true)
        }
    }

    private static func saveEventToCalendar(title: String, startDate: Date, endDate: Date, isAllDay: Bool, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let eventStore = EKEventStore()
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            completion?(.success(()))
        } catch let error {
            completion?(.failure(error))
        }
    }
}
