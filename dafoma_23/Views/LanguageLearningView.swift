//
//  LanguageLearningView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct LanguageLearningView: View {
    @StateObject private var viewModel = CourseViewModel()
    @State private var showCourseDetail = false
    @State private var showLessonView = false
    @State private var selectedCourse: LanguageCourse?
    @State private var searchText = ""
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        headerSection
                        
                        // Search and filters
                        searchSection
                        
                        // Recommended courses
                        recommendedSection
                        
                        // Course categories
                        categoriesSection
                        
                        // All courses
                        allCoursesSection
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCourseDetail) {
                if let course = selectedCourse {
                    CourseDetailView(course: course, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadCourses()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learn & Grow")
                        .font(Typography.largeTitle)
                        .foregroundColor(ColorThemes.textPrimary)
                    
                    Text("Master financial vocabulary through interactive lessons")
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                }
                
                Spacer()
                
                // Progress indicator
                ProgressRing(
                    progress: viewModel.getOverallProgress(),
                    lineWidth: 6,
                    size: 60,
                    showPercentage: false
                )
            }
            
            // Quick stats
            HStack(spacing: Spacing.lg) {
                statCard(
                    icon: "book.fill",
                    value: "\(viewModel.getCompletedCoursesCount())",
                    label: "Completed"
                )
                
                statCard(
                    icon: "clock.fill",
                    value: "\(viewModel.getTotalStudyTime())m",
                    label: "Study Time"
                )
                
                statCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(viewModel.getOverallProgress() * 100))%",
                    label: "Progress"
                )
            }
        }
        .padding(.top, Spacing.lg)
    }
    
    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ColorThemes.primaryBlue)
            
            Text(value)
                .font(Typography.headline.weight(.bold))
                .foregroundColor(ColorThemes.textPrimary)
            
            Text(label)
                .font(Typography.caption2)
                .foregroundColor(ColorThemes.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.sm)
        .glassStyle()
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.sm) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorThemes.textSecondary)
                    
                    TextField("Search courses...", text: $viewModel.searchText)
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textPrimary)
                }
                .padding(Spacing.md)
                .background(ColorThemes.surfacePrimary)
                .cornerRadius(CornerRadius.medium)
                
                // Filter button
                Button {
                    showFilters = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(ColorThemes.textPrimary)
                        .padding(Spacing.md)
                        .background(ColorThemes.surfacePrimary)
                        .cornerRadius(CornerRadius.medium)
                }
            }
            
            // Active filters
            if viewModel.selectedCategory != nil || viewModel.selectedDifficulty != nil {
                activeFiltersView
            }
        }
    }
    
    private var activeFiltersView: some View {
        HStack {
            if let category = viewModel.selectedCategory {
                filterChip(title: category.rawValue, icon: category.icon) {
                    viewModel.selectedCategory = nil
                }
            }
            
            if let difficulty = viewModel.selectedDifficulty {
                filterChip(title: difficulty.rawValue, icon: nil) {
                    viewModel.selectedDifficulty = nil
                }
            }
            
            Spacer()
            
            Button("Clear All") {
                viewModel.clearFilters()
            }
            .font(Typography.caption1)
            .foregroundColor(ColorThemes.primaryBlue)
        }
    }
    
    private func filterChip(title: String, icon: String?, action: @escaping () -> Void) -> some View {
        HStack(spacing: Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            
            Text(title)
                .font(Typography.caption1)
            
            Button(action: action) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(ColorThemes.primaryBlue.opacity(0.2))
        .foregroundColor(ColorThemes.primaryBlue)
        .cornerRadius(CornerRadius.small)
    }
    
    // MARK: - Recommended Section
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recommended for You")
                    .font(Typography.title2)
                    .foregroundColor(ColorThemes.textPrimary)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all recommended courses
                }
                .font(Typography.body)
                .foregroundColor(ColorThemes.primaryBlue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(viewModel.getRecommendedCourses()) { course in
                        RecommendedCourseCard(course: course) {
                            selectedCourse = course
                            showCourseDetail = true
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse by Category")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(LanguageCourse.CourseCategory.allCases, id: \.self) { category in
                        CategoryCard(category: category) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
    
    // MARK: - All Courses Section
    private var allCoursesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("All Courses")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.filteredCourses) { course in
                    CourseCard(course: course, viewModel: viewModel) {
                        selectedCourse = course
                        showCourseDetail = true
                    }
                }
            }
        }
    }
}

// MARK: - Recommended Course Card
struct RecommendedCourseCard: View {
    let course: LanguageCourse
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                HStack {
                    Image(systemName: course.imageSystemName)
                        .font(.title2)
                        .foregroundColor(ColorThemes.primaryBlue)
                    
                    Spacer()
                    
                    DifficultyBadge(course.difficulty, compact: true)
                }
                
                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(course.title)
                        .font(Typography.headline)
                        .foregroundColor(ColorThemes.textPrimary)
                        .lineLimit(2)
                    
                    Text(course.description)
                        .font(Typography.caption1)
                        .foregroundColor(ColorThemes.textSecondary)
                        .lineLimit(3)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(ColorThemes.textTertiary)
                        
