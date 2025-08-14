//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @State private var showEditSheet = false
    @State private var showPostDateSheet = false
    @State private var selectedPostDate = Date()
    
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
            Button {
                showEditSheet.toggle()
            } label: {
                Text(post.title)
                    .font(.title3)
                    .textSelection(.enabled)
                    .contextMenu { // gives a copy option on long press
                             Button {
                                 UIPasteboard.general.string = post.title
                             } label: {
                                 Label("Copy", systemImage: "doc.on.doc")
                             }
                         }
            }
            
            if let postDate = post.postDate {
                Text(postDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
            }
            
            
            if let uiImage = loadedImage {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                    
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
                .frame(maxHeight: 250)
              
            }
            
            
            
            
        }
        .sheet(isPresented: $showEditSheet) {
            AddPostSheet(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
