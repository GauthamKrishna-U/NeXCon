// TaskModel.swift
// NeXCon — Data Layer
// Defines all data models used throughout the app

import Foundation
import SwiftUI

// MARK: - Task Category

/// Categories available for each task
enum TaskCategory: String, CaseIterable, Codable {
    case study    = "Study"
    case health   = "Health"
    case personal = "Personal"
    
    /// SF Symbol icon name for the category
    var icon: String {
        switch self {
        case .study:    return "book.fill"
        case .health:   return "heart.fill"
        case .personal: return "person.fill"
        }
    }
    
    /// Accent color associated with the category
    var color: Color {
        switch self {
        case .study:    return Color(red: 0.38, green: 0.55, blue: 1.0)   // Indigo-blue
        case .health:   return Color(red: 0.25, green: 0.82, blue: 0.60)  // Mint-green
        case .personal: return Color(red: 1.0,  green: 0.58, blue: 0.22)  // Warm orange
        }
    }
    
    /// Soft background tint for card backgrounds
    var softColor: Color {
        switch self {
        case .study:    return Color(red: 0.38, green: 0.55, blue: 1.0).opacity(0.12)
        case .health:   return Color(red: 0.25, green: 0.82, blue: 0.60).opacity(0.12)
        case .personal: return Color(red: 1.0,  green: 0.58, blue: 0.22).opacity(0.12)
        }
    }
}

// MARK: - Task Model

/// A single task item
struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, category: TaskCategory, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

// MARK: - Motivational Quote

/// A quote item displayed in the motivation card
struct MotivationalQuote {
    let text: String
    let author: String
    
    /// Static pool of motivational quotes
    static let all: [MotivationalQuote] = [
        MotivationalQuote(text: "Success is the sum of small efforts, repeated day in and day out.", author: "Robert Collier"),
        MotivationalQuote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson"),
        MotivationalQuote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
        MotivationalQuote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        MotivationalQuote(text: "It always seems impossible until it's done.", author: "Nelson Mandela"),
        MotivationalQuote(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
        MotivationalQuote(text: "Push yourself, because no one else is going to do it for you.", author: "Unknown"),
        MotivationalQuote(text: "Great things never come from comfort zones.", author: "Unknown"),
        MotivationalQuote(text: "Dream it. Wish it. Do it.", author: "Unknown"),
        MotivationalQuote(text: "Little by little, a little becomes a lot.", author: "Tanzanian Proverb"),
    ]
    
    /// Returns a quote based on the day of the year (rotates daily)
    static var daily: MotivationalQuote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayOfYear % all.count]
    }
}

// MARK: - Streak Model

/// Tracks the user's daily task completion streak
struct StreakData: Codable {
    var currentStreak: Int
    var lastCompletedDate: Date?
    
    init() {
        self.currentStreak = 0
        self.lastCompletedDate = nil
    }
    
    /// Whether the streak was maintained today
    var isActiveToday: Bool {
        guard let last = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(last)
    }
}
