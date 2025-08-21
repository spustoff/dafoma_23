//
//  CustomControls.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

// MARK: - Animated Progress Ring
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let showPercentage: Bool
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, lineWidth: CGFloat = 8, size: CGFloat = 100, showPercentage: Bool = true) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.showPercentage = showPercentage
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(ColorThemes.surfaceSecondary, lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    ColorThemes.primaryGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            if showPercentage {
                Text("\(Int(animatedProgress * 100))%")
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(AnimationPresets.spring.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(AnimationPresets.easeInOut) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Glowing Button
struct GlowingButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let isEnabled: Bool
    let style: ButtonStyle
    
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0.5
    
    enum ButtonStyle {
        case primary, secondary, accent, success, warning, danger
        
        var colors: (background: LinearGradient, glow: Color) {
            switch self {
            case .primary:
                return (ColorThemes.primaryGradient, ColorThemes.primaryBlue)
            case .secondary:
                return (LinearGradient(colors: [ColorThemes.surfacePrimary], startPoint: .top, endPoint: .bottom), ColorThemes.textSecondary)
            case .accent:
                return (ColorThemes.accentGradient, ColorThemes.accentOrange)
            case .success:
                return (LinearGradient(colors: [ColorThemes.success], startPoint: .top, endPoint: .bottom), ColorThemes.success)
            case .warning:
                return (LinearGradient(colors: [ColorThemes.warning], startPoint: .top, endPoint: .bottom), ColorThemes.warning)
            case .danger:
                return (LinearGradient(colors: [ColorThemes.error], startPoint: .top, endPoint: .bottom), ColorThemes.error)
            }
        }
    }
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
        self.isEnabled = isEnabled
        self.style = style
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(Typography.body.weight(.semibold))
                }
                
                Text(title)
                    .font(Typography.body.weight(.semibold))
            }
            .foregroundColor(ColorThemes.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(style.colors.background)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(ColorThemes.borderPrimary, lineWidth: 1)
            )
            .shadow(color: style.colors.glow.opacity(glowIntensity * 0.6), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AnimationPresets.easeOut) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    
    @State private var isPressed = false
    
    init(_ icon: String, backgroundColor: Color = ColorThemes.primaryBlue, action: @escaping () -> Void) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(ColorThemes.textPrimary)
                .frame(width: 56, height: 56)
                .background(backgroundColor)
                .cornerRadius(28)
                .shadow(color: backgroundColor.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AnimationPresets.spring) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Interactive Card
struct InteractiveCard<Content: View>: View {
    let content: Content
    let action: (() -> Void)?
    
    @State private var isPressed = false
    @State private var offset = CGSize.zero
    
    init(action: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(offset)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AnimationPresets.spring) {
                isPressed = pressing
            }
        }, perform: {})
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(AnimationPresets.easeOut) {
                        offset = CGSize(width: gesture.translation.width * 0.1, height: gesture.translation.height * 0.1)
                    }
                }
                .onEnded { _ in
                    withAnimation(AnimationPresets.spring) {
                        offset = .zero
                    }
                }
        )
    }
    
    private var cardContent: some View {
        content
            .cardStyle()
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int
    let duration: Double
    let formatter: NumberFormatter?
    
    @State private var animatedValue: Int = 0
    
    init(value: Int, duration: Double = 1.0, formatter: NumberFormatter? = nil) {
        self.value = value
        self.duration = duration
        self.formatter = formatter
    }
    
    var body: some View {
        Text(formattedValue)
            .font(Typography.title1)
            .foregroundColor(ColorThemes.textPrimary)
            .onAppear {
                animateCounter()
            }
            .onChange(of: value) { _ in
                animateCounter()
            }
    }
    
    private var formattedValue: String {
        if let formatter = formatter {
            return formatter.string(from: NSNumber(value: animatedValue)) ?? "\(animatedValue)"
        }
        return "\(animatedValue)"
    }
    
    private func animateCounter() {
        let steps = 30
        let stepValue = value / steps
        let stepDuration = duration / Double(steps)
        
        animatedValue = 0
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) {
                withAnimation(AnimationPresets.easeOut) {
                    if i == steps {
                        animatedValue = value
                    } else {
                        animatedValue = stepValue * i
                    }
                }
            }
        }
    }
}

