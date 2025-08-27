//
//  OnboardingViewModel.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import Foundation
import Combine
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @AppStorage("isCompleted") var isCompleted = false
    @Published var userName = ""
    @Published var selectedLanguages: Set<String> = []
    @Published var selectedDifficulty: LanguageCourse.DifficultyLevel = .beginner
    @Published var learningGoals: Set<LearningGoal> = []
    @Published var dailyGoalMinutes = 15
    @Published var preferredStudyTime: Date = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var enableNotifications = true
    @Published var showFinancialTips = true
    
    // Animation states
    @Published var showWelcome = false
    @Published var showFeatures = false
    @Published var animateProgress = false
    
    private let dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    
    let totalSteps = 6
    let availableLanguages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Chinese", "Japanese"]
    
    enum LearningGoal: String, CaseIterable {
        case careerAdvancement = "Career Advancement"
        case financialLiteracy = "Financial Literacy"
        case travelPreparation = "Travel Preparation"
        case personalEnrichment = "Personal Enrichment"
        case businessCommunication = "Business Communication"
        case academicStudy = "Academic Study"
        
        var icon: String {
            switch self {
            case .careerAdvancement: return "briefcase.fill"
            case .financialLiteracy: return "dollarsign.circle.fill"
            case .travelPreparation: return "airplane"
            case .personalEnrichment: return "heart.fill"
            case .businessCommunication: return "person.2.fill"
            case .academicStudy: return "graduationcap.fill"
            }
        }
        
        var description: String {
            switch self {
            case .careerAdvancement: return "Advance your professional career"
            case .financialLiteracy: return "Master financial vocabulary and concepts"
            case .travelPreparation: return "Prepare for international travel"
            case .personalEnrichment: return "Learn for personal satisfaction"
            case .businessCommunication: return "Improve business communication"
            case .academicStudy: return "Support academic learning goals"
            }
        }
    }
    
    init() {
        // Check if onboarding was already completed
        if UserDefaults.standard.bool(forKey: "OnboardingCompleted") {
            isCompleted = true
        }
    }
    
    // MARK: - Navigation
    func nextStep() {
        withAnimation(AnimationPresets.spring) {
            if currentStep < totalSteps - 1 {
                currentStep += 1
                trackStepProgress()
            } else {
                completeOnboarding()
            }
        }
    }
    
    func previousStep() {
        withAnimation(AnimationPresets.spring) {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    func skipToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }
        
        withAnimation(AnimationPresets.smooth) {
            currentStep = step
        }
    }
    
    func skipOnboarding() {
        withAnimation(AnimationPresets.easeOut) {
            completeOnboarding()
        }
    }
    
    // MARK: - Data Management
    func toggleLanguage(_ language: String) {
        if selectedLanguages.contains(language) {
            selectedLanguages.remove(language)
        } else {
            selectedLanguages.insert(language)
        }
    }
    
    func toggleLearningGoal(_ goal: LearningGoal) {
        if learningGoals.contains(goal) {
            learningGoals.remove(goal)
        } else {
            learningGoals.insert(goal)
        }
    }
    
    func updateDailyGoal(_ minutes: Int) {
        dailyGoalMinutes = max(5, min(120, minutes)) // Clamp between 5-120 minutes
    }
    
    // MARK: - Validation
    func canProceedFromCurrentStep() -> Bool {
        switch currentStep {
        case 0: return true // Welcome screen
        case 1: return !userName.isEmpty && userName.count >= 2
        case 2: return !selectedLanguages.isEmpty
        case 3: return !learningGoals.isEmpty
        case 4: return dailyGoalMinutes >= 5
        case 5: return true // Preferences screen
        default: return true
        }
    }
    
    func getStepValidationMessage() -> String? {
        switch currentStep {
        case 1: return userName.isEmpty ? "Please enter your name" : nil
        case 2: return selectedLanguages.isEmpty ? "Please select at least one language" : nil
        case 3: return learningGoals.isEmpty ? "Please select at least one learning goal" : nil
        case 4: return dailyGoalMinutes < 5 ? "Please set a daily goal of at least 5 minutes" : nil
        default: return nil
        }
    }
    
    // MARK: - Completion
    private func completeOnboarding() {
        // Save user preferences
        saveUserPreferences()
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        isCompleted = true
        
        // Track completion
        analyticsService.trackUserAction(action: "onboarding_completed", context: [
            "steps_completed": totalSteps,
            "languages_selected": selectedLanguages.count,
            "goals_selected": learningGoals.count,
            "daily_goal": dailyGoalMinutes
        ])
        
        // Generate initial AI recommendations
        AIRecommendationService.shared.generatePersonalizedRecommendations()
    }
    
    private func saveUserPreferences() {
        var userProgress = dataService.userProgress
        
        // Update user preferences
        userProgress.preferences.preferredLanguages = Array(selectedLanguages)
        userProgress.preferences.difficultyPreference = selectedDifficulty
        userProgress.preferences.notificationsEnabled = enableNotifications
        userProgress.preferences.dailyReminderTime = preferredStudyTime
        userProgress.preferences.showFinancialTips = showFinancialTips
        userProgress.preferences.preferredLessonLength = dailyGoalMinutes
        userProgress.dailyGoal = dailyGoalMinutes
        userProgress.weeklyGoal = dailyGoalMinutes * 7
        
        // Save to data service
        dataService.updateUserProgress(userProgress)
    }
    
    // MARK: - Progress Tracking
    func getProgress() -> Double {
        return Double(currentStep) / Double(totalSteps - 1)
    }
    
    private func trackStepProgress() {
        analyticsService.trackUserAction(action: "onboarding_step_completed", context: [
            "step": currentStep,
            "progress": getProgress()
        ])
    }
    
    // MARK: - Animations
    func startWelcomeAnimation() {
        withAnimation(AnimationPresets.spring.delay(0.5)) {
            showWelcome = true
        }
    }
    
    func startFeatureAnimation() {
        withAnimation(AnimationPresets.spring.delay(0.3)) {
            showFeatures = true
        }
    }
    
    func animateProgressBar() {
        withAnimation(AnimationPresets.easeInOut) {
            animateProgress = true
        }
    }
    
    // MARK: - Step Content
    func getStepTitle() -> String {
        switch currentStep {
        case 0: return "Welcome to EduFortune"
        case 1: return "What's your name?"
        case 2: return "Which languages interest you?"
        case 3: return "What are your learning goals?"
        case 4: return "Set your daily goal"
        case 5: return "Customize your experience"
        default: return ""
        }
    }
    
    func getStepSubtitle() -> String {
        switch currentStep {
        case 0: return "Your journey to financial literacy through language learning starts here"
        case 1: return "We'd love to personalize your experience"
        case 2: return "Select the languages you want to learn"
        case 3: return "Help us tailor your learning path"
        case 4: return "How many minutes per day would you like to study?"
        case 5: return "Final touches to make EduFortune perfect for you"
        default: return ""
        }
    }
    
    func getStepIcon() -> String {
        switch currentStep {
        case 0: return "star.fill"
        case 1: return "person.fill"
        case 2: return "globe"
        case 3: return "target"
        case 4: return "clock.fill"
        case 5: return "gearshape.fill"
        default: return "checkmark"
        }
    }
    
    // MARK: - Recommendations Preview
    func getPreviewCourses() -> [LanguageCourse] {
        let allCourses = LanguageCourse.sampleCourses
        
        // Filter based on selected preferences
        let filteredCourses = allCourses.filter { course in
            if selectedLanguages.isEmpty { return true }
            return selectedLanguages.contains(course.language)
        }
        
        return Array(filteredCourses.prefix(2))
    }
    
    func getPersonalizedMessage() -> String {
        let goalCount = learningGoals.count
        let languageCount = selectedLanguages.count
        
        if goalCount == 0 && languageCount == 0 {
            return "Ready to start your learning journey!"
        } else if goalCount == 1 && languageCount == 1 {
            return "Perfect! We've found courses that match your goal of \(learningGoals.first?.rawValue ?? "") in \(selectedLanguages.first ?? "your selected language")."
        } else {
            return "Great choices! We've curated a learning path that combines your \(goalCount) goals across \(languageCount) language\(languageCount == 1 ? "" : "s")."
        }
    }
    
    // MARK: - Helper Methods
    func getDailyGoalDescription() -> String {
        switch dailyGoalMinutes {
        case 5..<15: return "Light learning - perfect for busy schedules"
        case 15..<30: return "Steady progress - recommended for most learners"
        case 30..<60: return "Intensive learning - accelerated progress"
        default: return "Expert dedication - maximum growth potential"
        }
    }
    
    func getEstimatedWeeklyTime() -> String {
        let weeklyMinutes = dailyGoalMinutes * 7
        let hours = weeklyMinutes / 60
        let minutes = weeklyMinutes % 60
        
        if hours == 0 {
            return "\(minutes) minutes per week"
        } else if minutes == 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") per week"
        } else {
            return "\(hours)h \(minutes)m per week"
        }
    }
    
    // MARK: - Reset (for testing)
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "OnboardingCompleted")
        currentStep = 0
        isCompleted = false
        userName = ""
        selectedLanguages.removeAll()
        selectedDifficulty = .beginner
        learningGoals.removeAll()
        dailyGoalMinutes = 15
        enableNotifications = true
        showFinancialTips = true
    }
}



