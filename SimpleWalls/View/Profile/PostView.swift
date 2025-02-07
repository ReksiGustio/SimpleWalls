//
//  PostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 24/06/24.
//

import SwiftUI

struct PostView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var post: Post
    @State private var displayPicture: Image?
    @State private var picture: Data?
    @State private var postPicture: Data?
    let author: PartialUser
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                NavigationLink {
                    ProfileView(global, userId: post.authorId, path: $path)
                } label: {
                    HStack {
                        ProfilePictureView(global: global, data: picture, imageURL: author.profile.profilePicture, frameSize: 44)
                        
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text(postDate)
                                .foregroundStyle(.secondary)
                        } // end of vstack
                        
                    } // end of hstack
                    
                } // end of navlink
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                if post.authorId == global.userData.id {
                    Menu(post.published ? "Public" : "Private") {
                        Button("Public") { if post.published == false {
                                update(id: post.id, published: true)
                            }
                        }
                        
                        Button("Private") { if post.published {
                            update(id: post.id, published: false)
                        }
                            
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                
            } // end of hstack
            .padding([.horizontal, .top])
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                    .lineLimit(5)
                    .padding(.top, 5)
                    .padding([.horizontal, .bottom], 10)
                
                if isSharingPost {
                    if let postId = post.imageURL {
                        SharedPostView(global, post: .example, author: .example, path: .constant(NavigationPath()), postId: Int(postId))
                            .disabled(true)
                            .padding(.horizontal)
                    }
                }
                
                if post.imageURL != nil && !isSharingPost {
                    PostPictureView(global: global, data: postPicture, imageURL: post.imageURL, postId: post.id)
                        .overlay (
                            Rectangle()
                                .stroke(.secondary)
                        )
                }
                
                HStack {
                    if (post.likes?.count ?? 0) > 0 {
                        Group {
                            Image(systemName: "hand.thumbsup.circle.fill")
                            Text("\(post.likes?.count ?? 0)")
                        }
                        .foregroundStyle(.blue)
                    } // end if
                    
                    Spacer()
                    
                    if (post.comments?.count ?? 0) > 0 {
                        Text("^[\(post.comments?.count ?? 0) Comment](inflect: true)")
                            .foregroundStyle(.secondary)
                    } // end if
                } // end of hstack
                .padding([.horizontal, .top], 10)
                
            } // end of vstack
            .contentShape(Rectangle())
            .onTapGesture {
                global.commentTapped = false
                path.append(post)
            }
            
            Divider()
            
            HStack {
                Button { 
                    if likedBySelf { unlike() }
                    else { like() }
                } label: {
                    Label(likedBySelf ? "Liked" : "Like", systemImage: "hand.thumbsup.fill")
                }
                .frame(maxWidth: .infinity)
                .tint(likedBySelf ? .blue : .primary)
                
                Divider()
                .frame(height: 20)
                
                Button { 
                    global.commentTapped = true
                    path.append(post)
                } label: {
                    Label("Comment", systemImage: "message.fill")
                }
                .frame(maxWidth: .infinity)
                .tint(.primary)
                
                Divider()
                .frame(height: 20)
                
                NavigationLink {
                    NewPostView(global, sharedPost: post) { _ in }
                } label: {
                    Label("Share", systemImage: "arrowshape.turn.up.right.fill")
                }
                .frame(maxWidth: .infinity)
                .tint(.primary)
            }
            .padding(.vertical)
            
        } // end of vstack
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(post.published ? .primary : .secondary ,lineWidth: 1)
        )
    } // end of body
    
    init(_ global: Global, post: Post, author: PartialUser, path: Binding<NavigationPath>) {
        self.global = global
        self.author = author
        _post = State(initialValue: post)
        _path = path
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(author.id)") ?? nil)
        _postPicture = State(initialValue: UserDefaults.standard.data(forKey: "postId:\(post.id)") ?? nil)
    }
    
}

#Preview {
    PostView(Global(), post: .example, author: .example, path: .constant(NavigationPath()))
}

//function and computed properties here
extension PostView {
    
    var profile: Profile {
        return author.profile
    } // end of profile property
    
    var name: String {
        return profile.name == "" ? "New User" : profile.name ?? "New User"
    } // end of name property
    
    var postDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let date = formatter.date(from: post.createdAt) ?? .now
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        
        let relativeDate = relativeFormatter.localizedString(for: date, relativeTo: .now)
        
        return relativeDate
    }
    
    var likedBySelf: Bool {
        return post.likes?.contains(where: { $0.userId == global.userData.id }) ?? false
    }
    
    var isSharingPost: Bool {
        guard let pictureURL = post.imageURL else { return false }
        if pictureURL.hasPrefix("http") {
            return false
        } else {
            return true
        }
    }
    
    func update(id: Int, published: Bool) {
        Task {
            print("update publish post")
            let response = await updatePost(id: id, title: post.title, published: published)
            
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                post = data.data
                global.message = data.message
                withAnimation { global.showMessage = true }
                global.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            } else {
                global.errorHandling(response: response)
            }
        }
    } // end of updatepost
    
    func like() {
        Task {
            print("liking post")
            let response = await likePost(userId: global.userData.id, postId: post.id, displayName: global.userData.profile.name)
            
            let title = "\"\(post.title ?? "")\""
            let object = "\(global.userData.profile.name ?? "Someone") liked your post: \(title)"
            
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                let _ = await createNotification(object: object, userImage: global.userData.profile.profilePicture, postId: post.id, ownerId: post.authorId)
                
                post = data.data
            } else {
                global.errorHandling(response: response)
            }
        }
    } // end of like
    
    func unlike() {
        Task {
            print("unlike post")
            let response = await unlikePost(postId: post.id)
            
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                let object = "liked your post"
                let _ = await deleteNotification(object: object, ownerId: post.authorId)
                
                post = data.data
            } else {
                global.errorHandling(response: response)
            }
        }
    } // end of unlike
    
}
