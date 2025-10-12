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
            
            // Mascot (Financial-themed design)
            ZStack {
                // Shadow
                Ellipse()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 180, height: 40)
                    .offset(y: 100)
                
                FinancialMascotView(size: 200)
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
