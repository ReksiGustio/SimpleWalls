//
//  SharedPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 04/07/24.
//

import SwiftUI

struct SharedPostView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var post: Post
    @State private var displayPicture: Image?
    @State private var picture: Data?
    @State private var postPicture: Data?
    @State private var author: PartialUser
    let postId: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                 
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
                
                Spacer()
                
            } // end of hstack
            .padding([.horizontal, .top])
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                    .lineLimit(5)
                    .padding(.top, 5)
                    .padding([.horizontal, .bottom], 10)
                
                if post.imageURL != nil {
                    PostPictureView(global: global, data: postPicture, imageURL: post.imageURL, postId: post.id)
                        .overlay (
                            Rectangle()
                                .stroke(.secondary)
                        )
                }
                
            } // end of vstack
            .contentShape(Rectangle())
            
        } // end of vstack
        .background(Color(uiColor: .systemBackground))
        .clipShape(.rect(cornerRadius: 10))
        .onTapGesture {
            global.commentTapped = false
            path.append(post)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(post.published ? .primary : .secondary ,lineWidth: 1)
        )
        .onAppear {
            if let postId { downloadPost(postId) }
        }
    } // end of body
    
    init(_ global: Global, post: Post, author: PartialUser, path: Binding<NavigationPath>, postId: Int?) {
        self.global = global
        self.postId = postId
        _post = State(initialValue: post)
        _author = State(initialValue: author)
        _path = path
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(author.id)") ?? nil)
        _postPicture = State(initialValue: UserDefaults.standard.data(forKey: "postId:\(post.id)") ?? nil)
    }
}

#Preview {
    SharedPostView(Global(), post: .example, author: .example, path: .constant(NavigationPath()), postId: nil)
}

//function and computed properties here
extension SharedPostView {
    
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
    
    func downloadPost(_ id: Int?) {
        guard let id else { return }
        
        Task {
            let response = await postById(id)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                post = data.data
                author = data.data.author ?? .example
                
                
            }
        }
    } // end of downloadpost
    
}
