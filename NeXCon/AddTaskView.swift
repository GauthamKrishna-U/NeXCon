// AddTaskView.swift
// NeXCon — Add Task Sheet
// Presents a bottom sheet form to create a new task

import SwiftUI

// MARK: - Add Task View

struct AddTaskView: View {
    
    // MARK: Dependencies
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: Local State
    @State private var taskTitle: String = ""
    @State private var selectedCategory: TaskCategory = .study
    @State private var titleError: Bool = false
    @State private var addButtonScale: CGFloat = 1.0
    
    // MARK: Focus
    @FocusState private var isTitleFocused: Bool
    
    // MARK: Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.nexDivider)
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                // Content
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Title field
                    titleField
                    
                    // Category picker
                    categoryPicker
                    
                    Spacer()
                    
                    // Add button
                    addButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.nexSubtext)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationCornerRadius(28)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isTitleFocused = true
            }
        }
    }
    
    // MARK: - Title Field
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Task Title", systemImage: "pencil")
                .font(NexFont.subhead)
                .foregroundColor(.nexSubtext)
            
            TextField("What do you need to do?", text: $taskTitle)
                .font(NexFont.body)
                .focused($isTitleFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.nexCardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    titleError ? Color.red.opacity(0.8) : Color.nexPrimary.opacity(isTitleFocused ? 0.6 : 0),
                                    lineWidth: 1.5
                                )
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isTitleFocused)
                .onChange(of: taskTitle) { _, _ in
                    if titleError { titleError = false }
                }
            
            if titleError {
                Text("Please enter a task title")
                    .font(NexFont.micro)
                    .foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: titleError)
    }
    
    // MARK: - Category Picker
    
    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Category", systemImage: "tag")
                .font(NexFont.subhead)
                .foregroundColor(.nexSubtext)
            
            HStack(spacing: 10) {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    categoryChip(category)
                }
            }
        }
    }
    
    private func categoryChip(_ category: TaskCategory) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(category.rawValue)
                    .font(NexFont.callout)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selectedCategory == category ? category.color : Color.nexCardBg)
            )
            .foregroundColor(selectedCategory == category ? .white : category.color)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        selectedCategory == category ? Color.clear : category.color.opacity(0.4),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(ButtonPressEffect())
    }
    
    // MARK: - Add Button
    
    private var addButton: some View {
        Button(action: handleAddTask) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add Task")
                    .font(NexFont.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NexGradients.headerGradient)
            )
            .nexLiftShadow()
        }
        .buttonStyle(ButtonPressEffect())
    }
    
    // MARK: - Actions
    
    private func handleAddTask() {
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                titleError = true
            }
            // Shake haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        // Success haptic
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        viewModel.addTask(title: taskTitle, category: selectedCategory)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    AddTaskView()
        .environmentObject(TaskViewModel())
}
