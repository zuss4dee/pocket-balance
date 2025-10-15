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
            
            // Centered app logo
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
                .scaleEffect(mascotScale)
                .opacity(mascotOpacity)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: mascotScale)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: mascotOpacity)
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
