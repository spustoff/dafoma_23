//
//  OnboardingView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Background gradient
            ColorThemes.backgroundGradient
                .ignoresSafeArea()
            
            if showContent {
                VStack(spacing: 0) {
                    // Progress indicator
                    progressIndicator
                    
                    // Main content
                    TabView(selection: $viewModel.currentStep) {
                        ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                            stepContent(for: step)
                                .tag(step)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(AnimationPresets.spring, value: viewModel.currentStep)
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
        }
        .onAppear {
            withAnimation(AnimationPresets.spring.delay(0.3)) {
                showContent = true
            }
            viewModel.startWelcomeAnimation()
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: Spacing.md) {
            // Progress bar
            HStack {
                ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step <= viewModel.currentStep ? ColorThemes.primaryBlue : ColorThemes.surfaceSecondary)
                        .frame(height: 4)
                        .animation(AnimationPresets.easeInOut.delay(Double(step) * 0.1), value: viewModel.currentStep)
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            // Step indicator
            Text("Step \(viewModel.currentStep + 1) of \(viewModel.totalSteps)")
                .font(Typography.caption1)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private func stepContent(for step: Int) -> some View {
        switch step {
        case 0:
            welcomeStep
        case 1:
            nameStep
        case 2:
            languageStep
        case 3:
            goalsStep
        case 4:
            dailyGoalStep
        case 5:
            preferencesStep
        default:
            EmptyView()
        }
    }
    
    // MARK: - Welcome Step
    private var welcomeStep: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // App logo/icon
            ZStack {
                Circle()
                    .fill(ColorThemes.primaryGradient)
                    .frame(width: 120, height: 120)
                    .shadow(color: ColorThemes.primaryBlue.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(ColorThemes.textPrimary)
            }
            .scaleEffect(viewModel.showWelcome ? 1.0 : 0.8)
            .opacity(viewModel.showWelcome ? 1.0 : 0.0)
            
            VStack(spacing: Spacing.md) {
                Text("Welcome to EduFortune")
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Master language learning through financial literacy")
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }
            .opacity(viewModel.showWelcome ? 1.0 : 0.0)
            .offset(y: viewModel.showWelcome ? 0 : 20)
            
            // Features preview
            if viewModel.showFeatures {
                VStack(spacing: Spacing.md) {
                    featureRow(icon: "dollarsign.circle.fill", title: "Financial Vocabulary", description: "Learn money terms in context")
                    featureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "See your improvement over time")
                    featureRow(icon: "brain.head.profile", title: "AI Recommendations", description: "Personalized learning paths")
                }
                .padding(.horizontal, Spacing.lg)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
        .onAppear {
            viewModel.startFeatureAnimation()
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorThemes.primaryBlue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Text(description)
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
            }
            
            Spacer()
        }
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Name Step
    private var nameStep: some View {
        VStack(spacing: Spacing.xl) {
            stepHeader(
                icon: "person.fill",
                title: "What's your name?",
                subtitle: "We'd love to personalize your experience"
            )
            
            VStack(spacing: Spacing.lg) {
                TextField("Enter your name", text: $viewModel.userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(Typography.body)
                    .padding(.horizontal, Spacing.lg)
                
                if let message = viewModel.getStepValidationMessage() {
                    Text(message)
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.error)
                }
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
    
    // MARK: - Language Step
    private var languageStep: some View {
        VStack(spacing: Spacing.xl) {
            stepHeader(
                icon: "globe",
                title: "Which languages interest you?",
                subtitle: "Select the languages you want to learn"
            )
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.md) {
                    ForEach(viewModel.availableLanguages, id: \.self) { language in
                        languageCard(language)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            
            Spacer()
        }
        .padding(.top, Spacing.lg)
    }
    
    private func languageCard(_ language: String) -> some View {
        let isSelected = viewModel.selectedLanguages.contains(language)
        
        return Button {
            withAnimation(AnimationPresets.spring) {
                viewModel.toggleLanguage(language)
            }
        } label: {
            HStack {
                Text(getLanguageFlag(language))
                    .font(.title2)
                
                Text(language)
                    .font(Typography.body.weight(.medium))
                    .foregroundColor(isSelected ? ColorThemes.textPrimary : ColorThemes.textSecondary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorThemes.success)
                        .font(.title3)
                }
            }
            .padding(Spacing.md)
            .background(isSelected ? ColorThemes.primaryBlue.opacity(0.2) : ColorThemes.surfacePrimary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? ColorThemes.primaryBlue : ColorThemes.borderPrimary, lineWidth: isSelected ? 2 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
    
    // MARK: - Goals Step
    private var goalsStep: some View {
        VStack(spacing: Spacing.xl) {
            stepHeader(
                icon: "target",
                title: "What are your learning goals?",
                subtitle: "Help us tailor your learning path"
            )
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible())], spacing: Spacing.md) {
                    ForEach(OnboardingViewModel.LearningGoal.allCases, id: \.self) { goal in
                        goalCard(goal)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
            
            Spacer()
        }
        .padding(.top, Spacing.lg)
    }
    
    private func goalCard(_ goal: OnboardingViewModel.LearningGoal) -> some View {
        let isSelected = viewModel.learningGoals.contains(goal)
        
        return Button {
            withAnimation(AnimationPresets.spring) {
                viewModel.toggleLearningGoal(goal)
            }
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? ColorThemes.primaryBlue : ColorThemes.textSecondary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(Typography.headline)
                        .foregroundColor(isSelected ? ColorThemes.textPrimary : ColorThemes.textSecondary)
                    
                    Text(goal.description)
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ColorThemes.success)
                        .font(.title3)
                }
            }
            .padding(Spacing.md)
            .background(isSelected ? ColorThemes.primaryBlue.opacity(0.2) : ColorThemes.surfacePrimary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(isSelected ? ColorThemes.primaryBlue : ColorThemes.borderPrimary, lineWidth: isSelected ? 2 : 1)
            )
        }
        .scaleEffect(isSelected ? 1.01 : 1.0)
    }
    
    // MARK: - Daily Goal Step
    private var dailyGoalStep: some View {
        VStack(spacing: Spacing.xl) {
            stepHeader(
                icon: "clock.fill",
                title: "Set your daily goal",
                subtitle: "How many minutes per day would you like to study?"
            )
            
            VStack(spacing: Spacing.lg) {
                // Goal display
                VStack(spacing: Spacing.md) {
                    Text("\(viewModel.dailyGoalMinutes)")
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(ColorThemes.primaryBlue)
                    
                    Text("minutes per day")
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textSecondary)
                    
                    Text(viewModel.getDailyGoalDescription())
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                
                // Slider
                VStack(spacing: Spacing.sm) {
                    Slider(value: Binding(
                        get: { Double(viewModel.dailyGoalMinutes) },
                        set: { viewModel.updateDailyGoal(Int($0)) }
                    ), in: 5...120, step: 5)
                    .accentColor(ColorThemes.primaryBlue)
                    .padding(.horizontal, Spacing.lg)
                    
                    HStack {
                        Text("5 min")
                            .font(Typography.caption2)
                            .foregroundColor(ColorThemes.textTertiary)
                        
                        Spacer()
                        
                        Text("120 min")
                            .font(Typography.caption2)
                            .foregroundColor(ColorThemes.textTertiary)
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                
                // Weekly estimate
                Text("≈ \(viewModel.getEstimatedWeeklyTime())")
                    .font(Typography.body.weight(.medium))
                    .foregroundColor(ColorThemes.primaryBlue)
                    .padding(.top, Spacing.md)
            }
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
    
    // MARK: - Preferences Step
    private var preferencesStep: some View {
        VStack(spacing: Spacing.xl) {
            stepHeader(
                icon: "gearshape.fill",
                title: "Customize your experience",
                subtitle: "Final touches to make EduFortune perfect for you"
            )
            
            VStack(spacing: Spacing.lg) {
                // Difficulty preference
                preferenceCard(
                    icon: "chart.bar.fill",
                    title: "Difficulty Level",
                    subtitle: "Choose your starting difficulty"
                ) {
                    Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                        ForEach(LanguageCourse.DifficultyLevel.allCases, id: \.self) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Notifications
                preferenceCard(
                    icon: "bell.fill",
                    title: "Daily Reminders",
                    subtitle: "Get notified to maintain your streak"
                ) {
                    Toggle("Enable Notifications", isOn: $viewModel.enableNotifications)
                        .toggleStyle(SwitchToggleStyle(tint: ColorThemes.primaryBlue))
                }
                
                // Financial tips
                preferenceCard(
                    icon: "dollarsign.circle.fill",
                    title: "Financial Tips",
                    subtitle: "Show daily financial literacy tips"
                ) {
                    Toggle("Show Financial Tips", isOn: $viewModel.showFinancialTips)
                        .toggleStyle(SwitchToggleStyle(tint: ColorThemes.primaryBlue))
                }
            }
            
            // Personalized message
            Text(viewModel.getPersonalizedMessage())
                .font(Typography.body)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
    
    private func preferenceCard<Content: View>(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
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
            }
            
            content()
        }
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: Spacing.md) {
            // Back button
            if viewModel.currentStep > 0 {
                Button("Back") {
                    viewModel.previousStep()
                }
                .secondaryButton()
            }
            
            Spacer()
            
            // Skip button (only on first few steps)
            if viewModel.currentStep < 3 {
                Button("Skip") {
                    viewModel.skipOnboarding()
                }
                .foregroundColor(ColorThemes.textTertiary)
                .font(Typography.body)
            }
            
            // Next/Complete button
            GlowingButton(
                viewModel.currentStep == viewModel.totalSteps - 1 ? "Get Started" : "Next",
                icon: viewModel.currentStep == viewModel.totalSteps - 1 ? "arrow.right.circle.fill" : "arrow.right",
                isEnabled: viewModel.canProceedFromCurrentStep()
            ) {
                viewModel.nextStep()
            }
        }
        .padding(Spacing.lg)
    }
    
    // MARK: - Helper Views
    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(ColorThemes.primaryBlue)
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(Typography.title1)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getLanguageFlag(_ language: String) -> String {
        switch language {
        case "English": return "🇺🇸"
        case "Spanish": return "🇪🇸"
        case "French": return "🇫🇷"
        case "German": return "🇩🇪"
        case "Italian": return "🇮🇹"
        case "Portuguese": return "🇵🇹"
        case "Chinese": return "🇨🇳"
        case "Japanese": return "🇯🇵"
        default: return "🌍"
        }
    }
}




