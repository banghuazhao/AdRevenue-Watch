//
// Created by Banghua Zhao on 08/11/2024
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation

public enum NetworkError: Error {
    case noAccessToken
    case accessTokenExpired    // Access token expired
    case forbidden          // User does not have permission
    case notFound           // Resource not found (404)
    case serverError        // Server error (5xx)
    case invalidResponse    // Invalid or unexpected response
    case decodingError      // JSON decoding failed
    case networkFailure     // General network failure (e.g., no internet)
    case timeout            // Request timed out
    case unknown            // Unknown error

    // Provide a message for each error case
    public var message: String {
        switch self {
        case .noAccessToken: return "No access token"
        case .accessTokenExpired:
            return "Access token expired."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .serverError:
            return "The server encountered an error. Please try again later."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError:
            return "Failed to decode the data. Please try again."
        case .networkFailure:
            return "Network connection lost. Please check your internet connection."
        case .timeout:
            return "The request timed out. Please try again."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}
