//
//  NetworkError.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unauthorized
    case serverError(Int)
    case serverMessage(String)
}
