//
//  PostSuggestor.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 12/11/25.
//

import SwiftUI
import Observation
import SwiftData
import FirebaseAILogic

enum FetchStatus {
    case notStarted
    case fetching
    case success
    case failed
}

@Observable
@MainActor
final class TitleSuggestor {
    private(set) var title: String?
    private(set) var titles: [String]?
    private(set) var titlesStatus: FetchStatus = .notStarted
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func generateTitles(_ posts: [Post]) async {
        titlesStatus = .fetching
        self.title = nil
        self.titles = nil
        let recentTitles = posts.map {"- \($0.title)"}
            .joined(separator: "\n")
        
        let prompt = """
        You are helping the user come up with three new social media post ideas.
        
        The user has previously published these titles:
        \(recentTitles)
        
        Constraints:
        - Generate exactly three distinct post title ideas
        - Match the user's tone, writing style, and level of directness
        - Use the previous titles to learn the user's voice, not to copy them
        - Keep the ideas similar in length to the user's previous titles
        - Make the ideas feel specific and useful, not generic
        - Avoid repeating the same idea three different ways
        - Avoid emojis, hashtags, quotes, and extra commentary
        - Return only the three titles, one per line
        """
        
        do {
            let responseText: String?
            responseText = try await model.generateContent(prompt).text
            
            let parsedTitles = responseText?
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if let parsedTitles, !parsedTitles.isEmpty {
                self.titles = Array(parsedTitles.prefix(3))
            } else {
                self.titles = nil
            }
            
            titlesStatus = .success
            
        } catch {
            titlesStatus = .failed
            self.title = nil
            self.titles = nil
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                titlesStatus = .notStarted
            }
        }
        
    }
    
    func improveTitle(_ posts: [Post], _ image: UIImage?, _ title: String) async {
        titlesStatus = .fetching
        self.title = nil
        
        let recentTitles = posts.map {"- \($0.title)"}
            .joined(separator: "\n")
        
        let imageContext: String
        if image != nil {
            imageContext = """
            The post includes an image. Use it only as supporting context to better understand the original title. Do not introduce new topics or details that are not grounded in the original title and image.
            """
        } else {
            imageContext = """
            The post does not include an image. Base your suggestion only on the original title and the user's previous titles.
            """
        }
        
        let prompt = """
        You are helping improve one social media post title written by the user.
        
        Original title:
        \(title)
        
        The user has previously published these titles:
        \(recentTitles)
        
        \(imageContext)
        
        Constraints:
        - Make the smallest effective improvement, not a full rewrite
        - Tighten the wording and flow
        - Preserve the same meaning, tone, and topic
        - Stay close to the original title
        - If no improvement can be made on the post, return the orginal post
        - Return one improved version and nothing else
        """
        
        do {
            let responseText: String?
            
            if let image {
                responseText = try await model.generateContent(prompt, image).text
            } else {
                responseText = try await model.generateContent(prompt).text
            }
            
            let title = responseText
            ?? ""
            
            
            self.title = title.isEmpty ? nil : title
            titlesStatus = .success
            
        } catch {
            titlesStatus = .failed
            self.title = nil
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                titlesStatus = .notStarted
            }
        }
    }
    
    func remixTitle(_ posts: [Post], _ image: UIImage?, _ title: String) async {
        titlesStatus = .fetching
        self.title = nil
        
        let recentTitles = posts.map {"- \($0.title)"}
            .joined(separator: "\n")
        
        let imageContext: String
        if image != nil {
            imageContext = """
                The post includes an image. Use it as supporting context to better understand the title's intent. Do not introduce new topics that are not grounded in the title or image.
                """
        } else {
            imageContext = """
                The post does not include an image. Base your suggestion only on the original title and the user's previous titles. Do not invent visual details or new topics.
                """
        }
        
        let prompt = """
            You are helping remix a social media post title written by the user.
            
            This original post title already performed well:
            \(title)
            
            The user has previously published these titles:
            \(recentTitles)
            
            \(imageContext)
            
            Constraints:
            - Explore a different angle on the original post’s core idea
            - Create a fresh variation, not a completely new idea
            - Preserve the same topic, tone, and point of view
            - Keep a similar length and writing style
            - Return one remixed version and nothing else
            """
        
        do {
            let responseText: String?
            
            if let image {
                responseText = try await model.generateContent(prompt, image).text
            } else {
                responseText = try await model.generateContent(prompt).text
            }
            
            let title = responseText
            ?? ""
            
            
            self.title = title.isEmpty ? nil : title
            titlesStatus = .success
            
        } catch {
            titlesStatus = .failed
            self.title = nil
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                titlesStatus = .notStarted
            }
        }
    }
}
