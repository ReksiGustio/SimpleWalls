//
//  ResponseData.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import Foundation

//default response
struct ResponseData<T: Codable>: Codable {
    let message: String
    let data: T
}

//response message, usually when failed request
struct ResMessage: Codable {
    let message: String
}

//--------------------------------------------------
//used for login
struct LoginBody: Codable {
    let username: String
    let password: String
}

//used for register
struct RegisterBody: Codable {
    let userName: String
    let password: String
    let name: String?
}

//used for fetch partial user data
struct Partial: Codable {
    let partial: String
}

//used for update profile
struct ProfileBody: Codable {
    let name: String?
    let bio: String?
    let profilePicture: String?
}

//used for search post and user
struct SearchBody: Codable {
    let textField: String
}

//used for finding posts
struct PostsBody: Codable {
    let startPoint: Int
}

//used for new post
struct NewPostBody: Codable {
    let title: String?
    let published: Bool
    let imageURL: String?
}

//used for update publish post
struct UpdatePostBody: Codable {
    let title: String?
    let imageURL: String?
    let published: Bool
}

//used for like system
struct LikeBody: Codable {
    let userId: Int
    let displayName: String?
}

//used for create comment
struct CommentBody: Codable {
    let text: String?
    let imageURL: String?
    let postId: Int
    let userId: Int
}

//used for finding comments
struct CommentsBody: Codable {
    let id: Int
    let startPoint: Int
}

//--------------------------------------------------
//used for user data
struct User: Codable, Hashable {
    let id: Int
    let userName: String
    let profile: Profile
    var posts: [Post]?
    
    static let example = User(id: 1, userName: "", profile: .example, posts: [.example])
}

//used for user data
struct PartialUser: Codable, Hashable {
    let id: Int
    let userName: String
    let profile: Profile
    
    static let example = PartialUser(id: 1, userName: "", profile: .example)
}

//used for user profile
struct Profile: Codable, Hashable {
    let id: Int
    let name: String?
    let bio: String?
    let profilePicture: String?
    let userId: Int
    
    static let example = Profile(id: 1, name: "", bio: "", profilePicture: nil, userId: 1)
}

//used for user profile
struct Post: Codable, Hashable, Identifiable {
    let id: Int
    let title: String?
    let imageURL: String?
    let likes: [PostLike]?
    var comments: [Comment]?
    let createdAt: String
    let updatedAt: String
    let published: Bool
    let authorId: Int
    let author: PartialUser?
    
    static let example = Post(id: 1, title: "", imageURL: nil, likes: [PostLike(displayName: "", postId: 1, userId: 3)], comments: [.example], createdAt: "", updatedAt: "", published: true, authorId: 1, author: nil)
}

//used for post like data
struct PostLike: Codable, Hashable {
    let displayName: String
    let postId: Int
    let userId: Int
}

//used for single comment
struct Comment: Codable, Hashable, Identifiable {
    let id: Int
    let text: String?
    let imageURL: String?
    let likes: [CommentLike]?
    let createdAt: String?
    let updatedAt: String?
    let userId: Int?
    let postId: Int?
    
    static let example = Comment(id: 1, text: "", imageURL: nil, likes: [], createdAt: "", updatedAt: "", userId: 1, postId: 1)
}
//used for comment like
struct CommentLike: Codable, Hashable {
    let displayName: String?
    let commentId: Int
    let userId: Int
}