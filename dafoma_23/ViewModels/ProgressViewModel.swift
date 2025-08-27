//
//  ProgressViewModel.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine
import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var userProgress: UserProgress
    @Published var learningAnalytics: AnalyticsService.LearningAnalytics?
    @Published var performanceMetrics: AnalyticsService.PerformanceMetrics?
    @Published var weeklyReport: WeeklyReport?
    @Published var monthlyReport: MonthlyReport?
    @Published var isLoadingAnalytics = false
    @Published var selectedTimeRange: TimeRange = .week
    @Published var showAchievements = false
    @Published var selectedAchievement: Achievement?
    
    // Chart data
    @Published var studyTimeData: [StudyDataPoint] = []
    @Published var accuracyData: [AccuracyDataPoint] = []
    @Published var categoryProgressData: [CategoryProgress] = []
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            }
        }
    }
    
    struct StudyDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let minutes: Int
        let lessonsCompleted: Int
    }
    
    struct AccuracyDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let accuracy: Double
        let category: LanguageCourse.CourseCategory
    }
    
    struct CategoryProgress: Identifiable {
        let id = UUID()
        let category: LanguageCourse.CourseCategory
        let progress: Double
        let timeSpent: Int
        let accuracy: Double
    }
    
    private let dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    private let aiService = AIRecommendationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userProgress = dataService.userProgress
        setupBindings()
        loadAnalytics()
        generateChartData()
    }
    
    private func setupBindings() {
        // Bind to data service updates
        dataService.$userProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.userProgress = progress
                self?.generateChartData()
            }
            .store(in: &cancellables)
        
        // Bind to analytics service
        analyticsService.$learningAnalytics
            .receive(on: DispatchQueue.main)
            .assign(to: \.learningAnalytics, on: self)
            .store(in: &cancellables)
        
        analyticsService.$performanceMetrics
            .receive(on: DispatchQueue.main)
            .assign(to: \.performanceMetrics, on: self)
            .store(in: &cancellables)
        
        analyticsService.$isCalculating
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoadingAnalytics, on: self)
            .store(in: &cancellables)
        
        // Bind to time range changes
        $selectedTimeRange
            .sink { [weak self] _ in
                self?.generateChartData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadAnalytics() {
        analyticsService.updateAnalytics()
        generateReports()
    }
    
    func refreshData() {
        loadAnalytics()
        generateChartData()
    }
    
    private func generateReports() {
        weeklyReport = analyticsService.generateWeeklyReport()
        monthlyReport = analyticsService.generateMonthlyReport()
    }
    
    // MARK: - Chart Data Generation
    private func generateChartData() {
        generateStudyTimeData()
        generateAccuracyData()
        generateCategoryProgressData()
    }
    
    private func generateStudyTimeData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        var dataPoints: [StudyDataPoint] = []
        
        for i in 0..<selectedTimeRange.days {
            let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
            
            // Mock data generation - in real app, this would come from stored daily data
            let minutes = Int.random(in: 0...60)
            let lessons = minutes > 0 ? Int.random(in: 0...3) : 0
            
            dataPoints.append(StudyDataPoint(
                date: date,
                minutes: minutes,
                lessonsCompleted: lessons
            ))
        }
        
        studyTimeData = dataPoints
    }
    
    private func generateAccuracyData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        var dataPoints: [AccuracyDataPoint] = []
        
        for i in 0..<min(selectedTimeRange.days, 30) { // Limit to 30 points for performance
            let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
            let category = LanguageCourse.CourseCategory.allCases.randomElement() ?? .vocabulary
            let accuracy = Double.random(in: 60...95)
            
            dataPoints.append(AccuracyDataPoint(
                date: date,
                accuracy: accuracy,
                category: category
            ))
        }
        
        accuracyData = dataPoints
    }
    
    private func generateCategoryProgressData() {
        categoryProgressData = LanguageCourse.CourseCategory.allCases.map { category in
            CategoryProgress(
                category: category,
                progress: Double.random(in: 0.1...1.0),
                timeSpent: Int.random(in: 30...300),
                accuracy: Double.random(in: 70...95)
            )
        }
    }
    
    // MARK: - Progress Calculations
    func getOverallProgress() -> Double {
        let totalLessons = dataService.availableCourses.flatMap { $0.lessons }.count
        return totalLessons > 0 ? Double(userProgress.totalLessonsCompleted) / Double(totalLessons) : 0
    }
    
    func getWeeklyGoalProgress() -> Double {
        let weeklyGoal = userProgress.weeklyGoal
        let weeklyProgress = getThisWeekStudyTime()
        return weeklyGoal > 0 ? Double(weeklyProgress) / Double(weeklyGoal) : 0
    }
    
    func getDailyGoalProgress() -> Double {
        let dailyGoal = userProgress.dailyGoal
        let todayProgress = getTodayStudyTime()
        return dailyGoal > 0 ? Double(todayProgress) / Double(dailyGoal) : 0
    }
    
    func getTodayStudyTime() -> Int {
        // In a real app, this would track actual daily study time
        return studyTimeData.last?.minutes ?? 0
    }
    
    func getThisWeekStudyTime() -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return studyTimeData.filter { dataPoint in
            calendar.isDate(dataPoint.date, equalTo: weekStart, toGranularity: .weekOfYear)
        }.reduce(0) { $0 + $1.minutes }
    }
    
    func getCurrentStreak() -> Int {
        return userProgress.currentStreak
    }
    
    func getLongestStreak() -> Int {
        return userProgress.longestStreak
    }
    
    // MARK: - Level and Experience
    func getCurrentLevel() -> UserProgress.UserLevel {
        return userProgress.level
    }
    
    func getExperienceProgress() -> Double {
        let currentLevel = userProgress.level
        let nextLevel = UserProgress.UserLevel.allCases.first { $0.rawValue > currentLevel.rawValue }
        
        guard let next = nextLevel else { return 1.0 }
        
        let currentExp = userProgress.experience - currentLevel.experienceRequired
        let expNeeded = next.experienceRequired - currentLevel.experienceRequired
        
        return expNeeded > 0 ? Double(currentExp) / Double(expNeeded) : 1.0
    }
    
    func getExperienceToNextLevel() -> Int {
        let currentLevel = userProgress.level
        let nextLevel = UserProgress.UserLevel.allCases.first { $0.rawValue > currentLevel.rawValue }
        
        guard let next = nextLevel else { return 0 }
        
        return max(0, next.experienceRequired - userProgress.experience)
    }
    
    // MARK: - Achievements
    func getRecentAchievements(limit: Int = 5) -> [Achievement] {
        return Array(userProgress.achievements.suffix(limit))
    }
    
    func getAchievementsByCategory(_ category: Achievement.AchievementCategory) -> [Achievement] {
        return userProgress.achievements.filter { $0.category == category }
    }
    
    func selectAchievement(_ achievement: Achievement) {
        selectedAchievement = achievement
        showAchievements = true
    }
    
    // MARK: - Statistics
    func getAverageAccuracy() -> Double {
        return performanceMetrics?.overallAccuracy ?? 0
    }
    
    func getTotalStudyHours() -> Double {
        return Double(userProgress.totalTimeSpent) / 60.0
    }
    
    func getCompletionRate() -> Double {
        return dataService.getCompletionRate()
    }
    
    func getLessonsPerWeek() -> Double {
        return learningAnalytics?.learningVelocity ?? 0
    }
    
    func getConsistencyScore() -> Double {
        return learningAnalytics?.consistencyScore ?? 0
    }
    
    // MARK: - Recommendations
    func getImprovementSuggestions() -> [String] {
        var suggestions: [String] = []
        
        // Based on streak
        if userProgress.currentStreak < 7 {
            suggestions.append("Try to study daily to build a strong learning habit")
        }
        
        // Based on accuracy
        if getAverageAccuracy() < 80 {
            suggestions.append("Review previous lessons to improve understanding")
        }
        
        // Based on study time
        if getTodayStudyTime() < userProgress.dailyGoal {
            suggestions.append("Spend a few more minutes today to reach your daily goal")
        }
        
        // Based on performance metrics
        if let metrics = performanceMetrics {
            suggestions.append(contentsOf: metrics.improvementAreas.prefix(2).map { "Focus on improving: \($0)" })
        }
        
        return suggestions
    }
    
    func getMotivationalMessage() -> String {
        let level = userProgress.level
        let streak = userProgress.currentStreak
        
        if streak >= 30 {
            return "🔥 Incredible! You're on fire with a \(streak)-day streak!"
        } else if streak >= 14 {
            return "⭐ Amazing consistency! Keep up the great work!"
        } else if streak >= 7 {
            return "🌟 One week strong! You're building great habits!"
        } else if level.rawValue >= 4 {
            return "🎓 You're becoming an expert! Your dedication shows!"
        } else if userProgress.totalLessonsCompleted >= 10 {
            return "📈 Great progress! You're really getting the hang of this!"
        } else {
            return "🚀 You're off to a great start! Keep learning!"
        }
    }
    
    // MARK: - Data Export
    func exportProgressData() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        var report = "EduFortune Progress Report\n"
        report += "Generated: \(formatter.string(from: Date()))\n\n"
        report += "Overall Statistics:\n"
        report += "- Level: \(userProgress.level.title)\n"
        report += "- Experience: \(userProgress.experience) XP\n"
        report += "- Lessons Completed: \(userProgress.totalLessonsCompleted)\n"
        report += "- Total Study Time: \(formatTime(userProgress.totalTimeSpent))\n"
        report += "- Current Streak: \(userProgress.currentStreak) days\n"
        report += "- Longest Streak: \(userProgress.longestStreak) days\n\n"
        
        report += "Achievements (\(userProgress.achievements.count)):\n"
        for achievement in userProgress.achievements {
            report += "- \(achievement.title): \(achievement.description)\n"
        }
        
        return report
    }
    
    // MARK: - Helper Methods
    func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: date)
    }
    
    func getProgressColor(for progress: Double) -> Color {
        switch progress {
        case 0.8...: return ColorThemes.success
        case 0.6..<0.8: return ColorThemes.warning
        default: return ColorThemes.error
        }
    }
    
    func getLevelColor() -> Color {
        switch userProgress.level {
        case .novice: return Color.gray
        case .beginner: return ColorThemes.success
        case .intermediate: return ColorThemes.primaryBlue
        case .advanced: return ColorThemes.primaryPurple
        case .expert: return ColorThemes.accentOrange
        case .master: return ColorThemes.financialGold
        }
    }
}



