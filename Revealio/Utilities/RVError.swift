//
//  RVError.swift
//  Revealio
//
//  Created by hanif hussain on 01/01/2025.
//
import Foundation
/// A collection of error codes that related to network connection failures.
public var NSURLErrorConnectionFailureCodes: [Int] {
    [
        NSURLErrorBackgroundSessionInUseByAnotherProcess, /// Error Code: `-996`
        NSURLErrorCannotFindHost, /// Error Code: ` -1003`
        NSURLErrorCannotConnectToHost, /// Error Code: ` -1004`
        NSURLErrorNetworkConnectionLost, /// Error Code: ` -1005`
        NSURLErrorNotConnectedToInternet, /// Error Code: ` -1009`
        NSURLErrorSecureConnectionFailed /// Error Code: ` -1200`
    ]
}

extension Error {
    /// Indicates an error which is caused by various connection related issue or an unaccepted status code.
    /// See: `NSURLErrorConnectionFailureCodes`
    var isOtherConnectionError: Bool {
        NSURLErrorConnectionFailureCodes.contains(_code)
    }
}

enum RVError: String, Error {
    case invalidURL = "The URL is invalid. Please notify customer support."
    case unableToCompleteRequest = "Unable to complete request. Please try again later"
    case invalidResponseFromServer = "Invalid response from the server. Please try again."
    case parametersNil = "Parameters were nil"
    case encodingFailed = "Parameter Encoding failed"
    case decodingFailed = "Unable to Decode data"
    case missingURL = "The URL is nil"
    case couldNotParse = "Unable to parse the JSON response"
    case noData = "Data is nil"
    case fragmentResponse = "Response's body has fragments"
    case authenticationError = "Incorrect username or password"
    case badRequest = "Bad request. Please try again."
    case pageNotFound = "Page not found"
    case failed = "Request failed"
    case serverError = "Server error"
    case noResponse = "No response"
    case success = "Success"
    case weakPassword = "Weak password unable to create account"
    case operationNotAllowed = "Sign up, or sign in is disabled for this app"
    case emailAlreadyInUse = "Email already in use"
    case invalidEmail = "Email invalid, please check if email entered correctly"
    case invalidPhoneNumber = "Phone number invalid, please check if phone number entered correctly"
    case captchaCheckFailed = "Captcha check failed"
    case secondaryAuthRequired = "Secondary authentication required"
    case invalidVerificationCode = "Invalid verification code"
}
