//
//  UserProgress.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation

struct UserProgress: Codable {
    let userId: String
    var totalLessonsCompleted: Int
    var totalTimeSpent: Int // in minutes
    var currentStreak: Int // consecutive days
    var longestStreak: Int
    var level: UserLevel
    var experience: Int
    var achievements: [Achievement]
    var completedCourses: [String] // Course IDs
    var currentCourse: String? // Current course ID
    var dailyGoal: Int // minutes per day
    var weeklyGoal: Int // minutes per week
    var lastActivityDate: Date
    var preferences: UserPreferences
    
    enum UserLevel: Int, CaseIterable, Codable {
        case novice = 1
        case beginner = 2
        case intermediate = 3
        case advanced = 4
        case expert = 5
        case master = 6
        
        var title: String {
            switch self {
            case .novice: return "Novice Learner"
            case .beginner: return "Beginner"
            case .intermediate: return "Intermediate"
            case .advanced: return "Advanced"
            case .expert: return "Expert"
            case .master: return "Master"
            }
        }
        
        var experienceRequired: Int {
            switch self {
            case .novice: return 0
            case .beginner: return 100
            case .intermediate: return 300
            case .advanced: return 600
            case .expert: return 1000
            case .master: return 1500
            }
        }
        
        var color: String {
            switch self {
            case .novice: return "gray"
            case .beginner: return "green"
            case .intermediate: return "blue"
            case .advanced: return "purple"
            case .expert: return "orange"
            case .master: return "yellow"
            }
        }
        
        var icon: String {
            switch self {
            case .novice: return "seedling"
            case .beginner: return "leaf.fill"
            case .intermediate: return "tree.fill"
            case .advanced: return "star.fill"
            case .expert: return "crown.fill"
            case .master: return "trophy.fill"
            }
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let unlockedDate: Date
    let category: AchievementCategory
    
    enum AchievementCategory: String, CaseIterable, Codable {
        case streak = "Streak"
        case completion = "Completion"
        case time = "Time Spent"
        case financial = "Financial Learning"
        case social = "Social"
        
        var color: String {
            switch self {
            case .streak: return "orange"
            case .completion: return "green"
            case .time: return "blue"
            case .financial: return "yellow"
            case .social: return "purple"
            }
        }
    }
}

struct UserPreferences: Codable {
    var preferredLanguages: [String]
    var difficultyPreference: LanguageCourse.DifficultyLevel
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var darkModeEnabled: Bool
    var autoPlayAudio: Bool
    var showFinancialTips: Bool
    var preferredLessonLength: Int // in minutes
}

extension UserProgress {
    static let defaultProgress = UserProgress(
        userId: UUID().uuidString,
        totalLessonsCompleted: 0,
        totalTimeSpent: 0,
        currentStreak: 0,
        longestStreak: 0,
        level: .novice,
        experience: 0,
        achievements: [],
        completedCourses: [],
        currentCourse: nil,
        dailyGoal: 15,
        weeklyGoal: 105,
        lastActivityDate: Date(),
        preferences: UserPreferences.defaultPreferences
    )
    
    mutating func addExperience(_ points: Int) {
        experience += points
        updateLevel()
    }
    
    mutating func completeLesson() {
        totalLessonsCompleted += 1
        addExperience(10)
        updateStreak()
    }
    
    mutating func completeCourse(_ courseId: String) {
        if !completedCourses.contains(courseId) {
            completedCourses.append(courseId)
            addExperience(50)
            checkForAchievements()
        }
    }
    
    private mutating func updateLevel() {
        for level in UserLevel.allCases.reversed() {
            if experience >= level.experienceRequired {
                if self.level.rawValue < level.rawValue {
                    self.level = level
                    // Add level up achievement
                    let achievement = Achievement(
                        title: "Level Up!",
                        description: "Reached \(level.title) level",
                        icon: level.icon,
                        unlockedDate: Date(),
                        category: .completion
                    )
                    achievements.append(achievement)
                }
                break
            }
        }
    }
    
    private mutating func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        if calendar.isDate(lastActivityDate, inSameDayAs: today) {
            // Already studied today, don't update streak
            return
        } else if calendar.isDate(lastActivityDate, equalTo: calendar.date(byAdding: .day, value: -1, to: today)!, toGranularity: .day) {
            // Studied yesterday, continue streak
            currentStreak += 1
        } else {
            // Streak broken, reset
            currentStreak = 1
        }
        
        lastActivityDate = today
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        checkStreakAchievements()
    }
    
    private mutating func checkStreakAchievements() {
        let streakMilestones = [7, 30, 100, 365]
        for milestone in streakMilestones {
            if currentStreak == milestone && !achievements.contains(where: { $0.title == "\(milestone) Day Streak" }) {
                let achievement = Achievement(
                    title: "\(milestone) Day Streak",
                    description: "Studied for \(milestone) consecutive days",
                    icon: "flame.fill",
                    unlockedDate: Date(),
                    category: .streak
                )
                achievements.append(achievement)
            }
        }
    }
    
    private mutating func checkForAchievements() {
        // Check completion achievements
        let completionMilestones = [1, 5, 10, 25]
        for milestone in completionMilestones {
            if completedCourses.count == milestone && !achievements.contains(where: { $0.title == "\(milestone) Course\(milestone == 1 ? "" : "s") Completed" }) {
                let achievement = Achievement(
                    title: "\(milestone) Course\(milestone == 1 ? "" : "s") Completed",
                    description: "Completed \(milestone) course\(milestone == 1 ? "" : "s")",
                    icon: "checkmark.seal.fill",
                    unlockedDate: Date(),
                    category: .completion
                )
                achievements.append(achievement)
            }
        }
    }
}

extension UserPreferences {
    static let defaultPreferences = UserPreferences(
        preferredLanguages: ["English"],
        difficultyPreference: .beginner,
        notificationsEnabled: true,
        dailyReminderTime: Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()),
        soundEnabled: true,
        hapticsEnabled: true,
        darkModeEnabled: false,
        autoPlayAudio: true,
        showFinancialTips: true,
        preferredLessonLength: 15
    )
}
