//
//  Post.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import Foundation
import CoreData

struct Post: Codable {
    let id: Int
    let title: String
    let body: String
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, title, body
    }
}

extension Post {
    func managedObject(context: NSManagedObjectContext) -> PostEntity {
        let postEntity = PostEntity(context: context)
        postEntity.id = Int64(self.id)
        postEntity.title = self.title
        postEntity.body = self.body
        return postEntity
    }
}
