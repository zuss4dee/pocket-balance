//
//  LaunchScreenView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App Name
                VStack(spacing: 12) {
                    Text("Pocket")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    Text("Balance")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .padding(.top, 100)
                
                Spacer()
                
                // App Mascot - Black Circle with Eyes
                FinancialMascotView(size: 200)
                .padding(.bottom, 60)
                
                // Tagline
                Text("Manual budgeting made simple")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
