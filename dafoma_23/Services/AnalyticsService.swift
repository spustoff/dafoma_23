//
//  AnalyticsService.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var learningAnalytics: LearningAnalytics?
    @Published var performanceMetrics: PerformanceMetrics?
    @Published var isCalculating = false
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen to user progress changes
        dataService.$userProgress
            .sink { [weak self] _ in
                self?.updateAnalytics()
            }
            .store(in: &cancellables)
        
        updateAnalytics()
    }
    
    // MARK: - Analytics Models
    struct LearningAnalytics {
        let totalStudyTime: Int // minutes
        let averageSessionLength: Double // minutes
        let studyFrequency: StudyFrequency
        let preferredStudyTimes: [Int] // hours of day (0-23)
        let mostProductiveDays: [String] // day names
        let learningVelocity: Double // lessons per week
        let retentionRate: Double // percentage
        let consistencyScore: Double // 0-100
        
        enum StudyFrequency {
            case daily, frequent, moderate, occasional, rare
            
            var description: String {
                switch self {
                case .daily: return "Daily learner"
                case .frequent: return "Frequent learner"
                case .moderate: return "Moderate learner"
                case .occasional: return "Occasional learner"
                case .rare: return "Rare learner"
                }
            }
            
            var color: String {
                switch self {
                case .daily: return "green"
                case .frequent: return "blue"
                case .moderate: return "orange"
                case .occasional: return "yellow"
                case .rare: return "red"
                }
            }
        }
    }
    
    struct PerformanceMetrics {
        let overallAccuracy: Double // percentage
        let categoryPerformance: [CategoryPerformance]
        let difficultyProgression: [DifficultyMetric]
        let learningCurve: [LearningPoint]
        let streakAnalysis: StreakAnalysis
        let timeToCompletion: [CourseTimeMetric]
        let improvementAreas: [String]
        let strongAreas: [String]
    }
    
    struct CategoryPerformance {
        let category: LanguageCourse.CourseCategory
        let accuracy: Double
        let timeSpent: Int
        let coursesCompleted: Int
        let averageScore: Double
    }
    
    struct DifficultyMetric {
        let difficulty: LanguageCourse.DifficultyLevel
        let successRate: Double
        let averageAttempts: Double
        let timePerLesson: Double
    }
    
    struct LearningPoint {
        let date: Date
        let cumulativeLessons: Int
        let skillLevel: Double
        let confidence: Double
    }
    
    struct StreakAnalysis {
        let currentStreak: Int
        let longestStreak: Int
        let averageStreakLength: Double
        let streakBreaks: Int
        let consistencyRating: ConsistencyRating
        
        enum ConsistencyRating: String {
            case excellent = "Excellent"
            case good = "Good"
            case fair = "Fair"
            case needsImprovement = "Needs Improvement"
            
            var color: String {
                switch self {
                case .excellent: return "green"
                case .good: return "blue"
                case .fair: return "orange"
                case .needsImprovement: return "red"
                }
            }
        }
    }
    
    struct CourseTimeMetric {
        let courseTitle: String
        let estimatedTime: Int
        let actualTime: Int
        let efficiency: Double // actualTime / estimatedTime
    }
    
    // MARK: - Analytics Calculation
    func updateAnalytics() {
        isCalculating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let analytics = self.calculateLearningAnalytics()
            let performance = self.calculatePerformanceMetrics()
            
            DispatchQueue.main.async {
                self.learningAnalytics = analytics
                self.performanceMetrics = performance
                self.isCalculating = false
            }
        }
    }
    
    private func calculateLearningAnalytics() -> LearningAnalytics {
        let userProgress = dataService.userProgress
        
        // Calculate study frequency based on streak and total lessons
        let studyFrequency: LearningAnalytics.StudyFrequency
        if userProgress.currentStreak >= 30 {
            studyFrequency = .daily
        } else if userProgress.currentStreak >= 14 {
            studyFrequency = .frequent
        } else if userProgress.currentStreak >= 7 {
            studyFrequency = .moderate
        } else if userProgress.currentStreak >= 3 {
            studyFrequency = .occasional
        } else {
            studyFrequency = .rare
        }
        
        // Mock calculations for demo purposes
        let averageSessionLength = userProgress.totalTimeSpent > 0 ?
            Double(userProgress.totalTimeSpent) / Double(max(userProgress.totalLessonsCompleted, 1)) : 0
        
        let learningVelocity = Double(userProgress.totalLessonsCompleted) / max(Double(userProgress.currentStreak), 1)
        
        let consistencyScore = min(Double(userProgress.currentStreak * 10), 100)
        
        return LearningAnalytics(
            totalStudyTime: userProgress.totalTimeSpent,
            averageSessionLength: averageSessionLength,
            studyFrequency: studyFrequency,
            preferredStudyTimes: [19, 20, 21], // Mock: evening study preference
            mostProductiveDays: ["Monday", "Wednesday", "Friday"],
            learningVelocity: learningVelocity,
            retentionRate: 85.5, // Mock retention rate
            consistencyScore: consistencyScore
        )
    }
    
    private func calculatePerformanceMetrics() -> PerformanceMetrics {
        let userProgress = dataService.userProgress
        let availableCourses = dataService.availableCourses
        
        // Calculate category performance
        let categoryPerformance = LanguageCourse.CourseCategory.allCases.map { category in
            let categoryAccuracy = Double.random(in: 70...95) // Mock data
            let categoryTime = Int.random(in: 30...180) // Mock data
            let categoryCourses = availableCourses.filter { $0.category == category }.count
            
            return CategoryPerformance(
                category: category,
                accuracy: categoryAccuracy,
                timeSpent: categoryTime,
                coursesCompleted: min(categoryCourses, userProgress.completedCourses.count),
                averageScore: categoryAccuracy
            )
        }
        
        // Calculate difficulty progression
        let difficultyProgression = LanguageCourse.DifficultyLevel.allCases.map { difficulty in
            DifficultyMetric(
                difficulty: difficulty,
                successRate: Double.random(in: 60...90),
                averageAttempts: Double.random(in: 1.2...2.5),
                timePerLesson: Double.random(in: 10...30)
            )
        }
        
        // Generate learning curve (mock data)
        let learningCurve = generateLearningCurve(for: userProgress)
        
        // Streak analysis
        let streakAnalysis = StreakAnalysis(
            currentStreak: userProgress.currentStreak,
            longestStreak: userProgress.longestStreak,
            averageStreakLength: Double(userProgress.longestStreak) * 0.7, // Mock calculation
            streakBreaks: max(0, userProgress.totalLessonsCompleted / 10 - 1), // Mock
            consistencyRating: getConsistencyRating(for: userProgress.currentStreak)
        )
        
        // Time metrics (mock data)
        let timeMetrics = availableCourses.prefix(3).map { course in
            CourseTimeMetric(
                courseTitle: course.title,
                estimatedTime: course.estimatedDuration,
                actualTime: Int.random(in: course.estimatedDuration-10...course.estimatedDuration+20),
                efficiency: Double.random(in: 0.8...1.3)
            )
        }
        
        return PerformanceMetrics(
            overallAccuracy: Double.random(in: 75...95),
            categoryPerformance: categoryPerformance,
            difficultyProgression: difficultyProgression,
            learningCurve: learningCurve,
            streakAnalysis: streakAnalysis,
            timeToCompletion: Array(timeMetrics),
            improvementAreas: getImprovementAreas(from: categoryPerformance),
            strongAreas: getStrongAreas(from: categoryPerformance)
        )
    }
    
    private func generateLearningCurve(for progress: UserProgress) -> [LearningPoint] {
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        var points: [LearningPoint] = []
        
        for i in 0..<30 {
            let date = Calendar.current.date(byAdding: .day, value: i, to: startDate) ?? Date()
            let cumulativeLessons = Int(Double(i) * (Double(progress.totalLessonsCompleted) / 30.0))
            let skillLevel = min(100.0, Double(cumulativeLessons) * 2.5)
            let confidence = min(100.0, skillLevel * 0.8 + Double.random(in: -10...10))
            
            points.append(LearningPoint(
                date: date,
                cumulativeLessons: cumulativeLessons,
                skillLevel: skillLevel,
                confidence: confidence
            ))
        }
        
        return points
    }
    
    private func getConsistencyRating(for streak: Int) -> StreakAnalysis.ConsistencyRating {
        switch streak {
        case 30...: return .excellent
        case 14..<30: return .good
        case 7..<14: return .fair
        default: return .needsImprovement
        }
    }
    
    private func getImprovementAreas(from performance: [CategoryPerformance]) -> [String] {
        return performance
            .filter { $0.accuracy < 80 }
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(3)
            .map { "\($0.category.rawValue) (accuracy: \(Int($0.accuracy))%)" }
    }
    
    private func getStrongAreas(from performance: [CategoryPerformance]) -> [String] {
        return performance
            .filter { $0.accuracy >= 85 }
            .sorted { $0.accuracy > $1.accuracy }
            .prefix(3)
            .map { "\($0.category.rawValue) (accuracy: \(Int($0.accuracy))%)" }
    }
    
    // MARK: - Event Tracking
    func trackLessonStart(lessonId: UUID, courseId: UUID) {
        // In a real app, this would send events to analytics service
        print("📊 Lesson started: \(lessonId) in course: \(courseId)")
    }
    
    func trackLessonCompletion(lessonId: UUID, courseId: UUID, timeSpent: Int, score: Double) {
        // Track lesson completion
        print("📊 Lesson completed: \(lessonId), time: \(timeSpent)min, score: \(score)%")
        
        // Update analytics after tracking
        updateAnalytics()
    }
    
    func trackQuizAttempt(questionId: UUID, isCorrect: Bool, timeSpent: Int) {
        // Track quiz performance
        print("📊 Quiz attempt: \(questionId), correct: \(isCorrect), time: \(timeSpent)s")
    }
    
    func trackUserAction(action: String, context: [String: Any] = [:]) {
        // General event tracking
        print("📊 User action: \(action), context: \(context)")
    }
    
    // MARK: - Reporting
    func generateWeeklyReport() -> WeeklyReport {
        let analytics = learningAnalytics ?? calculateLearningAnalytics()
        let performance = performanceMetrics ?? calculatePerformanceMetrics()
        
        return WeeklyReport(
            weekOf: Date(),
            totalStudyTime: analytics.totalStudyTime,
            lessonsCompleted: dataService.userProgress.totalLessonsCompleted,
            averageAccuracy: performance.overallAccuracy,
            streakMaintained: dataService.userProgress.currentStreak >= 7,
            topCategory: performance.categoryPerformance.max(by: { $0.accuracy < $1.accuracy })?.category.rawValue ?? "N/A",
            improvementFromLastWeek: Double.random(in: -5...15) // Mock improvement
        )
    }
    
    func generateMonthlyReport() -> MonthlyReport {
        let analytics = learningAnalytics ?? calculateLearningAnalytics()
        _ = performanceMetrics ?? calculatePerformanceMetrics()
        
        return MonthlyReport(
            monthOf: Date(),
            totalStudyHours: Double(analytics.totalStudyTime) / 60.0,
            coursesCompleted: dataService.userProgress.completedCourses.count,
            skillLevelGrowth: Double.random(in: 10...40), // Mock growth
            consistencyScore: analytics.consistencyScore,
            achievementsUnlocked: dataService.userProgress.achievements.count,
            topAchievement: dataService.userProgress.achievements.last?.title ?? "Getting Started"
        )
    }
}

// MARK: - Report Models
struct WeeklyReport {
    let weekOf: Date
    let totalStudyTime: Int // minutes
    let lessonsCompleted: Int
    let averageAccuracy: Double
    let streakMaintained: Bool
    let topCategory: String
    let improvementFromLastWeek: Double // percentage
}

struct MonthlyReport {
    let monthOf: Date
    let totalStudyHours: Double
    let coursesCompleted: Int
    let skillLevelGrowth: Double // percentage
    let consistencyScore: Double
    let achievementsUnlocked: Int
    let topAchievement: String
}
