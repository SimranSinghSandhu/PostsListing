//
//  Post.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import Foundation

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, title, body
    }
}