                        Text("\(course.estimatedDuration) min")
                            .font(Typography.caption2)
                            .foregroundColor(ColorThemes.textTertiary)
                        
                        Spacer()
                        
                        ProgressRing(
                            progress: course.progress,
                            lineWidth: 3,
                            size: 24,
                            showPercentage: false
                        )
                    }
                }
            }
            .padding(Spacing.md)
            .frame(width: 280, height: 180)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: LanguageCourse.CourseCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(ColorThemes.primaryBlue)
                
                Text(category.rawValue)
                    .font(Typography.caption1.weight(.medium))
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(Spacing.md)
            .frame(width: 100, height: 80)
            .glassStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Course Card
struct CourseCard: View {
    let course: LanguageCourse
    let viewModel: CourseViewModel
    let action: () -> Void
    
    var body: some View {
        InteractiveCard(action: action) {
            HStack(spacing: Spacing.md) {
                // Course icon
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .fill(viewModel.getDifficultyColor(for: course.difficulty).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: course.imageSystemName)
                        .font(.title2)
                        .foregroundColor(viewModel.getDifficultyColor(for: course.difficulty))
                }
                
                // Course info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(course.title)
                            .font(Typography.headline)
                            .foregroundColor(ColorThemes.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !course.isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                    }
                    
                    Text(course.description)
                        .font(Typography.body)
                        .foregroundColor(ColorThemes.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        // Category
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: course.category.icon)
                                .font(.caption)
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text(course.category.rawValue)
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                        
                        Spacer()
                        
                        // Duration
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(ColorThemes.textTertiary)
                            
                            Text(viewModel.formatDuration(course.estimatedDuration))
                                .font(Typography.caption2)
                                .foregroundColor(ColorThemes.textTertiary)
                        }
                        
                        // Difficulty
                        DifficultyBadge(course.difficulty, compact: true)
                    }
                    
                    // Progress bar
                    if course.progress > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Progress")
                                    .font(Typography.caption2)
                                    .foregroundColor(ColorThemes.textTertiary)
                                
                                Spacer()
                                
                                Text("\(Int(course.progress * 100))%")
                                    .font(Typography.caption2)
                                    .foregroundColor(ColorThemes.textTertiary)
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(ColorThemes.surfaceSecondary)
                                    .frame(height: 3)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(viewModel.getDifficultyColor(for: course.difficulty))
                                    .frame(width: max(0, 200 * course.progress), height: 3)
                                    .animation(AnimationPresets.easeInOut, value: course.progress)
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
        }
    }
}

// MARK: - Filters View
struct FiltersView: View {
    @ObservedObject var viewModel: CourseViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    // Category filter
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Category")
                            .font(Typography.headline)
                            .foregroundColor(ColorThemes.textPrimary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.sm) {
                            ForEach(LanguageCourse.CourseCategory.allCases, id: \.self) { category in
                                categoryFilterButton(category)
                            }
                        }
                    }
                    
                    // Difficulty filter
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Difficulty")
                            .font(Typography.headline)
                            .foregroundColor(ColorThemes.textPrimary)
                        
                        HStack(spacing: Spacing.sm) {
                            ForEach(LanguageCourse.DifficultyLevel.allCases, id: \.self) { difficulty in
                                difficultyFilterButton(difficulty)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: Spacing.md) {
                        Button("Clear All") {
                            viewModel.clearFilters()
                        }
                        .secondaryButton()
                        
                        GlowingButton("Apply Filters") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .padding(Spacing.lg)
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func categoryFilterButton(_ category: LanguageCourse.CourseCategory) -> some View {
        let isSelected = viewModel.selectedCategory == category
        
        return Button {
            viewModel.selectedCategory = isSelected ? nil : category
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.body)
                
                Text(category.rawValue)
                    .font(Typography.body)
                    .lineLimit(1)
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(isSelected ? ColorThemes.primaryBlue.opacity(0.2) : ColorThemes.surfacePrimary)
            .foregroundColor(isSelected ? ColorThemes.primaryBlue : ColorThemes.textSecondary)
            .cornerRadius(CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(isSelected ? ColorThemes.primaryBlue : ColorThemes.borderPrimary, lineWidth: 1)
            )
        }
    }
    
    private func difficultyFilterButton(_ difficulty: LanguageCourse.DifficultyLevel) -> some View {
        let isSelected = viewModel.selectedDifficulty == difficulty
        
        return Button {
            viewModel.selectedDifficulty = isSelected ? nil : difficulty
        } label: {
            Text(difficulty.rawValue)
                .font(Typography.body)
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(isSelected ? ColorThemes.primaryBlue.opacity(0.2) : ColorThemes.surfacePrimary)
                .foregroundColor(isSelected ? ColorThemes.primaryBlue : ColorThemes.textSecondary)
                .cornerRadius(CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.small)
                        .stroke(isSelected ? ColorThemes.primaryBlue : ColorThemes.borderPrimary, lineWidth: 1)
                )
        }
    }
}
