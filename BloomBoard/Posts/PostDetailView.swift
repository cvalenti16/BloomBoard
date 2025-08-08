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
                .textSelection(.enabled)
            
            if let uiImage = loadedImage {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                        .frame(maxHeight: 300)
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    } label: {
                        Image(systemName: UIIcons.download)
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
            
            HStack {
                Button {
                    showEditSheet.toggle()
                } label: {
                    Text(PostStrings.edit)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                Spacer()
                    
                Button {
                    
                } label: {
                    Text(PostStrings.post)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .sheet(isPresented: $showEditSheet) {
            AddPostView(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
        .frame(maxHeight: 350)
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
