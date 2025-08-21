//
//  ContentView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @State private var selectedTab = 0
    @State private var showGestureGuide = false
    
    var body: some View {
        Group {
            if onboardingViewModel.isCompleted {
                mainAppView
            } else {
                OnboardingView()
                    .environmentObject(onboardingViewModel)
            }
        }
        .onAppear {
            // Check if user wants to see gesture guide
            if UserDefaults.standard.bool(forKey: "ShouldShowGestureGuide") {
                showGestureGuide = true
                UserDefaults.standard.set(false, forKey: "ShouldShowGestureGuide")
            }
        }
        .sheet(isPresented: $showGestureGuide) {
            GestureGuideView()
        }
    }
    
    // MARK: - Main App View
    private var mainAppView: some View {
        ZStack {
            ColorThemes.backgroundGradient
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Learning Tab
                LanguageLearningView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "book.fill" : "book")
                        Text("Learn")
                    }
                    .tag(0)
                
                // Financial Insights Tab
                FinancialInsightsView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "dollarsign.circle.fill" : "dollarsign.circle")
                        Text("Insights")
                    }
                    .tag(1)
                
                // Progress Tab
                ProgressView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "chart.line.uptrend.xyaxis" : "chart.bar")
                        Text("Progress")
                    }
                    .tag(2)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                        Text("Profile")
                    }
                    .tag(3)
            }
            .accentColor(ColorThemes.primaryBlue)
            .background(ColorThemes.backgroundPrimary)
        }
    }
}