// MARK: - Swipe Action Button
struct SwipeActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted = false
    
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .fill(color.opacity(0.2))
                .frame(height: 60)
            
            // Success state
            if isCompleted {
                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(ColorThemes.success)
                        .font(.title2.weight(.bold))
                    Text("Completed!")
                        .foregroundColor(ColorThemes.success)
                        .font(Typography.headline)
                }
            } else {
                // Normal state
                HStack {
                    // Drag indicator
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .foregroundColor(ColorThemes.textPrimary)
                            .font(.title3.weight(.bold))
                    }
                    .offset(x: dragOffset)
                    
                    Spacer()
                    
                    Text(title)
                        .foregroundColor(.white)
                        .opacity(dragOffset == 0 ? 1.0 : 0.5)
                    
                    Spacer()
                }
                .padding(.horizontal, Spacing.sm)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = min(swipeThreshold, max(0, gesture.translation.width))
                }
                .onEnded { value in
                    if dragOffset >= swipeThreshold {
                        // Complete action
                        withAnimation(AnimationPresets.spring) {
                            isCompleted = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            action()
                        }
                    } else {
                        // Reset
                        withAnimation(AnimationPresets.spring) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - Skill Level Indicator
struct SkillLevelIndicator: View {
    let level: UserProgress.UserLevel
    let experience: Int
    let showProgress: Bool
    
    @State private var animatedProgress: Double = 0
    
    init(level: UserProgress.UserLevel, experience: Int, showProgress: Bool = true) {
        self.level = level
        self.experience = experience
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Level icon and title
            HStack(spacing: Spacing.sm) {
                Image(systemName: level.icon)
                    .foregroundColor(levelColor)
                    .font(.title2.weight(.bold))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text("\(experience) XP")
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textSecondary)
                }
            }
            
            if showProgress {
                // Progress to next level
                let nextLevel = UserProgress.UserLevel.allCases.first { $0.rawValue > level.rawValue }
                if let next = nextLevel {
                    let currentExp = experience - level.experienceRequired
                    let expNeeded = next.experienceRequired - level.experienceRequired
                    let progress = expNeeded > 0 ? Double(currentExp) / Double(expNeeded) : 1.0
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress to \(next.title)")
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Spacer()
                            
                            Text("\(max(0, next.experienceRequired - experience)) XP to go")
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ColorThemes.surfaceSecondary)
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(levelColor)
                                .frame(width: max(0, 200 * animatedProgress), height: 4)
                                .animation(AnimationPresets.easeInOut, value: animatedProgress)
                        }
                    }
                    .onAppear {
                        withAnimation(AnimationPresets.spring.delay(0.5)) {
                            animatedProgress = progress
                        }
                    }
                    .onChange(of: experience) { _ in
                        let newProgress = expNeeded > 0 ? Double(max(0, experience - level.experienceRequired)) / Double(expNeeded) : 1.0
                        withAnimation(AnimationPresets.easeInOut) {
                            animatedProgress = newProgress
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .glassStyle()
    }
    
    private var levelColor: Color {
        switch level {
        case .novice: return Color.gray
        case .beginner: return ColorThemes.success
        case .intermediate: return ColorThemes.primaryBlue
        case .advanced: return ColorThemes.primaryPurple
        case .expert: return ColorThemes.accentOrange
        case .master: return ColorThemes.financialGold
        }
    }
}

// MARK: - Streak Flame
struct StreakFlame: View {
    let streakCount: Int
    let isActive: Bool
    
    @State private var flameScale: CGFloat = 1.0
    @State private var flameOpacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                // Flame background
                Image(systemName: "flame.fill")
                    .font(.title.weight(.bold))
                    .foregroundColor(flameColor)
                    .scaleEffect(flameScale)
                    .opacity(flameOpacity)
                
                // Streak number
                Text("\(streakCount)")
                    .font(Typography.caption1.weight(.bold))
                    .foregroundColor(ColorThemes.textPrimary)
                    .offset(y: 2)
            }
            
            Text(streakCount == 1 ? "day" : "days")
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .onAppear {
            if isActive {
                startFlameAnimation()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startFlameAnimation()
            } else {
                stopFlameAnimation()
            }
        }
    }
    
    private var flameColor: Color {
        if !isActive {
            return Color.gray
        }
        
        switch streakCount {
        case 1...6: return ColorThemes.accentOrange
        case 7...29: return ColorThemes.error
        case 30...99: return ColorThemes.primaryBlue
        default: return ColorThemes.financialGold
        }
    }
    
    private func startFlameAnimation() {
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            flameScale = 1.1
        }
        
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            flameOpacity = 0.8
        }
    }
    
    private func stopFlameAnimation() {
        withAnimation(AnimationPresets.easeOut) {
            flameScale = 1.0
            flameOpacity = 0.5
        }
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    let size: CGFloat
    
    @State private var isUnlocked = false
    @State private var rotationAngle: Double = 0
    
    init(achievement: Achievement, size: CGFloat = 60) {
        self.achievement = achievement
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(categoryColor.opacity(0.2))
                .frame(width: size, height: size)
            
            // Border
            Circle()
                .stroke(categoryColor, lineWidth: 3)
                .frame(width: size, height: size)
            
            // Icon
            Image(systemName: achievement.icon)
                .font(.title2.weight(.bold))
                .foregroundColor(categoryColor)
                .rotationEffect(.degrees(rotationAngle))
        }
        .scaleEffect(isUnlocked ? 1.0 : 0.8)
        .opacity(isUnlocked ? 1.0 : 0.7)
        .onAppear {
            withAnimation(AnimationPresets.spring.delay(0.3)) {
                isUnlocked = true
            }
            
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
    
    private var categoryColor: Color {
        switch achievement.category {
        case .streak: return ColorThemes.accentOrange
        case .completion: return ColorThemes.success
        case .time: return ColorThemes.primaryBlue
        case .financial: return ColorThemes.financialGold
        case .social: return ColorThemes.primaryPurple
        }
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: LanguageCourse.DifficultyLevel
    let compact: Bool
    
    init(_ difficulty: LanguageCourse.DifficultyLevel, compact: Bool = false) {
        self.difficulty = difficulty
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            // Difficulty dots
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < difficultyLevel ? difficultyColor : Color.gray.opacity(0.3))
                        .frame(width: compact ? 4 : 6, height: compact ? 4 : 6)
                }
            }
            
            if !compact {
                Text(difficulty.rawValue)
                    .font(Typography.caption1.weight(.medium))
                    .foregroundColor(difficultyColor)
            }
        }
        .padding(.horizontal, compact ? Spacing.xs : Spacing.sm)
        .padding(.vertical, compact ? 2 : Spacing.xs)
        .background(difficultyColor.opacity(0.1))
        .cornerRadius(compact ? 8 : CornerRadius.small)
    }
    
    private var difficultyLevel: Int {
        switch difficulty {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return ColorThemes.success
        case .intermediate: return ColorThemes.warning
        case .advanced: return ColorThemes.error
        }
    }
}
