//
//  CourseViewModel.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine
import SwiftUI

class CourseViewModel: ObservableObject {
    @Published var courses: [LanguageCourse] = []
    @Published var filteredCourses: [LanguageCourse] = []
    @Published var currentCourse: LanguageCourse?
    @Published var currentLesson: Lesson?
    @Published var searchText = ""
    @Published var selectedCategory: LanguageCourse.CourseCategory?
    @Published var selectedDifficulty: LanguageCourse.DifficultyLevel?
    @Published var isLoading = false
    @Published var error: String?
    
    // Lesson state
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [Int] = []
    @Published var showResults = false
    @Published var lessonScore = 0.0
    @Published var isLessonCompleted = false
    
    private let dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    private let aiService = AIRecommendationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadCourses()
    }
    
    private func setupBindings() {
        // Bind to data service
        dataService.$availableCourses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] courses in
                self?.courses = courses
                self?.applyFilters()
            }
            .store(in: &cancellables)
        
        // Search and filter binding
        Publishers.CombineLatest3($searchText, $selectedCategory, $selectedDifficulty)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Course Management
    func loadCourses() {
        isLoading = true
        courses = dataService.availableCourses
        applyFilters()
        isLoading = false
    }
    
    func selectCourse(_ course: LanguageCourse) {
        currentCourse = course
        currentLesson = nil
        resetLessonState()
        
        // Update user's current course
        var updatedProgress = dataService.userProgress
        updatedProgress.currentCourse = course.id.uuidString
        dataService.updateUserProgress(updatedProgress)
        
        analyticsService.trackUserAction(action: "course_selected", context: ["courseId": course.id.uuidString, "title": course.title])
    }
    
    func startLesson(_ lesson: Lesson) {
        currentLesson = lesson
        resetLessonState()
        
        analyticsService.trackLessonStart(lessonId: lesson.id, courseId: currentCourse?.id ?? UUID())
    }
    
    private func applyFilters() {
        var filtered = courses
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = dataService.searchCourses(query: searchText)
        }
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        filteredCourses = filtered
    }
    
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedDifficulty = nil
    }
    
    // MARK: - Lesson Management
    private func resetLessonState() {
        currentQuestionIndex = 0
        selectedAnswers = []
        showResults = false
        lessonScore = 0.0
        isLessonCompleted = false
    }
    
    func selectAnswer(_ answerIndex: Int) {
        guard let lesson = currentLesson,
              currentQuestionIndex < lesson.questions.count else { return }
        
        // Ensure selectedAnswers array has enough elements
        while selectedAnswers.count <= currentQuestionIndex {
            selectedAnswers.append(-1)
        }
        
        selectedAnswers[currentQuestionIndex] = answerIndex
        
        analyticsService.trackQuizAttempt(
            questionId: lesson.questions[currentQuestionIndex].id,
            isCorrect: answerIndex == lesson.questions[currentQuestionIndex].correctAnswer,
            timeSpent: 0 // Would track actual time in real app
        )
    }
    
    func nextQuestion() {
        guard let lesson = currentLesson else { return }
        
        if currentQuestionIndex < lesson.questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            finishLesson()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func finishLesson() {
        guard let lesson = currentLesson,
              let course = currentCourse else { return }
        
        calculateScore()
        showResults = true
        isLessonCompleted = true
        
        // Update progress
        dataService.completeLesson(lessonId: lesson.id, courseId: course.id)
        
        // Track completion
        analyticsService.trackLessonCompletion(
            lessonId: lesson.id,
            courseId: course.id,
            timeSpent: lesson.duration,
            score: lessonScore
        )
        
        // Check if course is completed
        let completedLessons = course.lessons.filter { $0.isCompleted }.count + 1
        if completedLessons >= course.lessons.count {
            dataService.completeCourse(courseId: course.id)
        }
    }
    
    private func calculateScore() {
        guard let lesson = currentLesson else { return }
        
        let correctAnswers = lesson.questions.enumerated().reduce(0) { count, element in
            let (index, question) = element
            if index < selectedAnswers.count && selectedAnswers[index] == question.correctAnswer {
                return count + 1
            }
            return count
        }
        
        lessonScore = Double(correctAnswers) / Double(lesson.questions.count) * 100
    }
    
    func retryLesson() {
        resetLessonState()
    }
    
    func getNextLesson() -> Lesson? {
        guard let course = currentCourse,
              let currentIndex = course.lessons.firstIndex(where: { $0.id == currentLesson?.id }) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return nextIndex < course.lessons.count ? course.lessons[nextIndex] : nil
    }
    
    // MARK: - Progress Tracking
    func getLessonProgress() -> Double {
        guard let lesson = currentLesson else { return 0 }
        return Double(currentQuestionIndex) / Double(lesson.questions.count)
    }
    
    func getCourseProgress(for course: LanguageCourse) -> Double {
        let completedLessons = course.lessons.filter { $0.isCompleted }.count
        return Double(completedLessons) / Double(course.lessons.count)
    }
    
    // MARK: - Recommendations
    func getRecommendedCourses(limit: Int = 3) -> [LanguageCourse] {
        return dataService.getRecommendedCourses(limit: limit)
    }
    
    func getCoursesByCategory(_ category: LanguageCourse.CourseCategory) -> [LanguageCourse] {
        return courses.filter { $0.category == category }
    }
    
    func getCoursesByDifficulty(_ difficulty: LanguageCourse.DifficultyLevel) -> [LanguageCourse] {
        return courses.filter { $0.difficulty == difficulty }
    }
    
    // MARK: - Statistics
    func getOverallProgress() -> Double {
        let totalLessons = courses.flatMap { $0.lessons }.count
        let completedLessons = dataService.userProgress.totalLessonsCompleted
        return totalLessons > 0 ? Double(completedLessons) / Double(totalLessons) : 0
    }
    
    func getCompletedCoursesCount() -> Int {
        return dataService.userProgress.completedCourses.count
    }
    
    func getTotalStudyTime() -> Int {
        return dataService.userProgress.totalTimeSpent
    }
    
    // MARK: - Course Actions
    func toggleFavorite(for course: LanguageCourse) {
        // In a real app, you'd track favorites
        analyticsService.trackUserAction(action: "course_favorited", context: ["courseId": course.id.uuidString])
    }
    
    func downloadCourse(_ course: LanguageCourse) async {
        do {
            isLoading = true
            try await dataService.downloadCourse(courseId: course.id)
            analyticsService.trackUserAction(action: "course_downloaded", context: ["courseId": course.id.uuidString])
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func shareCourse(_ course: LanguageCourse) {
        analyticsService.trackUserAction(action: "course_shared", context: ["courseId": course.id.uuidString])
        // In a real app, you'd implement sharing functionality
    }
    
    // MARK: - Error Handling
    func clearError() {
        error = nil
    }
    
    // MARK: - Helper Methods
    func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
    }
    
    func getDifficultyColor(for difficulty: LanguageCourse.DifficultyLevel) -> Color {
        switch difficulty {
        case .beginner: return ColorThemes.beginnerColor
        case .intermediate: return ColorThemes.intermediateColor
        case .advanced: return ColorThemes.advancedColor
        }
    }
    
    func getCategoryIcon(for category: LanguageCourse.CourseCategory) -> String {
        return category.icon
    }
}