// MARK: - Progress View
struct ProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    @State private var showAchievements = false
    @State private var showAnalytics = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        headerSection
                        
                        // Level and experience
                        levelSection
                        
                        // Goals progress
                        goalsSection
                        
                        // Streak section
                        streakSection
                        
                        // Recent achievements
                        achievementsSection
                        
                        // Statistics
                        statisticsSection
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                viewModel.refreshData()
            }
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text(viewModel.getMotivationalMessage())
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                Spacer()
                
                Button {
                    showAnalytics = true
                } label: {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title2)
                        .foregroundColor(ColorThemes.primaryBlue)
                }
            }
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Level Section
    private var levelSection: some View {
        SkillLevelIndicator(
            level: viewModel.getCurrentLevel(),
            experience: viewModel.userProgress.experience,
            showProgress: true
        )
    }
    
    // MARK: - Goals Section
    private var goalsSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Daily & Weekly Goals")
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
            }
            
            HStack(spacing: Spacing.lg) {
                goalCard(
                    title: "Daily Goal",
                    progress: viewModel.getDailyGoalProgress(),
                    value: "\(viewModel.getTodayStudyTime())",
                    target: "\(viewModel.userProgress.dailyGoal) min",
                    color: ColorThemes.primaryBlue
                )
                
                goalCard(
                    title: "Weekly Goal",
                    progress: viewModel.getWeeklyGoalProgress(),
                    value: "\(viewModel.getThisWeekStudyTime())",
                    target: "\(viewModel.userProgress.weeklyGoal) min",
                    color: ColorThemes.success
                )
            }
        }
    }
    
    private func goalCard(title: String, progress: Double, value: String, target: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorThemes.textPrimary)
            
            ProgressRing(
                progress: progress,
                lineWidth: 6,
                size: 80,
                showPercentage: false
            )
            
            VStack(spacing: 2) {
                Text(value)
                    .font(Typography.title3.weight(.bold))
                    .foregroundColor(color)
                
                Text("of \(target)")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        HStack(spacing: Spacing.lg) {
            streakCard(
                title: "Current Streak",
                value: viewModel.getCurrentStreak(),
                icon: "flame.fill",
                color: ColorThemes.accentOrange
            )
            
            streakCard(
                title: "Longest Streak",
                value: viewModel.getLongestStreak(),
                icon: "trophy.fill",
                color: ColorThemes.financialGold
            )
        }
    }
    
    private func streakCard(title: String, value: Int, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(value)")
                .font(Typography.title1.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(title)
                .font(Typography.caption1)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
            
            Text(value == 1 ? "day" : "days")
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Achievements")
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    showAchievements = true
                }
                .font(Typography.body)
                .foregroundColor(ColorThemes.primaryBlue)
            }
            
            if viewModel.userProgress.achievements.isEmpty {
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 50))
                        .foregroundColor(ColorThemes.textTertiary)
                    
                    Text("Start learning to unlock achievements!")
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.xl)
                .cardStyle()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(viewModel.getRecentAchievements()) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Statistics")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.md) {
                statCard(
                    icon: "book.fill",
                    title: "Lessons Completed",
                    value: "\(viewModel.userProgress.totalLessonsCompleted)",
                    color: ColorThemes.primaryBlue
                )
                
                statCard(
                    icon: "clock.fill",
                    title: "Study Time",
                    value: viewModel.formatTime(viewModel.userProgress.totalTimeSpent),
                    color: ColorThemes.success
                )
                
                statCard(
                    icon: "percent",
                    title: "Accuracy",
                    value: "\(Int(viewModel.getAverageAccuracy()))%",
                    color: ColorThemes.warning
                )
                
                statCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Consistency",
                    value: "\(Int(viewModel.getConsistencyScore()))%",
                    color: ColorThemes.primaryPurple
                )
            }
        }
    }
    
    private func statCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(Typography.title3.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(title)
                .font(Typography.caption1)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .glassStyle()
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            AchievementBadge(achievement: achievement, size: 50)
            
            Text(achievement.title)
                .font(Typography.caption1.weight(.medium))
                .foregroundColor(ColorThemes.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(formatDate(achievement.unlockedDate))
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textTertiary)
        }
        .padding(Spacing.sm)
        .frame(width: 120, height: 120)
        .glassStyle()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var progressViewModel = ProgressViewModel()
    @State private var showSettings = false
    @State private var showGestureGuide = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Profile header
                        profileHeader
                        
                        // Quick stats
                        quickStats
                        
                        // Settings sections
                        settingsSection
                        
                        // Help section
                        helpSection
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showGestureGuide) {
            GestureGuideView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(ColorThemes.primaryGradient)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(ColorThemes.textPrimary)
            }
            
            // User info
            VStack(spacing: Spacing.xs) {
                Text("EduFortune Learner")
                    .font(Typography.title1)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Text(progressViewModel.getCurrentLevel().title)
                    .font(Typography.body)
                    .foregroundColor(progressViewModel.getLevelColor())
            }
        }
        .padding(.top, Spacing.xl)
    }
    
    // MARK: - Quick Stats
    private var quickStats: some View {
        HStack(spacing: Spacing.lg) {
            profileStatCard(
                icon: "star.fill",
                value: "\(progressViewModel.userProgress.experience)",
                label: "XP"
            )
            
            profileStatCard(
                icon: "flame.fill",
                value: "\(progressViewModel.getCurrentStreak())",
                label: "Day Streak"
            )
            
            profileStatCard(
                icon: "trophy.fill",
                value: "\(progressViewModel.userProgress.achievements.count)",
                label: "Achievements"
            )
        }
    }
    
    private func profileStatCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ColorThemes.primaryBlue)
            
            Text(value)
                .font(Typography.headline.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(label)
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Settings")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                settingsRow(
                    icon: "gearshape.fill",
                    title: "App Settings",
                    subtitle: "Notifications, privacy, and more"
                ) {
                    showSettings = true
                }
                
                settingsRow(
                    icon: "hand.draw.fill",
                    title: "Gesture Guide",
                    subtitle: "Learn app navigation gestures"
                ) {
                    showGestureGuide = true
                }
            }
        }
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Help & Support")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                
                settingsRow(
                    icon: "info.circle.fill",
                    title: "About EduFortune",
                    subtitle: "Version 1.0.0"
                ) {
                    // Show about page
                }
            }
        }
    }
    
    private func settingsRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(ColorThemes.primaryBlue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text(subtitle)
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundColor(ColorThemes.textTertiary)
            }
            .padding(Spacing.md)
            .glassStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func exportProgress() {
        let progressData = progressViewModel.exportProgressData()
        // In a real app, this would trigger sharing or save to files
        print("Exported progress data:\n\(progressData)")
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Notification settings
                        settingsGroup("Notifications") {
                            Toggle("Daily Reminders", isOn: .constant(true))
                            Toggle("Achievement Alerts", isOn: .constant(true))
                            Toggle("Streak Warnings", isOn: .constant(true))
                        }
                        
                        // Learning preferences
                        settingsGroup("Learning Preferences") {
                            HStack {
                                Text("Daily Goal")
                                Spacer()
                                Text("15 minutes")
                                    .foregroundColor(ColorThemes.textSecondary)
                            }
                            
                            HStack {
                                Text("Difficulty Level")
                                Spacer()
                                Text("Beginner")
                                    .foregroundColor(ColorThemes.textSecondary)
                            }
                            
                            Toggle("Show Financial Tips", isOn: .constant(true))
                        }
                        
                        // Privacy settings
                        settingsGroup("Privacy") {
                            Toggle("Analytics", isOn: .constant(true))
                            Toggle("Crash Reports", isOn: .constant(true))
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    @ViewBuilder
    private func settingsGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorThemes.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                content()
            }
            .padding(Spacing.md)
            .cardStyle()
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Spacing.md) {
                        ForEach(viewModel.userProgress.achievements) { achievement in
                            AchievementDetailCard(achievement: achievement)
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Achievement Detail Card
struct AchievementDetailCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            AchievementBadge(achievement: achievement, size: 60)
            
            Text(achievement.title)
                .font(Typography.caption1.weight(.medium))
                .foregroundColor(ColorThemes.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(achievement.description)
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(Spacing.sm)
        .frame(height: 140)
        .cardStyle()
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        Text("Detailed analytics would go here")
                            .font(Typography.title2)
                            .foregroundColor(ColorThemes.textPrimary)
                        
                        Text("Charts, graphs, and detailed progress metrics")
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.lg)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
