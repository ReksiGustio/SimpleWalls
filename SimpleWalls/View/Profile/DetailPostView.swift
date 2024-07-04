//
//  DetailPostView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 27/06/24.
//

import SwiftUI

struct DetailPostView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    
    @State private var viewState = ViewState.downloading
    @State private var sortComment = SortComment.top
    @State private var post = Post.example
    @State private var author = User.example
    @State private var selectedComment = -1
    @State private var deleteAlert = false
    @State private var displayPicture: Image?
    @State private var picture: Data?
    @State private var postPicture: Data?
    let postId: Int
    let authorId: Int
    let commentTapped: Bool
    
    var body: some View {
        switch viewState {
        case .downloading:
            ProgressView()
                .tint(.primary)
                .onAppear { 
                    downloadUser(authorId)
                    downloadPost(postId)
                    //download photo
                }
        case .downloaded:
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        NavigationLink {
                            ProfileView(global, userId: post.authorId, path: $path)
                        } label: {
                            HStack {
                                ProfilePictureView(global: global, image: displayPicture, data: picture, imageURL: author.profile.profilePicture, frameSize: 44)
                                
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text(postDate)
                                        .foregroundStyle(.secondary)
                                } // end of vstack
                                
                                Spacer()
                                
                                if post.authorId == global.userData.id {
                                    Text(post.published == true ? "Public" : "Private")
                                        .foregroundStyle(.secondary)
                                }
                                
                            } // end of hstack
                            
                        } // end of navlink
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.horizontal)
                        
                        Text(post.title ?? "")
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                        
                        if isSharingPost {
                            if let postId = post.imageURL {
                                SharedPostView(global, post: .example, author: .example, path: $path, postId: Int(postId))
                                    .padding(.horizontal)
                                    .padding(.bottom, 10)
                            }
                        }
                        
                        VStack {
                            if let postPicture {
                                if let image = global.loadImage(data: postPicture) {
                                    Button {
                                        global.imageData = postPicture
                                        global.showImage = true
                                    } label: {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxHeight: 400)
                                            .clipped()
                                            .contentShape(Rectangle())
                                    }
                                }
                            }
                        } // end of vstack
                        
                        if (post.likes?.count ?? 0) > 0 {
                            HStack {
                                Spacer()
                                Image(systemName: "hand.thumbsup.circle.fill")
                                Text("\(post.likes?.count ?? 0)")
                            } // end of hstack
                            .padding(.horizontal)
                            .foregroundStyle(.blue)
                        } // end if
                        
                        Divider().padding(.horizontal)
                        
                        HStack {
                            Button {
                                if likedBySelf { unlike() }
                                else { like() }
                            } label: {
                                Label(likedBySelf ? "Liked" : "Like", systemImage: "hand.thumbsup.fill")
                            }
                            .frame(maxWidth: .infinity)
                            .tint(likedBySelf ? .blue : .primary)
                            .padding(.top, 5)
                            .padding(.horizontal)
                            
                            NavigationLink {
                                NewPostView(global, sharedPost: post) { _ in }
                            } label: {
                                Label("Share", systemImage: "arrowshape.turn.up.right.fill")
                            }
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                        } // end of hstack
                        
                        Divider().padding(.horizontal)
                        
                        HStack {
                            Text("Comments")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            if comments.count > 0 {
                                Picker(commentPicker, selection: $sortComment) {
                                    Text("Latest Comments").tag(SortComment.new)
                                    Text("Oldest Comments").tag(SortComment.old)
                                    Text("Top Comments").tag(SortComment.top)
                                }
                                .tint(.primary)
                                .padding(.horizontal)
                            } // end if
                        }
                        
                        ForEach(comments) { comment in
                            CommentView(global, comment: comment, path: $path)
                                .contextMenu {
                                    if comment.userId == global.userData.id {
                                        Button(role: .destructive) {
                                            selectedComment = comment.id
                                            deleteAlert = true
                                        } label: {
                                            Label("Delete comment", systemImage: "trash")
                                        }
                                        
                                    } // end if
                                    
                                    Button {
                                        UIPasteboard.general.string = post.title
                                    } label: {
                                        Label("Copy text to clipboard", systemImage: "doc.on.doc")
                                    }
                                    
                                }
                                .padding(.bottom, 10)
                        }
                        .padding(.horizontal)
                        
                        //end post marker
                        if comments.count > 19 {
                            Color.secondary
                                .frame(height: 1)
                        }
                        
                    } // end of vstack
                    .padding(.vertical)
                    
                } // end of scrollview
                
                WriteCommentView(global, postId: post.id, commentTapped: commentTapped) { sentComment in
                    post.comments?.append(sentComment)
                }
                .onDisappear { global.commentTapped = false }
                
            } // end of vstack
            .navigationTitle("\(name)'s Post")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete your comment?", isPresented: $deleteAlert) {
                Button("Delete", role: .destructive) {
                    removeComment(commentId: selectedComment)
                }
                Button("Cancel", role: .cancel) { selectedComment = -1 }
            } message: {
                Text("Deleted comment can't be recovered")
            }
            .toolbar {
                if !path.isEmpty {
                    Button("Home") { path = NavigationPath() }
                }
            }
        case .failed:
            Button { 
                downloadUser(authorId)
                downloadPost(postId)
            } label: {
                Label("Try again", systemImage: "arrow.circlepath")
            }
        }
        
    } // end of body
    
    init(_ global: Global, postId: Int, authorId: Int, commentTapped: Bool = false, path: Binding<NavigationPath>) {
        self.global = global
        self.postId = postId
        self.authorId = authorId
        self.commentTapped = commentTapped
        _path = path
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(authorId)") ?? nil)
        _postPicture = State(initialValue: UserDefaults.standard.data(forKey: "postId:\(postId)") ?? nil)
    }
    
}

