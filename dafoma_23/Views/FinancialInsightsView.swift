//
//  FinancialInsightsView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct FinancialInsightsView: View {
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var aiService = AIRecommendationService.shared
    @State private var selectedTipCategory: AIRecommendationService.FinancialTip.Category?
    @State private var showTipDetail = false
    @State private var selectedTip: AIRecommendationService.FinancialTip?
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        headerSection
                        
                        // Daily tip
                        dailyTipSection
                        
                        // Financial categories
                        categoriesSection
                        
                        // Learning challenges
                        challengesSection
                        
                        // Progress insights
                        progressInsightsSection
                        
                        // Vocabulary spotlight
                        vocabularySpotlightSection
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                aiService.refreshDailyTip()
                progressViewModel.refreshData()
            }
        }
        .sheet(isPresented: $showTipDetail) {
            if let tip = selectedTip {
                TipDetailView(tip: tip)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Financial Insights")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text("Build wealth through language mastery")
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                Spacer()
                
                // Streak flame
                StreakFlame(
                    streakCount: progressViewModel.getCurrentStreak(),
                    isActive: progressViewModel.getCurrentStreak() > 0
                )
            }
            
            // Financial stats
            HStack(spacing: Spacing.lg) {
                financialStatCard(
                    icon: "dollarsign.circle.fill",
                    value: "$\(calculatePotentialEarnings())",
                    label: "Potential Earnings",
                    color: ColorThemes.financialGreen
                )
                
                financialStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(progressViewModel.getOverallProgress() * 100))%",
                    label: "Financial Literacy",
                    color: ColorThemes.financialBlue
                )
                
                financialStatCard(
                    icon: "brain.head.profile",
                    value: "\(progressViewModel.userProgress.achievements.count)",
                    label: "Skills Unlocked",
                    color: ColorThemes.financialGold
                )
            }
        }
        .padding(.top, Spacing.lg)
    }
    
    private func financialStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.headline.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(label)
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .glassStyle()
    }
    
    // MARK: - Daily Tip Section
    private var dailyTipSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("💡 Today's Financial Tip")
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
                
                Button("Refresh") {
                    aiService.refreshDailyTip()
                }
                .font(Typography.body)
                .foregroundColor(ColorThemes.primaryBlue)
            }
            
            if let tip = aiService.dailyTip {
                DailyTipCard(tip: tip) {
                    selectedTip = tip
                    showTipDetail = true
                }
            } else {
                LoadingTipCard()
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Financial Categories")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(AIRecommendationService.FinancialTip.Category.allCases, id: \.self) { category in
                        FinancialCategoryCard(category: category, isSelected: selectedTipCategory == category) {
                            selectedTipCategory = selectedTipCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - Challenges Section
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("🎯 Learning Challenges")
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to challenges view
                }
                .font(Typography.body)
                .foregroundColor(ColorThemes.primaryBlue)
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(aiService.getSuggestedChallenges().prefix(3), id: \.id) { challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
        }
    }
    
    // MARK: - Progress Insights Section
    private var progressInsightsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("📊 Your Progress Insights")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            VStack(spacing: Spacing.md) {
                // Improvement suggestions
                InsightCard(
                    icon: "target",
                    title: "Areas to Improve",
                    content: progressViewModel.getImprovementSuggestions().first ?? "Keep up the great work!",
                    color: ColorThemes.warning
                )
                
                // Motivational message
                InsightCard(
                    icon: "star.fill",
                    title: "Motivation",
                    content: progressViewModel.getMotivationalMessage(),
                    color: ColorThemes.success
                )
                
                // Weekly goal progress
                let weeklyProgress = progressViewModel.getWeeklyGoalProgress()
                InsightCard(
                    icon: "calendar",
                    title: "Weekly Goal",
                    content: "You've completed \(Int(weeklyProgress * 100))% of your weekly study goal. \(weeklyProgress >= 1.0 ? "Excellent!" : "Keep going!")",
                    color: weeklyProgress >= 0.8 ? ColorThemes.success : ColorThemes.primaryBlue
                )
            }
        }
    }
    
    // MARK: - Vocabulary Spotlight Section
    private var vocabularySpotlightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("📚 Vocabulary Spotlight")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                VocabularySpotlightCard(
                    word: "Diversification",
                    definition: "Spreading investments across different assets to reduce risk",
                    example: "Portfolio diversification helps protect against market volatility.",
                    tip: "Use this word when discussing investment strategies in professional settings."
                )
                
                VocabularySpotlightCard(
                    word: "Compound Interest",
                    definition: "Interest calculated on initial principal and accumulated interest",
                    example: "Compound interest can significantly grow your savings over time.",
                    tip: "Einstein called it 'the eighth wonder of the world' - perfect conversation starter!"
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func calculatePotentialEarnings() -> Int {
        let baseEarnings = 50000
        let skillMultiplier = Double(progressViewModel.userProgress.level.rawValue) * 0.1
        let completionBonus = progressViewModel.getOverallProgress() * 10000
        return Int(Double(baseEarnings) * (1 + skillMultiplier) + completionBonus)
    }
}

