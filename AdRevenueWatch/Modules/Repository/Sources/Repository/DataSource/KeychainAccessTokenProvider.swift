//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

// Data Layer
import Foundation
import Domain
import Security

public struct KeychainAccessTokenProvider: AccessTokenProvider {
    private let serviceName = "com.adRevenueWatch.accessToken"
    
    public init() {}

    public func saveAccessToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : serviceName,
            kSecValueData as String   : data
        ]

        // Remove existing item
        SecItemDelete(query as CFDictionary)

        // Add new token
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw mapKeychainError(status: status)
        }
    }

    public func getAccessToken() throws -> String {
        let query: [String: Any] = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrService as String   : serviceName,
            kSecReturnData as String    : kCFBooleanTrue!,
            kSecMatchLimit as String    : kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            if let data = dataTypeRef as? Data,
               let token = String(data: data, encoding: .utf8) {
                return token
            } else {
                throw AccessTokenErrorEntity.invalidTokenData
            }
        } else {
            throw mapKeychainError(status: status)
        }
    }

    public func deleteAccessToken() throws {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : serviceName
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw mapKeychainError(status: status)
        }
    }

    private func mapKeychainError(status: OSStatus) -> AccessTokenErrorEntity {
        // Optionally log the error status
        print("Keychain error with status: \(status)")

        switch status {
        case errSecItemNotFound:
            return .noToken
        default:
            return .unexpectedError
        }
    }
}
