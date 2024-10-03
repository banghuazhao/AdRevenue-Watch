//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public protocol AccessTokenRepositoryProtocol {
    func saveAccessToken(_ token: String) throws
    func getAccessToken() throws -> String
    func deleteAccessToken() throws
}
