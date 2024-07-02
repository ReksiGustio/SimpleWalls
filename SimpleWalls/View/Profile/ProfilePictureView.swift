//
//  ProfilePictureView.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 02/07/24.
//

import SwiftUI

struct ProfilePictureView: View {
    @ObservedObject var global: Global
    @State private var image: Image?
    @State private var data: Data?
    let imageURL: String?
    let frameSize: CGFloat
    
    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameSize, height: frameSize)
                    .clipShape(.circle)
            }
            
            if let existingImage = global.loadImage(data: data ?? Data()) {
                existingImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: frameSize, height: frameSize)
                    .clipShape(.circle)
                    .onAppear { Task { await downloadImage() } }
            } else {
                Circle()
                    .fill(.secondary)
                    .frame(width: frameSize, height: frameSize)
                    .onAppear { Task { await downloadImage() } }
            }
        }
            
    } // end of body
    
    init(global: Global, image: Image? = nil, data: Data? = nil, imageURL: String? = nil, frameSize: CGFloat) {
        self.global = global
        self.image = image
        self.data = data
        self.imageURL = imageURL
        self.frameSize = frameSize
    }
    
    func downloadImage() async -> Image? {
        let response = await downloadRequest(imageURL: imageURL)

        if response.isEmpty {
            return nil
        } else {
            data = response
            UserDefaults.standard.setValue(data, forKey: "userId:\(global.userData.id)")
            return Image(uiImage: UIImage(data: response) ?? UIImage())
        }
        
    } // end of download image
}

#Preview {
    ProfilePictureView(global: Global(), frameSize: 128)
}
