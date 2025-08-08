//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//

import SwiftUI

struct PostDetailView: View {
    let post: Post
    
    var loadedImage: UIImage? {
        guard let filename = post.image else { return nil }
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
    
    var body: some View {
    
            VStack {
                Text(post.title)
                    .font(.title3)
                    .padding()
                    .textSelection(.enabled)
               
                if let uiImage = loadedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                    
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: UIIcons.edit)
                                .foregroundStyle(.white)
                                .padding(. leading, 20)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        } label: {
                            Image(systemName: UIIcons.download)
                                .foregroundStyle(.white)
                                .padding(. trailing, 20)

                        }
                    }
                    
                
                   
                }
                            
    //            Text(testPost.completedDate, format: .dateTime.day().month().year())

            }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
