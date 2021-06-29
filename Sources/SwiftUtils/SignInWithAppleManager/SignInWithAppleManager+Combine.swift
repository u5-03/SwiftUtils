//
//  SignInWithAppleManager+Combine.swift
//  
//
//  Created by Yugo Sugiyama on 2021/01/08.
//

import Foundation
import Combine
import SwiftNetwork

extension SignInWithAppleManager {
    public func checkLoginStatus() -> AnyPublisher<Bool, Error> {
        CommonNetwork.shared.network { promise in
            SignInWithAppleManager.shared.checkLoginStatus { isValid in
                promise(.success(isValid))
            }
        }
    }

    public func authorizationWithAppleID() -> AnyPublisher<SignInWithAppleCredential, Error> {
        CommonNetwork.shared.network { promise in
            SignInWithAppleManager.shared.authorizationWithAppleID { result in
                switch result {
                case .success(let credential):
                    promise(.success(credential))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
}

