//
//  LessonView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let course: LanguageCourse
    @ObservedObject var viewModel: CourseViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showVocabulary = false
    @State private var showResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.showResults {
                    resultsView
                } else {
                    lessonContentView
                }
            }
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: HStack {
                    if !lesson.vocabulary.isEmpty {
                        Button("Vocabulary") {
                            showVocabulary = true
                        }
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.primaryBlue)
                    }
                    
                    Text("\(viewModel.currentQuestionIndex + 1)/\(lesson.questions.count)")
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textSecondary)
                }
            )
        }
        .sheet(isPresented: $showVocabulary) {
            VocabularyView(vocabulary: lesson.vocabulary)
        }
        .onAppear {
            viewModel.startLesson(lesson)
        }
    }
    
    // MARK: - Lesson Content View
    private var lessonContentView: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
            
            // Main content
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Lesson header
                    lessonHeader
                    
                    // Financial tip (if available)
                    if let tip = lesson.financialTip {
                        financialTipCard(tip)
                    }
                    
                    // Question content
                    if viewModel.currentQuestionIndex < lesson.questions.count {
                        questionView
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, 120) // Space for navigation buttons
            }
            
            Spacer()
            
            // Navigation buttons
            navigationButtons
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: Spacing.sm) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorThemes.surfaceSecondary)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorThemes.primaryBlue)
                    .frame(width: max(0, UIScreen.main.bounds.width * 0.9 * viewModel.getLessonProgress()), height: 4)
                    .animation(AnimationPresets.easeInOut, value: viewModel.getLessonProgress())
            }
            
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(lesson.questions.count)")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
                
                Spacer()
                
                Text("\(Int(viewModel.getLessonProgress() * 100))% Complete")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.primaryBlue)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.top, Spacing.md)
    }
    
    // MARK: - Lesson Header
    private var lessonHeader: some View {
        VStack(spacing: Spacing.md) {
            // Lesson type icon
            ZStack {
                Circle()
                    .fill(ColorThemes.primaryGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: lesson.type.icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(ColorThemes.textPrimary)
            }
            
            VStack(spacing: Spacing.sm) {
                Text(lesson.title)
                    .font(Typography.title1)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(lesson.content)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Financial Tip Card
    private func financialTipCard(_ tip: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(ColorThemes.financialGold)
                
                Text("💡 Financial Tip")
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
            }
            
            Text(tip)
                .font(Typography.body)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .padding(Spacing.md)
        .background(ColorThemes.financialGold.opacity(0.1))
        .cornerRadius(CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(ColorThemes.financialGold.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Question View
    private var questionView: some View {
        let question = lesson.questions[viewModel.currentQuestionIndex]
        
        return VStack(spacing: Spacing.lg) {
            // Question text
            VStack(spacing: Spacing.md) {
                Text("Question \(viewModel.currentQuestionIndex + 1)")
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.primaryBlue)
                
                Text(question.question)
                    .font(Typography.title3)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }
            .padding(Spacing.lg)
            .cardStyle()
            
            // Answer options
            VStack(spacing: Spacing.md) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    answerButton(option: option, index: index, question: question)
                }
            }
        }
    }
    
    private func answerButton(option: String, index: Int, question: Question) -> some View {
        let isSelected = viewModel.selectedAnswers.count > viewModel.currentQuestionIndex &&
                        viewModel.selectedAnswers[viewModel.currentQuestionIndex] == index
        let isCorrect = index == question.correctAnswer
        let showFeedback = isSelected && viewModel.selectedAnswers.count > viewModel.currentQuestionIndex
        
        return Button {
            viewModel.selectAnswer(index)
        } label: {
            HStack(spacing: Spacing.md) {
                // Option letter
                ZStack {
                    Circle()
                        .fill(backgroundColor(isSelected: isSelected, isCorrect: isCorrect, showFeedback: showFeedback))
                        .frame(width: 30, height: 30)
                    
                    Text(optionLetter(for: index))
                        .font(Typography.body.weight(.bold))
                        .foregroundColor(ColorThemes.textPrimary)
                }
                
                // Option text
                Text(option)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Feedback icon
                if showFeedback {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(isCorrect ? ColorThemes.success : ColorThemes.error)
                }
            }
            .padding(Spacing.md)
            .background(backgroundColorForOption(isSelected: isSelected, isCorrect: isCorrect, showFeedback: showFeedback))
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(borderColor(isSelected: isSelected, isCorrect: isCorrect, showFeedback: showFeedback), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSelected)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: Spacing.md) {
            // Previous button
            if viewModel.currentQuestionIndex > 0 {
                Button("Previous") {
                    viewModel.previousQuestion()
                }
                .secondaryButton()
            }
            
            Spacer()
            
            // Next/Finish button
            let hasAnswered = viewModel.selectedAnswers.count > viewModel.currentQuestionIndex &&
                             viewModel.selectedAnswers[viewModel.currentQuestionIndex] >= 0
            let isLastQuestion = viewModel.currentQuestionIndex >= lesson.questions.count - 1
            
            GlowingButton(
                isLastQuestion ? "Finish Lesson" : "Next Question",
                icon: isLastQuestion ? "checkmark.circle.fill" : "arrow.right",
                isEnabled: hasAnswered
            ) {
                if isLastQuestion {
                    viewModel.finishLesson()
                } else {
                    viewModel.nextQuestion()
                }
            }
        }
        .padding(Spacing.lg)
        .background(ColorThemes.backgroundPrimary.opacity(0.9))
    }
    
    // MARK: - Results View
    private var resultsView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Results header
            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(scoreColor.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(scoreColor, lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    VStack {
                        Text("\(Int(viewModel.lessonScore))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(scoreColor)
                        
                        Text("%")
                            .font(Typography.title3)
                            .foregroundColor(scoreColor)
                    }
                }
                
                Text(scoreMessage)
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("You answered \(correctAnswersCount) out of \(lesson.questions.count) questions correctly")
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Experience gained
            VStack(spacing: Spacing.sm) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(ColorThemes.financialGold)
                    
                    Text("+\(experienceGained) XP")
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                }
                
                Text("Experience gained")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
            }
            .padding(Spacing.md)
            .glassStyle()
            
            Spacer()
            
            // Action buttons
            VStack(spacing: Spacing.md) {
                if viewModel.lessonScore < 80 {
                    GlowingButton("Retry Lesson", icon: "arrow.clockwise") {
                        viewModel.retryLesson()
                    }
                }
                
                if let nextLesson = viewModel.getNextLesson() {
                    GlowingButton("Next Lesson", icon: "arrow.right.circle.fill") {
                        viewModel.startLesson(nextLesson)
                    }
                } else {
                    GlowingButton("Complete Course", icon: "checkmark.circle.fill") {
                        // Course completion logic
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                Button("Back to Course") {
                    presentationMode.wrappedValue.dismiss()
                }
                .secondaryButton()
            }
        }
        .padding(Spacing.lg)
    }
    
    // MARK: - Helper Methods
    private func optionLetter(for index: Int) -> String {
        return String(UnicodeScalar(65 + index)!)
    }
    
    private func backgroundColor(isSelected: Bool, isCorrect: Bool, showFeedback: Bool) -> Color {
        if showFeedback {
            return isCorrect ? ColorThemes.success : ColorThemes.error
        }
        return isSelected ? ColorThemes.primaryBlue : ColorThemes.surfaceSecondary
    }
    
    private func backgroundColorForOption(isSelected: Bool, isCorrect: Bool, showFeedback: Bool) -> Color {
        if showFeedback {
            return isCorrect ? ColorThemes.success.opacity(0.1) : ColorThemes.error.opacity(0.1)
        }
        return isSelected ? ColorThemes.primaryBlue.opacity(0.1) : ColorThemes.surfacePrimary
    }
    
    private func borderColor(isSelected: Bool, isCorrect: Bool, showFeedback: Bool) -> Color {
        if showFeedback {
            return isCorrect ? ColorThemes.success : ColorThemes.error
        }
        return isSelected ? ColorThemes.primaryBlue : ColorThemes.borderPrimary
    }
    
    private var scoreColor: Color {
        switch viewModel.lessonScore {
        case 90...: return ColorThemes.success
        case 70..<90: return ColorThemes.warning
        default: return ColorThemes.error
        }
    }
    
    private var scoreMessage: String {
        switch viewModel.lessonScore {
        case 90...: return "Excellent! 🎉"
        case 80..<90: return "Great job! 👏"
        case 70..<80: return "Good work! 👍"
        case 60..<70: return "Keep practicing! 💪"
        default: return "Try again! 📚"
        }
    }
    
    private var correctAnswersCount: Int {
        return lesson.questions.enumerated().reduce(0) { count, element in
            let (index, question) = element
            if index < viewModel.selectedAnswers.count && viewModel.selectedAnswers[index] == question.correctAnswer {
                return count + 1
            }
            return count
        }
    }
    
    private var experienceGained: Int {
        let baseXP = 10
        let bonusXP = Int(viewModel.lessonScore / 10)
        return baseXP + bonusXP
    }
}

// MARK: - Vocabulary View
struct VocabularyView: View {
    let vocabulary: [VocabularyItem]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(vocabulary) { item in
                            VocabularyCard(item: item)
                        }
                    }
                    .padding(Spacing.md)
                }
            }
            .navigationTitle("Vocabulary")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Vocabulary Card
struct VocabularyCard: View {
    let item: VocabularyItem
    @State private var showDefinition = false
    
    var body: some View {
        InteractiveCard {
            withAnimation(AnimationPresets.spring) {
                showDefinition.toggle()
            }
        } content: {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Word and pronunciation
                HStack {
                    Text(item.word)
                        .font(Typography.title3.weight(.bold))
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    if let pronunciation = item.pronunciation {
                        Text(pronunciation)
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: showDefinition ? "chevron.up" : "chevron.down")
                        .font(.body)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                if showDefinition {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text(item.definition)
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                        
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Example:")
                                .font(Typography.caption1.weight(.medium))
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text(item.example)
                                .font(Typography.body)
                                .foregroundColor(ColorThemes.textPrimary)
                                .italic()
                        }
                        
                        if let context = item.financialContext {
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Financial Context:")
                                    .font(Typography.caption1.weight(.medium))
                                    .foregroundColor(ColorThemes.financialGold)
                                
                                Text(context)
                                    .font(Typography.body)
                                    .foregroundColor(ColorThemes.textSecondary)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(Spacing.md)
        }
    }
}
