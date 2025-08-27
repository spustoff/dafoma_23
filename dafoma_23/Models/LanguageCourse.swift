//
//  LanguageCourse.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation

struct LanguageCourse: Identifiable, Codable {
    let id = UUID()
    let title: String
    let language: String
    let description: String
    let difficulty: DifficultyLevel
    let estimatedDuration: Int // in minutes
    let lessons: [Lesson]
    let category: CourseCategory
    let isUnlocked: Bool
    let progress: Double // 0.0 to 1.0
    let imageSystemName: String
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var color: String {
            switch self {
            case .beginner: return "green"
            case .intermediate: return "orange"
            case .advanced: return "red"
            }
        }
    }
    
    enum CourseCategory: String, CaseIterable, Codable {
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case conversation = "Conversation"
        case financial = "Financial Literacy"
        case business = "Business Language"
        
        var icon: String {
            switch self {
            case .vocabulary: return "book.fill"
            case .grammar: return "textformat"
            case .conversation: return "bubble.left.and.bubble.right.fill"
            case .financial: return "dollarsign.circle.fill"
            case .business: return "briefcase.fill"
            }
        }
    }
}

extension LanguageCourse {
    static let sampleCourses: [LanguageCourse] = [
        LanguageCourse(
            title: "Financial English Basics",
            language: "English",
            description: "Learn essential financial vocabulary and concepts in English",
            difficulty: .beginner,
            estimatedDuration: 45,
            lessons: Lesson.sampleLessons,
            category: .financial,
            isUnlocked: true,
            progress: 0.3,
            imageSystemName: "dollarsign.circle.fill"
        ),
        LanguageCourse(
            title: "Business Conversations",
            language: "English",
            description: "Master professional communication in business settings",
            difficulty: .intermediate,
            estimatedDuration: 60,
            lessons: Lesson.sampleBusinessLessons,
            category: .business,
            isUnlocked: true,
            progress: 0.1,
            imageSystemName: "briefcase.fill"
        ),
        LanguageCourse(
            title: "Investment Vocabulary",
            language: "English",
            description: "Advanced financial terms for investment and trading",
            difficulty: .advanced,
            estimatedDuration: 90,
            lessons: Lesson.sampleInvestmentLessons,
            category: .financial,
            isUnlocked: true,
            progress: 0.0,
            imageSystemName: "chart.line.uptrend.xyaxis"
        ),
        LanguageCourse(
            title: "Grammar Fundamentals",
            language: "English",
            description: "Master essential English grammar rules and structures",
            difficulty: .beginner,
            estimatedDuration: 40,
            lessons: Lesson.sampleLessons, // Reuse existing lessons for variety
            category: .grammar,
            isUnlocked: true,
            progress: 0.0,
            imageSystemName: "textformat"
        )
    ]
}



