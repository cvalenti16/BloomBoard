//
//  SettingsView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 12/15/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("trackedPlatforms")
    private var platforms: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    private var allSocials: [SocialMedia] {
        SocialMedia.allCases.filter { $0 != .none }
    }
    
    private var tracked: Set<SocialMedia> {
        get {
            guard !platforms.isEmpty else {
                return Set(allSocials)
            }
            
            return Set(
                platforms
                    .split(separator: ",")
                    .compactMap { SocialMedia(rawValue: String($0)) }
            )
        }
        set {
            platforms = newValue
                .map(\.rawValue)
                .sorted()
                .joined(separator: ",")
        }
    }
    
    var body: some View {
        NavigationStack {
            List(SocialMedia.allCases.filter{$0 != .none}) { platform in
                Toggle(platform.rawValue, isOn: Binding(
                    get: {
                        tracked.contains(platform)
                    },
                    set: { isOn in
                        var current = tracked
                        if isOn {
                            current.insert(platform)
                        } else {
                            current.remove(platform)
                        }
                        
                        platforms = current
                            .map(\.rawValue)
                            .sorted()
                            .joined(separator: ",")
                        
                    }
                ))
                .padding(.horizontal)
            }
            .scrollDisabled(true)
            .navigationTitle("Tracked Platforms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
            }
        }
    }
}



#Preview {
    SettingsView()
}


