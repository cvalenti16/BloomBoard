//
//  PostTitleEdit.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 9/11/25.
//

import SwiftUI
import SwiftData

struct PostTitleEdit: View {
    @Bindable var post: Post
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State var errorMessage : String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter title", text: $post.title, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .bold()
                
                if let error = errorMessage {
                    Text(error)
                        .defaultErrorStyle()
                }
                
                Spacer()
            }
            .navigationTitle("Edit Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.x)
                            .foregroundStyle(.text)
                    }
                }
                
                // Save button
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            errorMessage = ErrorMessages.savedFailed
                            print(error)
                        }
                    } label: {
                        Image(systemName: UIIcons.save)
                            .foregroundStyle(.text)
                    }
                }
            }
        }
    }
}

#Preview {
    // Preview with a test Post
    PostTitleEdit(post: .testPost)
        .preferredColorScheme(.dark)
}