// MARK: - Daily Tip Card
struct DailyTipCard: View {
    let tip: AIRecommendationService.FinancialTip
    let action: () -> Void
    
    var body: some View {
        InteractiveCard(action: action) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: tip.category.icon)
                        .font(.title2)
                        .foregroundColor(categoryColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tip.title)
                            .font(Typography.headline)
                            .foregroundColor(ColorThemes.textPrimary)
                        
                        Text(tip.category.rawValue)
                            .font(Typography.caption1)
                            .foregroundColor(categoryColor)
                    }
                    
                    Spacer()
                    
                    DifficultyBadge(tip.difficulty, compact: true)
                }
                
                Text(tip.content)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .lineLimit(3)
                
                if tip.actionable {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundColor(ColorThemes.financialGold)
                        
                        Text("Tap to learn more and practice")
                            .font(Typography.caption1)
                            .foregroundColor(ColorThemes.textTertiary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle")
                            .font(.body)
                            .foregroundColor(ColorThemes.primaryBlue)
                    }
                }
            }
            .padding(Spacing.md)
        }
    }
    
    private var categoryColor: Color {
        switch tip.category {
        case .budgeting: return ColorThemes.financialBlue
        case .investing: return ColorThemes.financialGreen
        case .saving: return ColorThemes.success
        case .creditDebt: return ColorThemes.warning
        case .careerFinance: return ColorThemes.primaryPurple
        case .languageLearning: return ColorThemes.primaryBlue
        }
    }
}

// MARK: - Loading Tip Card
struct LoadingTipCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Circle()
                    .fill(ColorThemes.surfaceSecondary)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorThemes.surfaceSecondary)
                        .frame(width: 150, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorThemes.surfaceSecondary)
                        .frame(width: 100, height: 12)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorThemes.surfaceSecondary)
                        .frame(height: 14)
                }
            }
        }
        .padding(Spacing.md)
        .cardStyle()
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Financial Category Card
struct FinancialCategoryCard: View {
    let category: AIRecommendationService.FinancialTip.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? ColorThemes.textPrimary : categoryColor)
                
                Text(category.rawValue)
                    .font(Typography.caption1.weight(.medium))
                    .foregroundColor(isSelected ? ColorThemes.textPrimary : ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(Spacing.md)
            .frame(width: 110, height: 90)
            .background(isSelected ? categoryColor.opacity(0.2) : ColorThemes.surfacePrimary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? categoryColor : ColorThemes.borderPrimary, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(AnimationPresets.spring, value: isSelected)
    }
    
    private var categoryColor: Color {
        switch category {
        case .budgeting: return ColorThemes.financialBlue
        case .investing: return ColorThemes.financialGreen
        case .saving: return ColorThemes.success
        case .creditDebt: return ColorThemes.warning
        case .careerFinance: return ColorThemes.primaryPurple
        case .languageLearning: return ColorThemes.primaryBlue
        }
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: LearningChallenge
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Progress ring
            ProgressRing(
                progress: challenge.progress,
                lineWidth: 4,
                size: 50,
                showPercentage: false
            )
            
            // Challenge info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(challenge.title)
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ColorThemes.success)
                            .font(.body)
                    }
                }
                
                Text(challenge.description)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "gift.fill")
                        .font(.caption)
                        .foregroundColor(ColorThemes.financialGold)
                    
                    Text("Reward: \(challenge.reward)")
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textTertiary)
                        .lineLimit(1)
                    
                    Spacer()
                }
            }
        }
        .padding(Spacing.md)
        .cardStyle()
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Text(content)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .glassStyle()
    }
}