#Preview {
    DetailPostView(Global(), postId: 1, authorId: 1, path: .constant(NavigationPath()))
}

//function and computed properties here
extension DetailPostView {
    enum SortComment {
        case new, old, top
    }
    
    var profile: Profile {
        author.profile
    } // end of profile property
    
    var name: String {
        profile.name == "" ? "New User" : profile.name ?? "New User"
    } // end of name property
    
    var comments: [Comment] {
        guard let comments = post.comments else { return [] }
        switch sortComment {
        case .new: return comments.sorted { $0.id > $1.id }
        case .old: return comments.sorted { $0.id < $1.id }
        case .top: return comments.sorted { $0.likes?.count ?? 0 > $1.likes?.count ?? 0 }
        }
    }
    
    var commentPicker: String {
        switch sortComment {
        case .new: "Latest Comments"
        case .old: "Oldest Comments"
        case .top: "Top Comments"
        }
    }
    
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
    
    func downloadUser(_ id: Int) {
        Task {
            let response = await partialStatus(id)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                author = data.data
            }
        }
    }// end of downloaduser
    
    func downloadPost(_ id: Int) {
        viewState = .downloading
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await postById(id)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<Post>.self, from: response) {
                post = data.data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewState = .downloaded
                }
            } else {
                print("error handling")
                global.errorHandling(response: response)
                viewState = .failed
            }
        }
    } // end of downloadpost
    
    func downloadComments() {
        print("downloading posts")
        
        Task {
            let response = await findComments(id: post.id, startPoint: comments.count)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<[Comment]>.self, from: response) {
                for comment in data.data {
                    if comments.contains(where: { $0.id == comment.id }) {
                        continue
                    } else {
                        post.comments?.append(comment)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewState = .downloaded
                }
            } else {
                print("error handling")
                viewState = .failed
            }
        }
    } // end of downloadpost
    
    func removeComment(commentId: Int) {
        global.message = ""
        global.timer.upstream.connect().cancel()
        
        Task {
            let response = await deleteComment(commentId: commentId)
            
            //get data success
            global.errorHandling(response: response)
            if global.message.hasPrefix("Deleted") {
                selectedComment = -1
                viewState = .downloading
                downloadPost(postId)
            }
        }
    } // end of removepost
    
    func like() {
        Task {
            print("liking post")
            let response = await likePost(userId: global.userData.id, postId: post.id, displayName: global.userData.profile.name ?? "")
            
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
