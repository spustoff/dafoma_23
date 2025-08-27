//
//  CourseDetailView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct CourseDetailView: View {
    let course: LanguageCourse
    @ObservedObject var viewModel: CourseViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showLessonView = false
    @State private var selectedLesson: Lesson?
    @State private var showNoLessonsAlert = false
    @State private var isDataLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                if !isDataLoaded {
                    // Loading state
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: ColorThemes.primaryBlue))
                        Text("Loading course details...")
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                            .padding(.top, Spacing.md)
                        Spacer()
                    }
                } else {
                    ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        courseHeader
                        
                        // Course info
                        courseInfo
                        
                        // Progress section
                        if course.progress > 0 {
                            progressSection
                        }
                        
                        // Lessons list
                        lessonsSection
                        
                        // Financial tip
                        if let firstLesson = course.lessons.first,
                           let tip = firstLesson.financialTip {
                            financialTipSection(tip)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, 100) // Space for floating button
                    }
                    
                    // Floating start button
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Group {
                            if course.lessons.isEmpty {
                                // Show disabled button when no lessons
                                FloatingActionButton(
                                    "exclamationmark.triangle.fill",
                                    backgroundColor: ColorThemes.textTertiary
                                ) {
                                    print("No lessons available for course: \(course.title)")
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    showNoLessonsAlert = true
                                }
                            } else {
                                FloatingActionButton(
                                    course.progress > 0 ? "arrow.right.circle.fill" : "play.circle.fill",
                                    backgroundColor: ColorThemes.primaryBlue
                                ) {
                                    print("Play button tapped - starting course: \(course.title)")
                                    // Add haptic feedback for better user experience
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    startCourse()
                                }
                            }
                        }
                        .padding(.trailing, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                    }
                }
            }
        }
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Menu {
                    Button(action: { viewModel.toggleFavorite(for: course) }) {
                        Label("Favorite", systemImage: "heart")
                    }
                    
                    Button(action: { viewModel.shareCourse(course) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    if !course.isUnlocked {
                        Button(action: { 
                            Task {
                                await viewModel.downloadCourse(course)
                            }
                        }) {
                            Label("Download", systemImage: "arrow.down.circle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(ColorThemes.textPrimary)
                }
            )
        }
        .sheet(isPresented: $showLessonView) {
            if let lesson = selectedLesson {
                LessonView(lesson: lesson, course: course, viewModel: viewModel)
            }
        }
        .alert("No Lessons Available", isPresented: $showNoLessonsAlert) {
            Button("OK") { }
        } message: {
            Text("This course doesn't have any lessons available yet. Please check back later or contact support.")
        }
        .onAppear {
            // Simulate data loading delay to ensure proper initialization
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isDataLoaded = true
            }
        }
    }
    
    // MARK: - Course Header
    private var courseHeader: some View {
        VStack(spacing: Spacing.md) {
            // Course icon
            ZStack {
                Circle()
                    .fill(ColorThemes.primaryGradient)
                    .frame(width: 100, height: 100)
                    .shadow(color: ColorThemes.primaryBlue.opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: course.imageSystemName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(ColorThemes.textPrimary)
            }
            
            // Title and description
            VStack(spacing: Spacing.sm) {
                Text(course.title)
                    .font(Typography.title1)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(course.description)
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
            }
        }
        .padding(.top, Spacing.lg)
    }
    
    // MARK: - Course Info
    private var courseInfo: some View {
        HStack(spacing: Spacing.lg) {
            infoCard(
                icon: "clock.fill",
                title: viewModel.formatDuration(course.estimatedDuration),
                subtitle: "Duration"
            )
            
            infoCard(
                icon: "book.fill",
                title: "\(course.lessons.count)",
                subtitle: "Lessons"
            )
            
            infoCard(
                icon: course.category.icon,
                title: course.category.rawValue,
                subtitle: "Category"
            )
        }
    }
    
    private func infoCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ColorThemes.primaryBlue)
            
            Text(title)
                .font(Typography.headline.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(subtitle)
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                Text("Your Progress")
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
                
                Text("\(Int(course.progress * 100))% Complete")
                    .font(Typography.body)
                    .foregroundColor(ColorThemes.primaryBlue)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorThemes.surfaceSecondary)
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(ColorThemes.primaryBlue)
                    .frame(width: max(0, UIScreen.main.bounds.width * 0.8 * course.progress), height: 4)
                    .animation(AnimationPresets.easeInOut, value: course.progress)
            }
            
            HStack {
                let completedLessons = Int(Double(course.lessons.count) * course.progress)
                Text("\(completedLessons) of \(course.lessons.count) lessons completed")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
                
                Spacer()
            }
        }
        .padding(Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Lessons Section
    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Lessons")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            if course.lessons.isEmpty {
                // No lessons available state
                VStack(spacing: Spacing.md) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(ColorThemes.textTertiary)
                    
                    Text("No Lessons Available")
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text("This course doesn't have any lessons yet. Check back later for updates.")
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
                .padding(Spacing.xl)
                .cardStyle()
            } else {
                LazyVStack(spacing: Spacing.sm) {
                    ForEach(Array(course.lessons.enumerated()), id: \.element.id) { index, lesson in
                        LessonCard(
                            lesson: lesson,
                            index: index + 1,
                            isLocked: !course.isUnlocked && index > 0
                        ) {
                            if course.isUnlocked || index == 0 {
                                selectedLesson = lesson
                                viewModel.startLesson(lesson)
                                showLessonView = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Financial Tip Section
    private func financialTipSection(_ tip: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(ColorThemes.financialGold)
                
                Text("Financial Tip")
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
    
    // MARK: - Actions
    private func startCourse() {
        print("startCourse() called for course: \(course.title)")
        
        // Ensure we have lessons available
        guard !course.lessons.isEmpty else {
            print("Error: Course has no lessons available")
            showNoLessonsAlert = true
            return
        }
        
        // Select the course in the view model
        viewModel.selectCourse(course)
        print("Course selected in view model")
        
        // Find the appropriate lesson to start
        let lessonToStart: Lesson
        if let firstIncompleteLesson = course.lessons.first(where: { !$0.isCompleted }) {
            lessonToStart = firstIncompleteLesson
            print("Starting first incomplete lesson: \(lessonToStart.title)")
        } else if let firstLesson = course.lessons.first {
            lessonToStart = firstLesson
            print("Starting first lesson (all completed): \(lessonToStart.title)")
        } else {
            print("Error: No suitable lesson found to start")
            return
        }
        
        // Start the lesson
        selectedLesson = lessonToStart
        viewModel.startLesson(lessonToStart)
        
        // Show the lesson view with a slight delay to ensure state is updated
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showLessonView = true
            print("Lesson view should now be displayed")
        }
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let lesson: Lesson
    let index: Int
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Lesson number/status
                ZStack {
                    Circle()
                        .fill(backgroundColorForLesson)
                        .frame(width: 40, height: 40)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundColor(ColorThemes.textPrimary)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.body)
                            .foregroundColor(ColorThemes.textTertiary)
                    } else {
                        Text("\(index)")
                            .font(Typography.headline.weight(.bold))
                            .foregroundColor(ColorThemes.textPrimary)
                    }
                }
                
                // Lesson info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(lesson.title)
                            .font(Typography.headline)
                            .foregroundColor(isLocked ? ColorThemes.textTertiary : ColorThemes.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: lesson.type.icon)
                                .font(.caption)
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text(lesson.type.rawValue)
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                    }
                    
                    HStack {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text("\(lesson.duration) min")
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                        
                        Spacer()
                        
                        if lesson.questions.count > 0 {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "questionmark.circle")
                                    .font(.caption)
                                    .foregroundColor(ColorThemes.textTertiary)
                                
                                Text("\(lesson.questions.count) questions")
                                    .font(Typography.caption2)
                                    .foregroundColor(ColorThemes.textTertiary)
                            }
                        }
                    }
                }
                
                // Arrow
                if !isLocked {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundColor(ColorThemes.textTertiary)
                }
            }
            .padding(Spacing.md)
            .background(ColorThemes.surfacePrimary)
            .cornerRadius(CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .stroke(ColorThemes.borderPrimary, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .opacity(isLocked ? 0.6 : 1.0)
    }
    
    private var backgroundColorForLesson: Color {
        if lesson.isCompleted {
            return ColorThemes.success
        } else if isLocked {
            return ColorThemes.surfaceSecondary
        } else {
            return ColorThemes.primaryBlue
        }
    }
}
