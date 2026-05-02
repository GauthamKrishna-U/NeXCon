// ProgressRingView.swift
// NeXCon — Progress Ring Component
// Animated circular progress indicator with gradient stroke

import SwiftUI

// MARK: - Progress Ring View

struct ProgressRingView: View {
    
    // MARK: Properties
    let progress: Double     // 0.0 – 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    
    // MARK: Initializer
    init(progress: Double, size: CGFloat = 120, lineWidth: CGFloat = 12) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
    }
    
    // MARK: State
    @State private var animatedProgress: Double = 0
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            // Track ring (background)
            Circle()
                .stroke(Color.nexPrimary.opacity(0.15), lineWidth: lineWidth)
            
            // Animated progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    NexGradients.progressRing,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: animatedProgress)
            
            // Center text
            VStack(spacing: 2) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundColor(.nexText)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.5), value: animatedProgress)
                
                Text("Done")
                    .font(.system(size: size * 0.11, weight: .medium, design: .rounded))
                    .foregroundColor(.nexSubtext)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75).delay(0.3)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 30) {
        ProgressRingView(progress: 0.0)
        ProgressRingView(progress: 0.6)
        ProgressRingView(progress: 1.0)
    }
    .padding()
}
