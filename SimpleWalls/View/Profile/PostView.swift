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
    let author: PartialUser
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                NavigationLink {
                    ProfileView(global, userId: post.authorId, path: $path)
                } label: {
                    HStack {
                        //image placeholder
                        Circle()
                            .fill(.gray)
                            .frame(width: 44, height: 44)
                        
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
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                    .lineLimit(5)
                    .padding(.vertical, 5)
                
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
            }
            .padding(.top, 5)
            
        } // end of vstack
        .padding()
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
    
    func update(id: Int, published: Bool) {
        Task {
            print("update publish post")
            let response = await updatePost(id: id, title: post.title, imageURL: post.imageURL, published: published)
            
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
            
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                post = data.data
                global.message = data.message
                withAnimation { global.showMessage = true }
                global.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
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
                post = data.data
                global.message = data.message
                withAnimation { global.showMessage = true }
                global.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            } else {
                global.errorHandling(response: response)
            }
        }
    } // end of unlike
    
}
