//
//  GestureGuideView.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

struct GestureGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPage = 0
    @State private var showDemo = false
    @State private var demoOffset = CGSize.zero
    @State private var demoScale: CGFloat = 1.0
    @State private var demoRotation: Double = 0
    
    let gestures = GestureInfo.allGestures
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Gesture pages
                    TabView(selection: $currentPage) {
                        ForEach(Array(gestures.enumerated()), id: \.offset) { index, gesture in
                            GesturePageView(gesture: gesture, isActive: currentPage == index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Page indicator
                    pageIndicator
                    
                    // Navigation buttons
                    navigationButtons
                }
            }
            .navigationBarItems(
                leading: Button("Skip") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Text("Gesture Guide")
                .font(Typography.largeTitle)
                .foregroundColor(ColorThemes.textPrimary)
            
            Text("Master intuitive gestures for seamless learning")
                .font(Typography.body)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.lg)
        .padding(.horizontal, Spacing.lg)
    }
    
    // MARK: - Page Indicator
    private var pageIndicator: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<gestures.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? ColorThemes.primaryBlue : ColorThemes.surfaceSecondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(AnimationPresets.spring, value: currentPage)
            }
        }
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: Spacing.md) {
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation(AnimationPresets.spring) {
                        currentPage -= 1
                    }
                }
                .secondaryButton()
            }
            
            Spacer()
            
            if currentPage < gestures.count - 1 {
                GlowingButton("Next", icon: "arrow.right") {
                    withAnimation(AnimationPresets.spring) {
                        currentPage += 1
                    }
                }
            } else {
                GlowingButton("Get Started", icon: "checkmark.circle.fill") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Gesture Page View
struct GesturePageView: View {
    let gesture: GestureInfo
    let isActive: Bool
    
    @State private var animationPhase = 0
    @State private var demoOffset = CGSize.zero
    @State private var demoScale: CGFloat = 1.0
    @State private var demoRotation: Double = 0
    @State private var showHands = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Demo area
            demoArea
            
            // Gesture info
            gestureInfo
            
            // Tips
            tipsSection
        }
        .padding(.horizontal, Spacing.lg)
        .onAppear {
            if isActive {
                startAnimation()
            }
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
    }
    
    // MARK: - Demo Area
    private var demoArea: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: CornerRadius.large)
                .fill(ColorThemes.surfacePrimary)
                .frame(height: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.large)
                        .stroke(ColorThemes.borderPrimary, lineWidth: 2)
                )
            
            // Demo content
            VStack(spacing: Spacing.md) {
                // Gesture icon
                ZStack {
                    Circle()
                        .fill(ColorThemes.primaryGradient)
                        .frame(width: 80, height: 80)
                        .scaleEffect(demoScale)
                        .offset(demoOffset)
                        .rotationEffect(.degrees(demoRotation))
                    
                    Image(systemName: gesture.icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(ColorThemes.textPrimary)
                        .scaleEffect(demoScale)
                        .offset(demoOffset)
                        .rotationEffect(.degrees(demoRotation))
                }
                
                // Hand indicators
                if showHands {
                    handIndicators
                }
                
                // Action text
                Text(gesture.actionText)
                    .font(Typography.body.weight(.medium))
                    .foregroundColor(ColorThemes.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(showHands ? 1.0 : 0.7)
            }
        }
    }
    
    private var handIndicators: some View {
        HStack(spacing: Spacing.lg) {
            ForEach(0..<gesture.fingerCount, id: \.self) { _ in
                Image(systemName: "hand.point.up.left.fill")
                    .font(.title2)
                    .foregroundColor(ColorThemes.primaryBlue.opacity(0.7))
                    .rotationEffect(.degrees(Double.random(in: -15...15)))
            }
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Gesture Info
    private var gestureInfo: some View {
        VStack(spacing: Spacing.md) {
            Text(gesture.title)
                .font(Typography.title1)
                .foregroundColor(ColorThemes.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(gesture.description)
                .font(Typography.body)
                .foregroundColor(ColorThemes.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(ColorThemes.financialGold)
                
                Text("Pro Tips")
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                ForEach(gesture.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Text("•")
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.primaryBlue)
                        
                        Text(tip)
                            .font(Typography.body)
                            .foregroundColor(ColorThemes.textSecondary)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .glassStyle()
    }
    
    // MARK: - Animation Methods
    private func startAnimation() {
        switch gesture.type {
        case .tap:
            animateTap()
        case .swipe:
            animateSwipe()
        case .pinch:
            animatePinch()
        case .longPress:
            animateLongPress()
        case .drag:
            animateDrag()
        case .rotation:
            animateRotation()
        }
        
        withAnimation(AnimationPresets.spring.delay(0.5)) {
            showHands = true
        }
    }
    
    private func stopAnimation() {
        demoOffset = .zero
        demoScale = 1.0
        demoRotation = 0
        showHands = false
        animationPhase = 0
    }
    
    private func animateTap() {
        let animation = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        withAnimation(animation) {
            demoScale = 1.2
        }
    }
    
    private func animateSwipe() {
        let animation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        withAnimation(animation) {
            demoOffset = gesture.direction == .horizontal ? CGSize(width: 50, height: 0) : CGSize(width: 0, height: 50)
        }
    }
    
    private func animatePinch() {
        let animation = Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)
        withAnimation(animation) {
            demoScale = 0.7
        }
    }
    
    private func animateLongPress() {
        let scaleAnimation = Animation.easeInOut(duration: 0.3).delay(0.5).repeatForever(autoreverses: false)
        let pulseAnimation = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        
        withAnimation(scaleAnimation) {
            demoScale = 1.1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(pulseAnimation) {
                demoScale = 1.3
            }
        }
    }
    
    private func animateDrag() {
        let animation = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        withAnimation(animation) {
            demoOffset = CGSize(width: 30, height: -40)
        }
    }
    
    private func animateRotation() {
        let animation = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)
        withAnimation(animation) {
            demoRotation = 360
        }
    }
}

// MARK: - Gesture Info Model
struct GestureInfo {
    let type: GestureType
    let title: String
    let description: String
    let icon: String
    let actionText: String
    let fingerCount: Int
    let direction: Direction
    let tips: [String]
    
    enum GestureType {
        case tap, swipe, pinch, longPress, drag, rotation
    }
    
    enum Direction {
        case horizontal, vertical, any
    }
    
    static let allGestures: [GestureInfo] = [
        GestureInfo(
            type: .tap,
            title: "Tap to Select",
            description: "Quick tap to select courses, lessons, or answer questions. The most basic and essential gesture.",
            icon: "hand.tap.fill",
            actionText: "Tap anywhere to select",
            fingerCount: 1,
            direction: .any,
            tips: [
                "Use quick, light taps for best responsiveness",
                "Tap directly on buttons and cards",
                "Double-tap to open course details quickly"
            ]
        ),
        
        GestureInfo(
            type: .swipe,
            title: "Swipe to Navigate",
            description: "Swipe left or right to navigate between lessons, or swipe up/down to scroll through content.",
            icon: "hand.draw.fill",
            actionText: "Swipe to move between pages",
            fingerCount: 1,
            direction: .horizontal,
            tips: [
                "Swipe right to go to next lesson",
                "Swipe left to go back to previous lesson",
                "Swipe up/down to scroll through long content"
            ]
        ),
        
        GestureInfo(
            type: .pinch,
            title: "Pinch to Zoom",
            description: "Use two fingers to pinch in or out to zoom content, especially useful for reading vocabulary cards.",
            icon: "arrow.up.and.down.and.arrow.left.and.right",
            actionText: "Pinch with two fingers",
            fingerCount: 2,
            direction: .any,
            tips: [
                "Pinch out to zoom in on text and images",
                "Pinch in to zoom out and see more content",
                "Great for reading financial charts and graphs"
            ]
        ),
        
        GestureInfo(
            type: .longPress,
            title: "Long Press for Options",
            description: "Press and hold on courses or lessons to reveal additional options like bookmarking or sharing.",
            icon: "hand.point.up.left.fill",
            actionText: "Press and hold for options",
            fingerCount: 1,
            direction: .any,
            tips: [
                "Hold for 1-2 seconds to activate",
                "Look for haptic feedback confirmation",
                "Access quick actions without opening menus"
            ]
        ),
        
        GestureInfo(
            type: .drag,
            title: "Drag to Reorder",
            description: "Drag and drop to reorder your learning goals, favorite courses, or customize your dashboard.",
            icon: "arrow.up.and.down.and.arrow.left.and.right",
            actionText: "Drag to move items",
            fingerCount: 1,
            direction: .any,
            tips: [
                "Press and hold, then drag to move items",
                "Organize your learning path your way",
                "Drag courses to create custom study sequences"
            ]
        ),
        
        GestureInfo(
            type: .rotation,
            title: "Rotate for Details",
            description: "Rotate your device to landscape mode for enhanced reading experience and detailed progress charts.",
            icon: "rotate.right.fill",
            actionText: "Rotate device for landscape view",
            fingerCount: 0,
            direction: .any,
            tips: [
                "Rotate to landscape for better chart viewing",
                "Enhanced reading experience for lessons",
                "Automatic adaptation to your preferred orientation"
            ]
        )
    ]
}

// MARK: - Interactive Gesture Demo
struct InteractiveGestureDemo: View {
    @State private var selectedGesture: GestureInfo?
    @State private var showingGestureDetail = false
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Try These Gestures")
                .font(Typography.title2)
                .foregroundColor(ColorThemes.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Spacing.md) {
                ForEach(Array(GestureInfo.allGestures.enumerated()), id: \.offset) { index, gesture in
                    GestureDemoCard(gesture: gesture) {
                        selectedGesture = gesture
                        showingGestureDetail = true
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .sheet(isPresented: $showingGestureDetail) {
            if let gesture = selectedGesture {
                GestureDetailView(gesture: gesture)
            }
        }
    }
}

// MARK: - Gesture Demo Card
struct GestureDemoCard: View {
    let gesture: GestureInfo
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var offset = CGSize.zero
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                Image(systemName: gesture.icon)
                    .font(.title)
                    .foregroundColor(ColorThemes.primaryBlue)
                
                Text(gesture.title)
                    .font(Typography.headline)
                    .foregroundColor(ColorThemes.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text("Tap to learn")
                    .font(Typography.caption1)
                    .foregroundColor(ColorThemes.textSecondary)
            }
            .padding(Spacing.md)
            .frame(height: 120)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(offset)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(AnimationPresets.spring) {
                isPressed = pressing
            }
        }, perform: {})
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    withAnimation(AnimationPresets.easeOut) {
                        offset = CGSize(width: gesture.translation.width * 0.1, height: gesture.translation.height * 0.1)
                    }
                }
                .onEnded { _ in
                    withAnimation(AnimationPresets.spring) {
                        offset = .zero
                    }
                }
        )
    }
}

// MARK: - Gesture Detail View
struct GestureDetailView: View {
    let gesture: GestureInfo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorThemes.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(ColorThemes.primaryGradient)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: gesture.icon)
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(ColorThemes.textPrimary)
                            }
                            
                            Text(gesture.title)
                                .font(Typography.title1)
                                .foregroundColor(ColorThemes.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, Spacing.lg)
                        
                        // Description
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("How it Works")
                                .font(Typography.headline)
                                .foregroundColor(ColorThemes.textPrimary)
                            
                            Text(gesture.description)
                                .font(Typography.body)
                                .foregroundColor(ColorThemes.textSecondary)
                        }
                        .padding(Spacing.md)
                        .cardStyle()
                        
                        // Tips
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("Pro Tips")
                                .font(Typography.headline)
                                .foregroundColor(ColorThemes.textPrimary)
                            
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                ForEach(gesture.tips, id: \.self) { tip in
                                    HStack(alignment: .top, spacing: Spacing.sm) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.body)
                                            .foregroundColor(ColorThemes.success)
                                        
                                        Text(tip)
                                            .font(Typography.body)
                                            .foregroundColor(ColorThemes.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .cardStyle()
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationTitle("Gesture Guide")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
