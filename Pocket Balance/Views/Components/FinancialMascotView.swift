//
//  FinancialMascotView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI

struct FinancialMascotView: View {
    let size: CGFloat
    
    init(size: CGFloat = 120) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Main black circle (mascot) - restored original design
            Circle()
                .fill(Color.black)
                .frame(width: size, height: size)
                .overlay(
                    // Eyes - original white circles with black pupils
                    HStack(spacing: size * 0.15) {
                        // Left eye
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.25, height: size * 0.25)
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size * 0.08, height: size * 0.08)
                                .offset(x: -size * 0.03, y: -size * 0.03)
                        }
                        
                        // Right eye
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.25, height: size * 0.25)
                            
                            Circle()
                                .fill(Color.black)
                                .frame(width: size * 0.08, height: size * 0.08)
                                .offset(x: -size * 0.03, y: -size * 0.03)
                        }
                    }
                    .offset(y: -size * 0.05)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FinancialMascotView(size: 120)
        FinancialMascotView(size: 180)
        FinancialMascotView(size: 200)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
