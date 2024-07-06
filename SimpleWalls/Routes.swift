//
//  Routes.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 22/06/24.
//

import Foundation

//login function
func login(username: String, password: String) async -> Data {
    let userData = LoginBody(username: username, password: password)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/login")
    return data
}

//logout function
func removeCookie() {
    guard let url = URL(string: "http://172.20.57.25:3000") else { return }
    if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
        for cookie in cookies {
            print("\(cookie)")
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
    }
}

//register function
func register(username: String, password: String, name: String?) async -> Data {
    let userData = RegisterBody(userName: username, password: password, name: name)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/register")
    return data
}

//check user status
func userStatus() async -> Data {
    let data = await getRequest(API: "/user/status")
    return data
}

//get user status by id
func statusById(_ id: Int) async -> Data {
    let data = await getRequest(API: "/users/\(id)")
    return data
}

//get user status partially
func partialStatus(_ id: Int) async -> Data {
    let userData =  Partial(partial: "partial")
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/users/\(id)")
    return data
}

//update user status
func updateStatus(name: String?, bio: String?, profilePicture: String?) async -> Data {
    let userData = ProfileBody(name: name, bio: bio, profilePicture: profilePicture)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await putRequest(body: encoded, API: "/user/update")
    return data
}

//find posts
func findPosts(_ startPoint: Int) async -> Data {
    let userData = PostsBody(startPoint: startPoint)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/posts")
    return data
}

//create new post
func uploadPost(title: String?, published: Bool, imageURL: String?) async -> Data {
    let userData = NewPostBody(title: title, published: published, imageURL: imageURL)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/post")
    return data
}

//update post
func updatePost(id: Int, title: String?, published: Bool) async -> Data {
    let userData = UpdatePostBody(title: title, published: published)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await putRequest(body: encoded, API: "/post/\(id)")
    return data
}

//delete post
func deletePost(postId: Int) async -> Data {
    let data = await deleteRequest(API: "/post/\(postId)")
    return data
}

//find post by id
func postById(_ id: Int) async -> Data {
    let data = await getRequest(API: "/post/\(id)")
    return data
}

//search post and user
func searchRequest(_ API: String, textField: String) async -> Data {
    let userData = SearchBody(textField: textField)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/\(API)/search")
    return data
}

//like post
func likePost(userId: Int, postId: Int, displayName: String?) async -> Data {
    let userData = LikeBody(userId: userId, displayName: displayName)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/post/like/\(postId)")
    return data
}

//unlike post
func unlikePost(postId: Int) async -> Data {
    let data = await deleteRequest(API: "/post/like/\(postId)")
    return data
}

//create comment
func uploadComment(text: String?, imageURL: String?, postId: Int, userId: Int) async -> Data {
    let userData = CommentBody(text: text, imageURL: imageURL, postId: postId, userId: userId)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/comment/\(postId)")
    return data
}

//find comments
func findComments(id: Int, startPoint: Int) async -> Data {
    let userData = CommentsBody(id: id, startPoint: startPoint)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/comments")
    return data
}

//delete comment
func deleteComment(commentId: Int) async -> Data {
    let data = await deleteRequest(API: "/comment/\(commentId)")
    return data
}

//like comment
func likeComment(userId: Int, commentId: Int, displayName: String?) async -> Data {
    let userData = LikeBody(userId: userId, displayName: displayName)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/comment/like/\(commentId)")
    return data
}

//unlike comment
func unlikeComment(commentId: Int) async -> Data {
    let data = await deleteRequest(API: "/comment/like/\(commentId)")
    return data
}

//follow user
func followUser(id: Int, displayName: String?, imageURL: String?) async -> Data {
    let userData = FollowBody(displayName: displayName, imageURL: imageURL)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/user/follow/\(id)")
    return data
}

//follow user
func unfollowUser(userId: Int) async -> Data {
    let data = await deleteRequest(API: "/user/follow/\(userId)")
    return data
}

//create notification
func createNotification(object: String, userImage: String?, postId: Int?, ownerId: Int) async -> Data {
    let userData = NotificationBody(object: object, userImage: userImage, postId: postId, ownerId: ownerId)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/notification")
    return data
}

//delete notification
func deleteNotification(object: String, ownerId: Int) async -> Data {
    let userData = NotificationBody(object: object, userImage: nil, postId: nil, ownerId: ownerId)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/notification/delete")
    return data
}

//fetch notifications
func fetchNotifications(startPoint: Int) async -> Data {
    let userData = PostsBody(startPoint: startPoint)
    guard let encoded = try? JSONEncoder().encode(userData) else { return Data() }
    
    let data = await postRequest(body: encoded, API: "/notifications")
    return data
}

//fetch notifications
func updateNotification(id: Int) async -> Data {
    let data = await putRequest(body: Data(), API: "/notification/\(id)")
    return data
}

