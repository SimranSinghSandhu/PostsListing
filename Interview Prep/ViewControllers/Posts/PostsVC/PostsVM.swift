//
//  PostsVM.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit
import Combine

class PostsVM {
    
    @Published var posts: [Post]?
    @Published var error: String?
    
    var isLoading = false
    var currentPage = 1
    var totalPages = 10 // For testing, as the API doenst have pagination integrated
    
    var shouldRefresh = false
    
    deinit {
        print("Posts ViewModal de-initialised")
    }
    
    @MainActor func fetchPosts(query: [URLQueryItem]) {
        Task {
            do {
                let posts = try await NetworkManager.shared.request(.fetchPosts(query: query) as Endpoint<[Post]>)
                self.isLoading = false
                if currentPage == 1 {
                    self.posts = posts
                } else {
                    self.posts = (self.posts ?? []) + posts
                }
            }
            catch {
                self.isLoading = false
                self.error = ErrorCodes.decodingError.localizedDescription
            }
        }
    }
}
