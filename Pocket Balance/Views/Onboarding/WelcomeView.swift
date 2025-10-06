//
//  WelcomeView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Headline
            Text("It's time to Learn it, Earn it, Stack it and Spend it!")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 32)
                .padding(.top, 60)
            
            Spacer()
            
            // Mascot
            ZStack {
                // Shadow
                Ellipse()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 180, height: 40)
                    .offset(y: 100)
                
                // Main circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 200, height: 200)
                    .overlay(
                        HStack(spacing: 20) {
                            // Left eye
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 15, height: 15)
                                    .offset(x: -5, y: -5)
                            }
                            
                            // Right eye
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 50, height: 50)
                                
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 15, height: 15)
                                    .offset(x: -5, y: -5)
                            }
                        }
                        .offset(y: -10)
                    )
                    .overlay(
                        // Smile
                        Path { path in
                            path.move(to: CGPoint(x: 70, y: 110))
                            path.addQuadCurve(
                                to: CGPoint(x: 130, y: 110),
                                control: CGPoint(x: 100, y: 125)
                            )
                        }
                        .stroke(Color.white, lineWidth: 3)
                    )
            }
            .padding(.bottom, 80)
            
            Spacer()
            
            // Button
            Button(action: {
                authState.moveToNextStep()
            }) {
                Text("Let's roll")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.2, green: 0.25, blue: 0.3))
                    .cornerRadius(28)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthenticationState())
}
