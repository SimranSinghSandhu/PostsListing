//
//  APIHelper.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import Foundation
import UIKit

struct APIHelper {
    static let baseURL = "https://jsonplaceholder.typicode.com"
}

struct Endpoint<ResponseType> {
    private let path: Path
    private let queryItems: [URLQueryItem]
    
    init(path: Path, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.queryItems = queryItems
    }
}

extension Endpoint {
    enum Path {
        
        case posts
     
        var asString: String {
            switch self {
                
            case .posts: return "/posts"
                
            }
        }
    }
}

extension Endpoint {
    /// A convenience property for constructing a URL
    var url: URL? {
        var components = URLComponents()
        components.path = "\(path.asString)"
        components.queryItems = queryItems
        
        let urlString = components.url?.absoluteString.removingPercentEncoding
        let urlString2 = urlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        return URL(string: APIHelper.baseURL + (urlString2 ?? ""))
    }
    
    static func fetchPosts(query: [URLQueryItem]) -> Endpoint {
        .init(path: .posts, queryItems: query)
    }
}
