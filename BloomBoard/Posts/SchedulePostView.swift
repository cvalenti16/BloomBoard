//
//  SchedulePostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/11/25.
//

import SwiftUI

struct SchedulePostView: View {
    var post: Post
    @State var selectedPostDate: Date = Date()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(PostStrings.selectPostDate)
                .font(.headline)
            
            DatePicker(
                PostStrings.postedOn,
                selection: $selectedPostDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            
            
            HStack {
                Button(UIStrings.cancelString) { dismiss() }
                
                Spacer()
                
                if post.postDate != nil {
                    Button(PostStrings.unpost) {
                        post.postDate = nil
                        dismiss()
                    }
                    Spacer()
                }
                
                Button(UIStrings.saveString) {
                    post.postDate = selectedPostDate
                    dismiss()
                }
            }
            .padding(.horizontal)
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SchedulePostView(post: Post.testPost)
}
