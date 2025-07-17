//
//  AddBasePostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/9/25.
//

import SwiftUI

struct AddBasePostView: View {
    @State private var selectedPlatform: SocialMediaPlatform = .Youtube
    @State private var selectedPostType: PostType = .ImagePost
    @State private var selectedDay: Day = .Sunday
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            Form {
                Picker(UIStrings.day.rawValue, selection: $selectedDay) {
                    ForEach(Day.allCases, id: \.self) { day in
                        Text(day.rawValue)
                    }
                }
                
                Picker(UIStrings.platformString.rawValue, selection: $selectedPlatform) {
                    ForEach(SocialMediaPlatform.allCases, id: \.self) { platform in
                        Text(platform.rawValue)
                    }
                }
                
                Picker(UIStrings.postType.rawValue, selection: $selectedPostType) {
                    ForEach(selectedPlatform.availablePostTypes, id: \.self) { postType in
                        Text(postType.rawValue)
                    }
                }
            }
            .scrollDisabled(true)
            .navigationTitle(UIStrings.addBasePost.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(UIStrings.cancelString.rawValue)
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newBasePost = SocialPost(postType: selectedPostType, platform: selectedPlatform, postDay: selectedDay)
                        modelContext.insert(newBasePost)
                        dismiss()
                        
                    } label: {
                        Text(UIStrings.saveString.rawValue)
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
