//
//  DataService.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var userProgress: UserProgress
    @Published var availableCourses: [LanguageCourse]
    @Published var isLoading = false
    @Published var error: DataError?
    
    private let userDefaultsKey = "EduFortuneUserProgress"
    private let coursesKey = "EduFortuneCourses"
    
    enum DataError: LocalizedError {
        case loadingFailed
        case savingFailed
        case invalidData
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .loadingFailed:
                return "Failed to load data"
            case .savingFailed:
                return "Failed to save data"
            case .invalidData:
                return "Invalid data format"
            case .networkError:
                return "Network connection error"
            }
        }
    }
    
    private init() {
        self.userProgress = DataService.loadUserProgress()
        self.availableCourses = DataService.loadCourses()
    }
    
    // MARK: - User Progress Management
    func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            self.error = .savingFailed
        }
    }
    
    private static func loadUserProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: "EduFortuneUserProgress"),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return UserProgress.defaultProgress
        }
        return progress
    }
    
    func updateUserProgress(_ progress: UserProgress) {
        self.userProgress = progress
        saveUserProgress()
    }
    
    func completeLesson(lessonId: UUID, courseId: UUID) {
        userProgress.completeLesson()
        
        // Update course progress
        if let courseIndex = availableCourses.firstIndex(where: { $0.id == courseId }) {
            let totalLessons = availableCourses[courseIndex].lessons.count
            let completedLessons = availableCourses[courseIndex].lessons.filter { $0.isCompleted }.count + 1
            _ = Double(completedLessons) / Double(totalLessons)
            
            let updatedCourse = availableCourses[courseIndex]
            // Note: In a real app, you'd update the specific lesson's completion status
            availableCourses[courseIndex] = updatedCourse
        }
        
        saveUserProgress()
        saveCourses()
    }
    
    func completeCourse(courseId: UUID) {
        userProgress.completeCourse(courseId.uuidString)
        saveUserProgress()
    }
    
    // MARK: - Course Management
    func saveCourses() {
        do {
            let data = try JSONEncoder().encode(availableCourses)
            UserDefaults.standard.set(data, forKey: coursesKey)
        } catch {
            self.error = .savingFailed
        }
    }
    
    private static func loadCourses() -> [LanguageCourse] {
        guard let data = UserDefaults.standard.data(forKey: "EduFortuneCourses"),
              let courses = try? JSONDecoder().decode([LanguageCourse].self, from: data) else {
            return LanguageCourse.sampleCourses
        }
        return courses
    }
    
    func getCourse(by id: UUID) -> LanguageCourse? {
        return availableCourses.first { $0.id == id }
    }
    
    func getCoursesBy(category: LanguageCourse.CourseCategory) -> [LanguageCourse] {
        return availableCourses.filter { $0.category == category }
    }
    
    func getCoursesBy(difficulty: LanguageCourse.DifficultyLevel) -> [LanguageCourse] {
        return availableCourses.filter { $0.difficulty == difficulty }
    }
    
    func unlockCourse(courseId: UUID) {
        if let index = availableCourses.firstIndex(where: { $0.id == courseId }) {
            _ = availableCourses[index]
            // Note: In a real implementation, you'd create a new struct with updated properties
            // availableCourses[index] = course with isUnlocked = true
        }
        saveCourses()
    }
    
    // MARK: - Statistics and Analytics
    func getTotalStudyTime() -> Int {
        return userProgress.totalTimeSpent
    }
    
    func getCurrentStreak() -> Int {
        return userProgress.currentStreak
    }
    
    func getLongestStreak() -> Int {
        return userProgress.longestStreak
    }
    
    func getCompletionRate() -> Double {
        let totalLessons = availableCourses.flatMap { $0.lessons }.count
        guard totalLessons > 0 else { return 0.0 }
        return Double(userProgress.totalLessonsCompleted) / Double(totalLessons)
    }
    
    func getWeeklyProgress() -> [Int] {
        // Mock data for weekly progress (7 days)
        // In a real app, you'd track daily activity
        return [45, 30, 60, 25, 40, 35, 50]
    }
    
    func getMonthlyProgress() -> [Int] {
        // Mock data for monthly progress (30 days)
        // In a real app, you'd track daily activity
        return Array(1...30).map { _ in Int.random(in: 0...90) }
    }
    
    // MARK: - Achievements
    func checkAndUnlockAchievements() {
        // This would be called after completing lessons/courses
        // Achievements are automatically checked in UserProgress model
        saveUserProgress()
    }
    
    func getRecentAchievements(limit: Int = 5) -> [Achievement] {
        return Array(userProgress.achievements.suffix(limit))
    }
    
    // MARK: - Search and Filtering
    func searchCourses(query: String) -> [LanguageCourse] {
        guard !query.isEmpty else { return availableCourses }
        
        return availableCourses.filter { course in
            course.title.localizedCaseInsensitiveContains(query) ||
            course.description.localizedCaseInsensitiveContains(query) ||
            course.language.localizedCaseInsensitiveContains(query) ||
            course.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getRecommendedCourses(limit: Int = 3) -> [LanguageCourse] {
        // Simple recommendation based on user's current level and preferences
        _ = userProgress.level
        let preferredDifficulty = userProgress.preferences.difficultyPreference
        
        let filtered = availableCourses.filter { course in
            course.difficulty == preferredDifficulty && course.isUnlocked
        }
        
        return Array(filtered.prefix(limit))
    }
    
    // MARK: - Data Reset (for development/testing)
    func resetAllData() {
        userProgress = UserProgress.defaultProgress
        availableCourses = LanguageCourse.sampleCourses
        
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: coursesKey)
    }
    
    // MARK: - Mock Network Operations (for future API integration)
    func syncWithServer() async throws {
        isLoading = true
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // In a real app, this would sync with a backend server
        // For now, we'll just simulate success
        
        isLoading = false
    }
    
    func downloadCourse(courseId: UUID) async throws {
        isLoading = true
        
        // Simulate course download
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Mock unlocking the course after download
        unlockCourse(courseId: courseId)
        
        isLoading = false
    }
}
