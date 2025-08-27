//
//  AIRecommendationService.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine

class AIRecommendationService: ObservableObject {
    static let shared = AIRecommendationService()
    
    @Published var personalizedRecommendations: [CourseRecommendation] = []
    @Published var dailyTip: FinancialTip?
    @Published var isGeneratingRecommendations = false
    
    private let dataService = DataService.shared
    
    private init() {
        generateInitialRecommendations()
        generateDailyTip()
    }
    
    // MARK: - Recommendation Models
    struct CourseRecommendation: Identifiable {
        let id = UUID()
        let course: LanguageCourse
        let reason: String
        let confidence: Double // 0.0 to 1.0
        let priority: Priority
        
        enum Priority: Int, CaseIterable {
            case low = 1
            case medium = 2
            case high = 3
            case urgent = 4
            
            var color: String {
                switch self {
                case .low: return "gray"
                case .medium: return "blue"
                case .high: return "orange"
                case .urgent: return "red"
                }
            }
        }
    }
    
    struct FinancialTip: Identifiable {
        let id = UUID()
        let title: String
        let content: String
        let category: Category
        let difficulty: LanguageCourse.DifficultyLevel
        let relatedVocabulary: [String]
        let actionable: Bool
        
        enum Category: String, CaseIterable {
            case budgeting = "Budgeting"
            case investing = "Investing"
            case saving = "Saving"
            case creditDebt = "Credit & Debt"
            case careerFinance = "Career Finance"
            case languageLearning = "Language Learning"
            
            var icon: String {
                switch self {
                case .budgeting: return "chart.pie.fill"
                case .investing: return "chart.line.uptrend.xyaxis"
                case .saving: return "banknote.fill"
                case .creditDebt: return "creditcard.fill"
                case .careerFinance: return "briefcase.fill"
                case .languageLearning: return "book.fill"
                }
            }
        }
    }
    
