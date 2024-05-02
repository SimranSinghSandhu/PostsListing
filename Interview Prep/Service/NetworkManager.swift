//
//  NetworkManager.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit
import SystemConfiguration

enum ErrorCodes: Error {
    case invalidUrl
    case tokenExpired
    case unauthorisedAccess
    case invalidResponse
    case reachabilityIssue
    case decodingError
    case invalidMedia
    case network(Error?)
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    var isTokenAlreadyExpired: Bool = false
    
    // MARK: - GET
    
    func request<ResponseType: Codable>(
        _ endpoint: Endpoint<ResponseType>
    ) async throws -> ResponseType {
        return try await realRequest(endpoint, payload: nil as String?)
    }
    
    // MARK: - POST
    
    func request<ResponseType: Codable, Payload: Encodable>(
        _ endpoint: Endpoint<ResponseType>,
        payload: Payload
    ) async throws -> ResponseType {
        return try await realRequest(endpoint, payload: payload)
    }
    
    // MARK: - DELETE
    
    func deleteRequest<ResponseType: Codable>(
        _ endpoint: Endpoint<ResponseType>
    ) async throws -> ResponseType {
        return try await realRequest(endpoint, payload: nil as String?, delete: true)
    }
    
    // MARK: - PUT
    
    func putRequest<ResponseType: Codable>(
        _ endpoint: Endpoint<ResponseType>
    ) async throws -> ResponseType {
        return try await realRequest(endpoint, payload: nil as String?, put: true)
    }
    
    // MARK: - application/json type
    
    private func realRequest<ResponseType: Codable, Payload: Encodable>(
        _ endpoint: Endpoint<ResponseType>,
        payload: Payload? = nil,
        delete: Bool = false,
        put: Bool = false
    ) async throws -> ResponseType {
        // This will check if device is connected to any Wifi or celluler data otherwise it will throw an error
        if !checkNetworkConnectivity() {
            throw ErrorCodes.reachabilityIssue
        }
        
        guard let url = endpoint.url else {
            throw ErrorCodes.invalidUrl
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        
        if let payload = payload { // Post
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(payload)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            debugPrint("payload - ", payload)
        } else if put {
            request.httpMethod = "PUT"
        } else if delete {
            request.httpMethod = "DELETE"
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("****************\nURL: ", request.url!, "\nHeaderFields: ", request.allHTTPHeaderFields!, "\nMethod: ", request.httpMethod!, "\n****************")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Use this to print response in the console
        if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
            print("API JSON Response =", JSONString)
        } else {
            print("Invalid JSON")
        }

        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            guard (200...299 ~= statusCode || statusCode == 401 || statusCode == 403 || statusCode == 404 || statusCode == 400) else {
                // Invalid response
                throw ErrorCodes.invalidResponse
                // show error
            }
            
            // Token Expired or Invalid because of Unautorised Access
            if statusCode == 401 {
                // If there is a token involved in the app, and it gets expired.
            }
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // So we can use codable structs
            return try decoder.decode(ResponseType.self, from: data)
        } catch {
            print("error = ", error)
            throw ErrorCodes.decodingError
        }
    }
    
}

extension NetworkManager {
    
    func checkNetworkConnectivity() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
