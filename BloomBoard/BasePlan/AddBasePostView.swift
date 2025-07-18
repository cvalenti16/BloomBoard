//
//  AddBasePostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/9/25.
//

import SwiftUI

struct AddBasePostView: View {
    @State private var selectedPlatform: SocialMediaPlatform
    @State private var selectedPostType: PostType
    @State private var selectedDay: Day
    var existingPost: SocialPost?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    init(existingPost: SocialPost? = nil) {
        _selectedPlatform = State(initialValue: existingPost?.platform ?? . Youtube)
        _selectedPostType = State(initialValue: existingPost?.postType ?? .ImagePost)
        _selectedDay = State(initialValue: existingPost?.postDay ?? .Sunday)
        self.existingPost = existingPost
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker(UIStrings.day, selection: $selectedDay) {
                    ForEach(Day.allCases, id: \.self) { day in
                        Text(day.rawValue)
                    }
                }
                
                Picker(UIStrings.platformString, selection: $selectedPlatform) {
                    ForEach(SocialMediaPlatform.allCases, id: \.self) { platform in
                        Text(platform.rawValue)
                    }
                }
                
                Picker(UIStrings.postType, selection: $selectedPostType) {
                    ForEach(selectedPlatform.availablePostTypes, id: \.self) { postType in
                        Text(postType.rawValue)
                    }
                }
            }
            .scrollDisabled(true)
            .navigationTitle(existingPost == nil ? UIStrings.addBasePost : UIStrings.editBasePost)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(UIStrings.cancelString)
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let post = existingPost {
                            post.platform = selectedPlatform
                            post.postType = selectedPostType
                            post.postDay = selectedDay
                            
                            try? modelContext.save()
                            dismiss()
                            
                        } else {
                            let newBasePost = SocialPost(postType: selectedPostType, platform: selectedPlatform, postDay: selectedDay)
                            modelContext.insert(newBasePost)
                            dismiss()
                        }
                        
                        
                        
                        
                    } label: {
                        Text(UIStrings.saveString)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    AddBasePostView()
}
