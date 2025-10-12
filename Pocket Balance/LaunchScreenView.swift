//
//  LaunchScreenView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var titleOffset: CGFloat = -100
    @State private var mascotScale: CGFloat = 0.5
    @State private var mascotOpacity: Double = 0
    @State private var taglineOffset: CGFloat = 50
    @State private var taglineOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App Name - Animated entrance from top
                VStack(spacing: 12) {
                    Text("Pocket")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .offset(y: titleOffset)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: titleOffset)
                    
                    Text("Balance")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .offset(y: titleOffset)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: titleOffset)
                }
                .padding(.top, 100)
                
                Spacer()
                
                // App Mascot - Animated scale and fade in
                FinancialMascotView(size: 200)
                    .scaleEffect(mascotScale)
                    .opacity(mascotOpacity)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: mascotScale)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: mascotOpacity)
                    .padding(.bottom, 60)
                
                // Tagline - Animated entrance from bottom
                Text("Manual budgeting made simple")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .offset(y: taglineOffset)
                    .opacity(taglineOpacity)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: taglineOffset)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: taglineOpacity)
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Trigger animations
            titleOffset = 0
            mascotScale = 1.0
            mascotOpacity = 1.0
            taglineOffset = 0
            taglineOpacity = 1.0
        }
    }
}

#Preview {
    LaunchScreenView()
}