    // MARK: - AI Recommendation Engine
    func generatePersonalizedRecommendations() {
        isGeneratingRecommendations = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let recommendations = self.analyzeUserAndGenerateRecommendations()
            
            DispatchQueue.main.async {
                self.personalizedRecommendations = recommendations
                self.isGeneratingRecommendations = false
            }
        }
    }
    
    private func generateInitialRecommendations() {
        personalizedRecommendations = analyzeUserAndGenerateRecommendations()
    }
    
    private func analyzeUserAndGenerateRecommendations() -> [CourseRecommendation] {
        let userProgress = dataService.userProgress
        let availableCourses = dataService.availableCourses
        
        var recommendations: [CourseRecommendation] = []
        
        // Analyze user's learning patterns
        let userLevel = userProgress.level
        let completedCourses = userProgress.completedCourses.count
        let currentStreak = userProgress.currentStreak
        let preferences = userProgress.preferences
        
        for course in availableCourses {
            guard course.isUnlocked else { continue }
            
            let recommendation = generateRecommendationForCourse(
                course: course,
                userLevel: userLevel,
                completedCourses: completedCourses,
                currentStreak: currentStreak,
                preferences: preferences
            )
            
            if let rec = recommendation {
                recommendations.append(rec)
            }
        }
        
        // Sort by priority and confidence
        return recommendations.sorted { first, second in
            if first.priority.rawValue != second.priority.rawValue {
                return first.priority.rawValue > second.priority.rawValue
            }
            return first.confidence > second.confidence
        }
    }
    
    private func generateRecommendationForCourse(
        course: LanguageCourse,
        userLevel: UserProgress.UserLevel,
        completedCourses: Int,
        currentStreak: Int,
        preferences: UserPreferences
    ) -> CourseRecommendation? {
        
        var confidence: Double = 0.5
        var priority: CourseRecommendation.Priority = .medium
        var reasons: [String] = []
        
        // Check difficulty match
        if course.difficulty == preferences.difficultyPreference {
            confidence += 0.3
            reasons.append("Matches your preferred difficulty level")
        }
        
        // Check if it's a financial course (user might be interested)
        if course.category == .financial && preferences.showFinancialTips {
            confidence += 0.2
            priority = .high
            reasons.append("Enhances your financial literacy")
        }
        
        // Check lesson length preference
        if course.estimatedDuration <= preferences.preferredLessonLength + 10 {
            confidence += 0.1
            reasons.append("Fits your preferred lesson length")
        }
        
        // Streak-based recommendations
        if currentStreak > 7 {
            confidence += 0.15
            reasons.append("Keep your streak going!")
        }
        
        // Beginner boost
        if completedCourses == 0 && course.difficulty == .beginner {
            confidence += 0.25
            priority = .high
            reasons.append("Perfect for getting started")
        }
        
        // Progressive difficulty
        if completedCourses > 2 && course.difficulty.rawValue > preferences.difficultyPreference.rawValue {
            confidence += 0.2
            reasons.append("Ready for the next challenge")
        }
        
        // Business language for advanced users
        if userLevel.rawValue >= 3 && course.category == .business {
            confidence += 0.15
            reasons.append("Advance your professional skills")
        }
        
        // Only recommend if confidence is above threshold
        guard confidence >= 0.6 else { return nil }
        
        let reason = reasons.joined(separator: " • ")
        
        return CourseRecommendation(
            course: course,
            reason: reason,
            confidence: confidence,
            priority: priority
        )
    }
    
    // MARK: - Daily Tips Generation
    func generateDailyTip() {
        let tips = getFinancialTips()
        dailyTip = tips.randomElement()
    }
    
    func refreshDailyTip() {
        generateDailyTip()
    }
    
    private func getFinancialTips() -> [FinancialTip] {
        return [
            FinancialTip(
                title: "Emergency Fund Vocabulary",
                content: "Learn key terms: 'Emergency fund' means money saved for unexpected expenses. Aim to save 3-6 months of expenses. Practice saying: 'I'm building my emergency fund for financial security.'",
                category: .saving,
                difficulty: .beginner,
                relatedVocabulary: ["Emergency fund", "Expenses", "Financial security", "Savings account"],
                actionable: true
            ),
            FinancialTip(
                title: "Investment Terminology",
                content: "Master these investment words: 'Diversification' means spreading investments across different assets. 'Portfolio' is your collection of investments. Practice: 'I diversify my portfolio to reduce risk.'",
                category: .investing,
                difficulty: .intermediate,
                relatedVocabulary: ["Diversification", "Portfolio", "Assets", "Risk management"],
                actionable: true
            ),
            FinancialTip(
                title: "Credit Score Communication",
                content: "Important phrases for credit discussions: 'My credit score is...' 'I'm working to improve my creditworthiness.' 'I pay my bills on time to maintain good credit.'",
                category: .creditDebt,
                difficulty: .beginner,
                relatedVocabulary: ["Credit score", "Creditworthiness", "Payment history", "Credit report"],
                actionable: true
            ),
            FinancialTip(
                title: "Budgeting Expressions",
                content: "Essential budgeting phrases: 'I allocate 50% for needs, 30% for wants, 20% for savings.' 'I track my expenses monthly.' 'I stick to my budget to reach my goals.'",
                category: .budgeting,
                difficulty: .beginner,
                relatedVocabulary: ["Allocate", "Expenses", "Budget", "Financial goals"],
                actionable: true
            ),
            FinancialTip(
                title: "Salary Negotiation Language",
                content: "Professional phrases for salary discussions: 'Based on my research and experience...' 'I would like to discuss my compensation.' 'My salary expectations are...'",
                category: .careerFinance,
                difficulty: .advanced,
                relatedVocabulary: ["Compensation", "Salary expectations", "Market rate", "Professional experience"],
                actionable: true
            ),
            FinancialTip(
                title: "Banking Conversations",
                content: "Common banking phrases: 'I'd like to open a checking account.' 'What's the interest rate on savings?' 'Can you explain the fees?' 'I need to transfer funds.'",
                category: .budgeting,
                difficulty: .beginner,
                relatedVocabulary: ["Checking account", "Interest rate", "Bank fees", "Transfer funds"],
                actionable: true
            ),
            FinancialTip(
                title: "Learning Consistency",
                content: "Study financial English for just 15 minutes daily. Consistency beats intensity! Use the vocabulary in real conversations. Practice makes permanent, not perfect.",
                category: .languageLearning,
                difficulty: .beginner,
                relatedVocabulary: ["Consistency", "Daily practice", "Vocabulary", "Real conversations"],
                actionable: true
            )
        ]
    }
    
    // MARK: - Adaptive Learning Suggestions
    func getNextLessonSuggestion() -> Lesson? {
        let userProgress = dataService.userProgress
        guard let currentCourseId = userProgress.currentCourse,
              let currentCourse = dataService.getCourse(by: UUID(uuidString: currentCourseId) ?? UUID()) else {
            return nil
        }
        
        // Find next incomplete lesson
        return currentCourse.lessons.first { !$0.isCompleted }
    }
    
    func getWeakAreasToImprove() -> [String] {
        // In a real app, this would analyze user's quiz performance
        // For now, return mock weak areas
        return [
            "Financial vocabulary pronunciation",
            "Business conversation confidence",
            "Investment terminology understanding",
            "Banking procedure explanations"
        ]
    }
    
    func getStrengthAreas() -> [String] {
        // Mock strength areas based on completed courses
        let completedCount = dataService.userProgress.completedCourses.count
        
        switch completedCount {
        case 0:
            return ["Motivation to learn", "Consistent daily practice"]
        case 1...2:
            return ["Basic vocabulary", "Learning dedication", "Progress tracking"]
        case 3...5:
            return ["Financial concepts", "Vocabulary retention", "Study habits"]
        default:
            return ["Advanced terminology", "Concept application", "Teaching others", "Expert knowledge"]
        }
    }
    
    // MARK: - Gamification Suggestions
    func getSuggestedChallenges() -> [LearningChallenge] {
        let userProgress = dataService.userProgress
        
        return [
            LearningChallenge(
                title: "7-Day Streak Master",
                description: "Study for 7 consecutive days",
                reward: "Unlock advanced course",
                progress: Double(userProgress.currentStreak) / 7.0,
                isCompleted: userProgress.currentStreak >= 7
            ),
            LearningChallenge(
                title: "Financial Vocab Expert",
                description: "Learn 50 financial terms",
                reward: "Achievement badge + 100 XP",
                progress: Double(userProgress.totalLessonsCompleted) / 10.0, // Mock calculation
                isCompleted: false
            ),
            LearningChallenge(
                title: "Course Completionist",
                description: "Complete 3 courses",
                reward: "Unlock premium features",
                progress: Double(userProgress.completedCourses.count) / 3.0,
                isCompleted: userProgress.completedCourses.count >= 3
            )
        ]
    }
}

// MARK: - Supporting Models
struct LearningChallenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let reward: String
    let progress: Double // 0.0 to 1.0
    let isCompleted: Bool
}



