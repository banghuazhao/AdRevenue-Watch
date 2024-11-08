//
// Created by Banghua Zhao on 08/09/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation
import UIKit

public protocol GoogleAuthRepositoryProtocol {
    @MainActor
    func signIn(presentingViewController: UIViewController) async throws -> GoogleUserEntity
    func hasPreviousSignIn() -> Bool
    func restorePreviousSignIn() async throws -> GoogleUserEntity
    func signOut() async
}
