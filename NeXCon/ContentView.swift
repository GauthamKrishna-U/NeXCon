// ContentView.swift
// NeXCon — Main Dashboard View
// The primary screen: greeting, progress, streak, quote, and task list

import SwiftUI

// MARK: - Content View

struct ContentView: View {
    
    // MARK: Dependencies
    @EnvironmentObject var viewModel: TaskViewModel
    
    // MARK: Body
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Main scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. Header card
                    headerCard
                        .cardAppear(appeared: viewModel.cardsAppeared, delay: 0.0)
                    
                    // 2. Progress + Streak row
                    HStack(spacing: 14) {
                        progressCard
                        streakCard
                    }
                    .cardAppear(appeared: viewModel.cardsAppeared, delay: 0.1)
                    
                    // 3. Motivational quote
                    quoteCard
                        .cardAppear(appeared: viewModel.cardsAppeared, delay: 0.18)
                    
                    // 4. Task list
                    taskListSection
                        .cardAppear(appeared: viewModel.cardsAppeared, delay: 0.25)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 110) // Space above FAB
            }
            
            // Floating Add Button
            addTaskFAB
        }
        .sheet(isPresented: $viewModel.showingAddTask) {
            AddTaskView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            
            // Gradient background
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(NexGradients.headerGradient)
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 180, height: 180)
                    .offset(x: geo.size.width - 100, y: -40)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 120, height: 120)
                    .offset(x: geo.size.width - 30, y: 40)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(viewModel.greetingEmoji)
                        .font(.system(size: 28))
                    Text(viewModel.greeting)
                        .font(NexFont.title2)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text("Let's crush today's goals")
                    .font(NexFont.largeTitle)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer().frame(height: 4)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 13, weight: .medium))
                    Text(viewModel.todayDateString)
                        .font(NexFont.callout)
                }
                .foregroundColor(.white.opacity(0.75))
            }
            .padding(24)
        }
        .frame(height: 180)
        .nexLiftShadow()
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        VStack(spacing: 12) {
            ProgressRingView(progress: viewModel.completionProgress, size: 90, lineWidth: 9)
            
            VStack(spacing: 2) {
                Text("Progress")
                    .font(NexFont.subhead)
                    .foregroundColor(.nexSubtext)
                
                Text("\(viewModel.completedTasks)/\(viewModel.totalTasks) tasks")
                    .font(NexFont.micro)
                    .foregroundColor(.nexSubtext.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.nexCardBg)
        )
        .nexCardShadow()
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        VStack(spacing: 10) {
            
            // Flame icon with gradient background
            ZStack {
                Circle()
                    .fill(NexGradients.streakGradient)
                    .frame(width: 58, height: 58)
                
                Text("🔥")
                    .font(.system(size: 28))
            }
            
            // Streak count
            Text("\(viewModel.streak.currentStreak)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.nexText)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.5), value: viewModel.streak.currentStreak)
            
            Text("Day Streak")
                .font(NexFont.subhead)
                .foregroundColor(.nexSubtext)
            
            // Active indicator
            if viewModel.streak.isActiveToday {
                Label("Active", systemImage: "checkmark.circle.fill")
                    .font(NexFont.micro)
                    .foregroundColor(Color(red: 0.25, green: 0.82, blue: 0.60))
            } else {
                Text("Complete a task!")
                    .font(NexFont.micro)
                    .foregroundColor(.nexSubtext.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.nexCardBg)
        )
        .nexCardShadow()
    }
    
    // MARK: - Quote Card
    
    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header
            HStack(spacing: 8) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.nexSecondary)
                Text("Daily Motivation")
                    .font(NexFont.subhead)
                    .foregroundColor(.nexSubtext)
                Spacer()
            }
            
            // Divider
            Rectangle()
                .fill(Color.nexDivider)
                .frame(height: 1)
            
            // Quote text
            Text(viewModel.dailyQuote.text)
                .font(NexFont.callout)
                .foregroundColor(.nexText)
                .italic()
                .lineSpacing(5)
            
            // Author
            HStack {
                Spacer()
                Text("— \(viewModel.dailyQuote.author)")
                    .font(NexFont.micro)
                    .foregroundColor(.nexSubtext)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.nexCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.nexPrimary.opacity(0.3), Color.nexSecondary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .nexCardShadow()
    }
    
    // MARK: - Task List Section
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Tasks")
                        .font(NexFont.title3)
                        .foregroundColor(.nexText)
                    Text("\(viewModel.tasks.count) items")
                        .font(NexFont.micro)
                        .foregroundColor(.nexSubtext)
                }
                Spacer()
                
                // Inline add button
                Button(action: { viewModel.showingAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(NexGradients.headerGradient)
                }
                .buttonStyle(ButtonPressEffect())
            }
            
            // Task cards
            if viewModel.tasks.isEmpty {
                emptyState
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(viewModel.tasks.enumerated()), id: \.element.id) { index, task in
                        TaskCardView(
                            task: task,
                            onToggle: { viewModel.toggleTask(task) },
                            onDelete: { viewModel.deleteTask(task) }
                        )
                        .transition(
                            .asymmetric(
                                insertion: .push(from: .leading).combined(with: .opacity),
                                removal:   .push(from: .trailing).combined(with: .opacity)
                            )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.badge.plus")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(NexGradients.headerGradient)
            
            Text("No tasks yet")
                .font(NexFont.title3)
                .foregroundColor(.nexText)
            
            Text("Tap + to add your first task for today")
                .font(NexFont.callout)
                .foregroundColor(.nexSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.nexCardBg)
        )
        .nexCardShadow()
    }
    
    // MARK: - Floating Action Button
    
    private var addTaskFAB: some View {
        Button(action: { viewModel.showingAddTask = true }) {
            ZStack {
                Circle()
                    .fill(NexGradients.headerGradient)
                    .frame(width: 60, height: 60)
                    .nexLiftShadow()
                
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ButtonPressEffect())
        .padding(.trailing, 22)
        .padding(.bottom, 36)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(TaskViewModel())
}
