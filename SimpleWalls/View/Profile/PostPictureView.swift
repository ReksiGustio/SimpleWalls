//
//  PostPictureView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 02/07/24.
//

import SwiftUI

struct PostPictureView: View {
    @ObservedObject var global: Global
    @State private var image: Image?
    @State private var data: Data?
    let imageURL: String?
    let postId: Int
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 300)
                    .clipped()
                    .contentShape(Rectangle())
            }
            
            if let existingImage = global.loadImage(data: data ?? Data()) {
                existingImage
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 300)
                    .clipped()
                    .contentShape(Rectangle())
                    .onAppear { Task { await downloadImage() } }
            } else {
                Rectangle()
                    .fill(.secondary)
                    .frame(maxHeight: 300)
                    .onAppear { Task { await downloadImage() } }
            }
        }
            
    } // end of body
    
    init(global: Global, image: Image? = nil, data: Data? = nil, imageURL: String? = nil, postId: Int) {
        self.global = global
        self.image = image
        self.data = data
        self.imageURL = imageURL
        self.postId = postId
    }
    
    func downloadImage() async -> Image? {
        let response = await downloadRequest(imageURL: imageURL)

        if response.isEmpty {
            return nil
        } else {
            data = response
            UserDefaults.standard.setValue(data, forKey: "postId:\(postId)")
            return Image(uiImage: UIImage(data: response) ?? UIImage())
        }
        
    } // end of download image
}

#Preview {
    PostPictureView(global: Global(), postId: -1)
}
