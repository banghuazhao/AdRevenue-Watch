//
// Created by Banghua Zhao on 08/11/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
