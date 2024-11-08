//
// Created by Banghua Zhao on 08/11/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public protocol AccessTokenProvider {
    func saveAccessToken(_ token: String) throws
    func getAccessToken() throws -> String
    func deleteAccessToken() throws
}
