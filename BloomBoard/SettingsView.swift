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
    
    @AppStorage("selectedAppearance") private var selectedAppearance: Appearance = .dark
    
    @Environment(\.dismiss) private var dismiss
    
    private var allSocials: [SocialMedia] {
        SocialMedia.allCases
            .filter { $0 != .none }
            .sorted { $0.rawValue < $1.rawValue }
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
            List(allSocials){ platform in
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        switch selectedAppearance {
                        case .dark: selectedAppearance = .light
                        case .light: selectedAppearance = .dark
                        }
                    } label: {
                        Image(systemName: selectedAppearance == .dark ? UIIcons.moon : UIIcons.sun)
                            .symbolEffect(.bounce, value: selectedAppearance)
                    }
                    
                    
                }
            }
            .environment(\.colorScheme, selectedAppearance == .dark ? .dark : .light)
        }
    }
}

#Preview {
    SettingsView()
}

