//
//  SignInWithAppleManager.swift
//  Repty
//
//  Created by 杉山優悟 on 2021/01/04.
//  Copyright © 2021 yugo.sugiyama. All rights reserved.
//

import Foundation
import AuthenticationServices
import SwiftExtensions

private enum SignInWithAppleSaveKey: String {
    case signInWithAppleNickName
    case signInWithAppleEmail
    case signInWithAppleUserIdentifier
    case signInWithAppleIdentityToken
}

public struct SignInWithAppleCredential {
    public let nickName: String?
    public let email: String?
    public let userIdentifier: String
    public let identityToken: String?
    public let nonce: String?

    public init(nickName: String?, email: String?,
                userIdentifier: String,
                identityToken: String?,
                nonce: String?) {
        self.nickName = nickName
        self.email = email
        self.userIdentifier = userIdentifier
        self.identityToken = identityToken
        self.nonce = nonce
    }
}

public enum AppleServiceError: UtilsErrorProtocol {
    case authFailure(message: String)
    case disAllowMakeAccount(message: String)
    case invalidAccountID(message: String)
    case invalidNickName(message: String)
    case registrationFailure(message: String)
    case disAllowLogin(message: String)
    case loginUserNotFound(message: String)
    case cancel
    case unexpected

    public var message: String {
        switch self {
        case .authFailure(let message), .disAllowMakeAccount(let message), .invalidAccountID(let message),
             .invalidNickName(let message), .registrationFailure(let message),
             .disAllowLogin(let message), .loginUserNotFound(let message):
            return message
        case .cancel: return NSLocalizedString("error.cancelled", comment: "")
        case .unexpected: return NSLocalizedString("error.unknown", comment: "")
        }
    }

    static func convert(errorMessage: String, errorType: String) -> AppleServiceError {
        switch errorType {
        case "AUTH_FAILURE":
            return .authFailure(message: errorMessage)
        case "DISALLOW_MAKE_ACCOUNT":
            return .disAllowMakeAccount(message: errorMessage)
        case "INVALID_ACCOUNT_ID":
            return .invalidAccountID(message: errorMessage)
        case "INVALID_NAME":
            return .invalidNickName(message: errorMessage)
        case "REGISTRATION_FAILURE":
            return .registrationFailure(message: errorMessage)
        case "DISALLOW_LOGIN":
            return .disAllowLogin(message: errorMessage)
        case "USER_NOT_FOUND":
            return .loginUserNotFound(message: errorMessage)
        default:
            return .unexpected
        }
    }
}

public final class SignInWithAppleManager: NSObject {
    public static let shared = SignInWithAppleManager()
    private var result: ((Result<SignInWithAppleCredential, AppleServiceError>) -> Void)?
    private var currentNonce: String?

    public var isAppleLoginUser: Bool {
        return !userIdentifier.isEmpty
    }

    public func resetUserIdentifier() {
        userIdentifier = ""
    }

    public func checkLoginStatus(completion: @escaping ((Bool) -> Void)) {
        if userIdentifier.isEmpty {
            completion(false)
        } else {
            ASAuthorizationAppleIDProvider()
                .getCredentialState(forUserID: self.userIdentifier) { (state, _) in
                    completion(state == .authorized)
                }
        }
    }

    public func authorizationWithAppleID(result: @escaping ((Result<SignInWithAppleCredential, AppleServiceError>) -> Void)) {
        self.result = result
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = String.randomNonceString()
        currentNonce = nonce
        request.nonce = nonce.sha256
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}

extension SignInWithAppleManager: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            //　取得できる値
            var identityTokenString: String?
            if let identityToken = appleIDCredential.identityToken {
                identityTokenString = String(bytes: identityToken, encoding: .utf8)
            }
            let userIdentifier = appleIDCredential.user
            let nickName = appleIDCredential.fullName?.nickname
            let email = appleIDCredential.email
            if !userIdentifier.isEmpty {
                self.userIdentifier = userIdentifier
            }
            if let nickNameUnwrapped = nickName.nilOrEmptyValidated {
                self.nickName = nickNameUnwrapped
            }
            if let emailUnwrapped = email.nilOrEmptyValidated {
                self.email = emailUnwrapped
            }

            let credential = SignInWithAppleCredential(nickName: nickName, email: email, userIdentifier: userIdentifier, identityToken: identityTokenString, nonce: currentNonce)
            result?(.success(credential))
        } else {
            result?(.failure(.unexpected))
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let appleError = error as? AppleServiceError {
            result?(.failure(appleError))
        } else {
            result?(.failure(.unexpected))
        }
    }
}

extension SignInWithAppleManager {
    public var nickName: String? {
        get {
            return UserDefaults.standard
                .string(forKey: SignInWithAppleSaveKey.signInWithAppleNickName.rawValue)
                .unwrapped("")
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: SignInWithAppleSaveKey.signInWithAppleNickName.rawValue)
        }
    }

    public var email: String {
        get {
            return UserDefaults.standard
                .string(forKey: SignInWithAppleSaveKey.signInWithAppleEmail.rawValue)
                .unwrapped("")
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: SignInWithAppleSaveKey.signInWithAppleEmail.rawValue)
        }
    }

    public var userIdentifier: String {
        get {
            return UserDefaults.standard
                .string(forKey: SignInWithAppleSaveKey.signInWithAppleUserIdentifier.rawValue)
                .unwrapped("")
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: SignInWithAppleSaveKey.signInWithAppleUserIdentifier.rawValue)
        }
    }

    public var identityToken: String? {
        get {
            return UserDefaults.standard
                .string(forKey: SignInWithAppleSaveKey.signInWithAppleIdentityToken.rawValue)
        }
        set {
            UserDefaults.standard
                .setValue(newValue, forKey: SignInWithAppleSaveKey.signInWithAppleIdentityToken.rawValue)
        }
    }
}
