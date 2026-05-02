// TaskCardView.swift
// NeXCon — Task Card Component
// A premium card UI for displaying a single task with swipe-to-delete

import SwiftUI

// MARK: - Task Card View

struct TaskCardView: View {
    
    // MARK: Dependencies
    let task: Task
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    // MARK: Local State
    @State private var isPressed: Bool = false
    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteButton: Bool = false
    
    // MARK: Body
    
    var body: some View {
        ZStack(alignment: .trailing) {
            
            // Delete background revealed on swipe
            deleteBackground
            
            // Main card content
            cardContent
                .offset(x: dragOffset)
                .gesture(swipeGesture)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        HStack(spacing: 14) {
            
            // Category badge
            categoryBadge
            
            // Task text
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(NexFont.headline)
                    .foregroundColor(.nexText)
                    .strikethrough(task.isCompleted, color: .nexSubtext)
                    .opacity(task.isCompleted ? 0.5 : 1.0)
                    .animation(.easeInOut(duration: 0.25), value: task.isCompleted)
                
                Text(task.category.rawValue)
                    .font(NexFont.caption)
                    .foregroundColor(task.category.color)
            }
            
            Spacer()
            
            // Completion toggle
            completionToggle
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.nexCardBg)
                .overlay(
                    // Subtle left accent bar
                    HStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(task.category.color)
                            .frame(width: 4)
                        Spacer()
                    }
                )
        )
        .nexCardShadow()
    }
    
    // MARK: - Category Badge
    
    private var categoryBadge: some View {
        ZStack {
            Circle()
                .fill(task.category.softColor)
                .frame(width: 44, height: 44)
            
            Image(systemName: task.category.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(task.category.color)
        }
    }
    
    // MARK: - Completion Toggle
    
    private var completionToggle: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                onToggle()
            }
        }) {
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? task.category.color : Color.nexDivider,
                        lineWidth: 2
                    )
                    .frame(width: 28, height: 28)
                
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(task.category.color)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(ButtonPressEffect())
        .animation(.spring(response: 0.3, dampingFraction: 0.65), value: task.isCompleted)
    }
    
    // MARK: - Delete Background
    
    private var deleteBackground: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                onDelete()
            }
        }) {
            HStack {
                Spacer()
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.trailing, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.85))
            )
        }
        .opacity(showDeleteButton ? 1 : 0)
    }
    
    // MARK: - Swipe Gesture
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard value.translation.width < 0 else {
                    // Reset if swiping right
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                        showDeleteButton = false
                    }
                    return
                }
                dragOffset = max(value.translation.width, -90)
                showDeleteButton = dragOffset < -20
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    if value.translation.width < -60 {
                        dragOffset = -80
                        showDeleteButton = true
                    } else {
                        dragOffset = 0
                        showDeleteButton = false
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        TaskCardView(
            task: Task(title: "Review lecture notes", category: .study),
            onToggle: {},
            onDelete: {}
        )
        TaskCardView(
            task: Task(title: "Morning run 🏃", category: .health, isCompleted: true),
            onToggle: {},
            onDelete: {}
        )
        TaskCardView(
            task: Task(title: "Call a friend", category: .personal),
            onToggle: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
