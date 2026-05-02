// TaskViewModel.swift
// NeXCon — ViewModel Layer
// Manages all app state, business logic, and UserDefaults persistence

import Foundation
import SwiftUI
import Combine

// MARK: - TaskViewModel

/// Central ViewModel for the NeXCon app.
/// Conforms to ObservableObject so SwiftUI views can reactively update.
final class TaskViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// The master list of all tasks
    @Published var tasks: [Task] = []
    
    /// Streak tracking data
    @Published var streak: StreakData = StreakData()
    
    /// Controls whether the Add Task sheet is showing
    @Published var showingAddTask: Bool = false
    
    /// Controls the animated entry of cards on load
    @Published var cardsAppeared: Bool = false
    
    // MARK: - UserDefaults Keys
    
    private enum StorageKey {
        static let tasks  = "nexcon_tasks"
        static let streak = "nexcon_streak"
    }
    
    // MARK: - Computed Properties
    
    /// Total number of tasks for today
    var totalTasks: Int { tasks.count }
    
    /// Number of completed tasks
    var completedTasks: Int { tasks.filter { $0.isCompleted }.count }
    
    /// Completion fraction (0.0 – 1.0) for the progress ring
    var completionProgress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    /// Completion percentage string
    var completionPercentageString: String {
        "\(Int(completionProgress * 100))%"
    }
    
    /// Time-appropriate greeting for the user
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default:      return "Good Night"
        }
    }
    
    /// Greeting emoji based on time of day
    var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "☀️"
        case 12..<17: return "⛅️"
        case 17..<21: return "🌆"
        default:      return "🌙"
        }
    }
    
    /// Today's date formatted for display
    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    /// Daily motivational quote (rotates per day)
    var dailyQuote: MotivationalQuote {
        MotivationalQuote.daily
    }
    
    // MARK: - Init
    
    init() {
        loadTasks()
        loadStreak()
        // Trigger card appear animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.cardsAppeared = true
            }
        }
    }
    
    // MARK: - Task CRUD
    
    /// Adds a new task to the list
    func addTask(title: String, category: TaskCategory) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTask = Task(title: title.trimmingCharacters(in: .whitespaces), category: category)
        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
            tasks.insert(newTask, at: 0)
        }
        saveTasks()
    }
    
    /// Toggles the completion state of a task
    func toggleTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            tasks[index].isCompleted.toggle()
        }
        saveTasks()
        updateStreak()
    }
    
    /// Deletes tasks at given offsets (for swipe-to-delete)
    func deleteTasks(at offsets: IndexSet) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            tasks.remove(atOffsets: offsets)
        }
        saveTasks()
        updateStreak()
    }
    
    /// Deletes a specific task by ID
    func deleteTask(_ task: Task) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            tasks.removeAll { $0.id == task.id }
        }
        saveTasks()
        updateStreak()
    }
    
    // MARK: - Streak Logic
    
    /// Updates the streak based on whether any task is completed today
    private func updateStreak() {
        let hasCompletedTaskToday = tasks.contains { $0.isCompleted }
        
        if hasCompletedTaskToday {
            if streak.isActiveToday {
                // Already counted today — no change needed
                return
            }
            
            // Check if yesterday was the last active day
            if let last = streak.lastCompletedDate,
               Calendar.current.isDateInYesterday(last) {
                streak.currentStreak += 1
            } else if streak.lastCompletedDate == nil {
                streak.currentStreak = 1
            } else {
                // Gap in streak — restart
                streak.currentStreak = 1
            }
            streak.lastCompletedDate = Date()
        } else {
            // No tasks completed today — check if streak should reset
            if let last = streak.lastCompletedDate,
               !Calendar.current.isDateInToday(last) &&
               !Calendar.current.isDateInYesterday(last) {
                streak.currentStreak = 0
                streak.lastCompletedDate = nil
            }
        }
        
        saveStreak()
    }
    
    // MARK: - Persistence
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: StorageKey.tasks)
        }
    }
    
    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.tasks),
              let decoded = try? JSONDecoder().decode([Task].self, from: data) else {
            // Seed with sample tasks on first launch
            tasks = Self.sampleTasks()
            return
        }
        tasks = decoded
    }
    
    private func saveStreak() {
        if let encoded = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(encoded, forKey: StorageKey.streak)
        }
    }
    
    private func loadStreak() {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.streak),
              let decoded = try? JSONDecoder().decode(StreakData.self, from: data) else {
            streak = StreakData()
            return
        }
        streak = decoded
    }
    
    // MARK: - Sample Data
    
    /// Sample tasks for first launch
    private static func sampleTasks() -> [Task] {
        [
            Task(title: "Review lecture notes", category: .study),
            Task(title: "30-minute morning run", category: .health, isCompleted: true),
            Task(title: "Complete assignment", category: .study),
            Task(title: "Call a friend", category: .personal),
            Task(title: "Drink 8 glasses of water", category: .health),
        ]
    }
}
