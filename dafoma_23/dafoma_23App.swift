//
//  EduFortuneApp.swift
//  EduFortune
//
//  Created by Вячеслав on 8/20/25.
//

import SwiftUI

@main
struct EduFortuneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force dark mode for futuristic design
                .onAppear {
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance (iOS 15.6 compatible)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(ColorThemes.backgroundSecondary)
        
        // Normal state
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(ColorThemes.textTertiary)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(ColorThemes.textTertiary)
        ]
        
        // Selected state
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(ColorThemes.primaryBlue)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(ColorThemes.primaryBlue)
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(ColorThemes.backgroundPrimary)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(ColorThemes.textPrimary),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(ColorThemes.textPrimary),
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Configure other UI elements
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        // Configure progress view
        UIProgressView.appearance().progressTintColor = UIColor(ColorThemes.primaryBlue)
        UIProgressView.appearance().trackTintColor = UIColor(ColorThemes.surfaceSecondary)
    }
}
