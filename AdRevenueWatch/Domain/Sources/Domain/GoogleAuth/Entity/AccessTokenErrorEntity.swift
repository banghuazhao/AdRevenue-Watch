//
// Created by Banghua Zhao on 03/10/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public enum AccessTokenErrorEntity: Error {
    case noToken
    case invalidTokenData
    case unexpectedError
}