// MARK: - Vocabulary Spotlight Card
struct VocabularySpotlightCard: View {
    let word: String
    let definition: String
    let example: String
    let tip: String
    
    @State private var showDetails = false
    
    var body: some View {
        InteractiveCard {
            withAnimation(AnimationPresets.spring) {
                showDetails.toggle()
            }
        } content: {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text(word)
                        .font(Typography.title3.weight(.bold))
                        .foregroundColor(ColorThemes.primaryBlue)
                    
                    Spacer()
                    
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.body)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                if showDetails {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(definition)
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Example:")
                                .font(Typography.caption1.weight(.medium))
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text(example)
                                .font(Typography.body)
                                .foregroundColor(ColorThemes.textPrimary)
                                .italic()
                        }
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("💡 Pro Tip:")
                                .font(Typography.caption1.weight(.medium))
                                .foregroundColor(ColorThemes.financialGold)
                            
                            Text(tip)
                                .font(Typography.body)
                                .foregroundColor(ColorThemes.textSecondary)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(Spacing.md)
        }
    }
}

// MARK: - Tip Detail View
struct TipDetailView: View {
    let tip: AIRecommendationService.FinancialTip
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: tip.category.icon)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(categoryColor)
                            }
                            
                            Text(tip.title)
                                .font(Typography.title1)
                                .foregroundColor(ColorThemes.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Text(tip.category.rawValue)
                                    .font(Typography.body)
                                    .foregroundColor(categoryColor)
                                
                                Text("•")
                                    .foregroundColor(ColorThemes.textTertiary)
                                
                                DifficultyBadge(tip.difficulty)
                            }
                        }
                        .padding(.top, Spacing.lg)
                        
                        // Content
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Financial Insight")
                                .font(Typography.headline)
                                .foregroundColor(ColorThemes.textPrimary)
                            
                            Text(tip.content)
                                .font(Typography.body)
                                .foregroundColor(ColorThemes.textSecondary)
                        }
                        .padding(Spacing.md)
                        .cardStyle()
                        
                        // Related vocabulary
                        if !tip.relatedVocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Key Vocabulary")
                                    .font(Typography.headline)
                                    .foregroundColor(ColorThemes.textPrimary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.sm) {
                                    ForEach(tip.relatedVocabulary, id: \.self) { word in
                                        Text(word)
                                            .font(Typography.body)
                                            .foregroundColor(ColorThemes.textPrimary)
                                            .padding(Spacing.sm)
                                            .background(ColorThemes.primaryBlue.opacity(0.1))
                                            .cornerRadius(CornerRadius.small)
                                    }
                                }
                            }
                            .padding(Spacing.md)
                            .cardStyle()
                        }
                        
                        // Action button
                        if tip.actionable {
                            GlowingButton("Practice This Concept", icon: "play.circle.fill") {
                                // Navigate to related lesson or practice
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding(.horizontal, Spacing.lg)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationTitle("Financial Tip")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var categoryColor: Color {
        switch tip.category {
        case .budgeting: return ColorThemes.financialBlue
        case .investing: return ColorThemes.financialGreen
        case .saving: return ColorThemes.success
        case .creditDebt: return ColorThemes.warning
        case .careerFinance: return ColorThemes.primaryPurple
        case .languageLearning: return ColorThemes.primaryBlue
        }
    }
}
