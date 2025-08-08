//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @State private var showEditSheet = false
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
            }
            
            // 🔹 Buttons row (edit always visible)
            HStack(spacing: 40) {
                if let uiImage = loadedImage {
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    } label: {
                        Image(systemName: UIIcons.download)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(12)
//                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                
                Button {
                    showEditSheet.toggle()
                } label: {
                    Image(systemName: UIIcons.edit)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(12)
//                        .background(.ultraThinMaterial, in: Circle())
                }
            }
            .frame(maxWidth: .infinity)   // centers even if only one button
            .padding(.top, 10)
        }
        .sheet(isPresented: $showEditSheet) {
            AddPostView(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
