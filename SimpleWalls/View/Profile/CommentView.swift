//
//  CommentView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 28/06/24.
//

import SwiftUI

struct CommentView: View {
    @ObservedObject var global: Global
    @Binding var path: NavigationPath
    @State private var user = User.example
    @State private var comment: Comment
    @State private var viewState = ViewState.downloading
    @State private var displayPicture: Image?
    @State private var picture: Data?
    
    var body: some View {
        if viewState == .downloaded {
            HStack(alignment: .top) {
                NavigationLink {
                    ProfileView(global, userId: comment.userId ?? 0, path: $path)
                } label: {
                    ProfilePictureView(global: global, data: picture, imageURL: user.profile.profilePicture, frameSize: 44)
                } // end of navlink
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading) {
                    NavigationLink {
                        ProfileView(global, userId: comment.userId ?? 0, path: $path)
                    } label: {
                        Text(name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    } // end of navlink
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(comment.text ?? "")
                    
                    HStack {
                        Text(postDate)
                            .padding(.trailing, 5)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            likedBySelf ? unlike() : like()
                        } label: {
                            Text(likedBySelf ? "Liked" : "Like")
                                .font(.headline)
                                .foregroundStyle(likedBySelf ? .blue : .secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if (comment.likes?.count ?? 0) > 0 {
                            Group {
                                Image(systemName: "hand.thumbsup.circle.fill")
                                Text("\(comment.likes?.count ?? 0)")
                            }
                            .foregroundStyle(.blue)
                        } // end if
                    } // end of hstack
                    
                } // end of vstack
                .padding(.leading, 10)
                
                Spacer()
                
            } // end of hstack
            .frame(maxWidth: .infinity)
            
        } else {
            Color.clear
                .frame(width: 1, height: 1)
                .onAppear { downloadUser(comment.userId ?? 0) }
        }// end if
    } // end of body
    
    init(_ global: Global, comment: Comment, path: Binding<NavigationPath>) {
        self.global = global
        self.comment = comment
        _path = path
        _picture = State(initialValue: UserDefaults.standard.data(forKey: "userId:\(comment.userId ?? 0)") ?? nil)
    }
}

#Preview {
    CommentView(Global(), comment: .example, path: .constant(NavigationPath()))
}

extension CommentView {
    
    var profile: Profile {
        return user.profile
    } // end of profile property
    
    var name: String {
        return profile.name == "" ? "New User" : profile.name ?? "New User"
    } // end of name property
    
    var postDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let date = formatter.date(from: comment.createdAt ?? "") ?? .now
        
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .abbreviated
        
        let relativeDate = relativeFormatter.localizedString(for: date, relativeTo: .now)
        
        return relativeDate
    }
    
    var likedBySelf: Bool {
        return comment.likes?.contains(where: { $0.userId == global.userData.id }) ?? false
    }
    
    func downloadUser(_ id: Int) {
        Task {
            let response = await partialStatus(id)
            
            //get data success
            if let data = try? JSONDecoder().decode(ResponseData<User>.self, from: response) {
                user = data.data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewState = .downloaded
                }
            }
        }
    }// end of downloaduser
    
    func like() {
        Task {
            print("liking comment")
            let response = await likeComment(userId: global.userData.id, commentId: comment.id, displayName: global.userData.profile.name)
            
            if let data = try? JSONDecoder().decode(ResponseData<Comment>.self, from: response) {
                comment = data.data
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
            print("unlike comment")
            let response = await unlikeComment(commentId: comment.id)
            
            if let data = try? JSONDecoder().decode(ResponseData<Comment>.self, from: response) {
                comment = data.data
                global.message = data.message
                withAnimation { global.showMessage = true }
                global.timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
            } else {
                global.errorHandling(response: response)
            }
        }
    } // end of unlike
    
}
