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
            // Shadow
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
                .offset(x: size * 0.05, y: size * 0.05)
            
            // Main orange circle (mascot)
            Circle()
                .fill(Color.orange)
                .frame(width: size, height: size)
                .overlay(
                    VStack(spacing: size * 0.1) {
                        // Eyes - simple curved lines
                        HStack(spacing: size * 0.2) {
                            // Left eye
                            Path { path in
                                path.move(to: CGPoint(x: -size * 0.05, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: size * 0.05, y: 0),
                                    control: CGPoint(x: 0, y: -size * 0.02)
                                )
                            }
                            .stroke(Color.black, lineWidth: size * 0.02)
                            
                            // Right eye
                            Path { path in
                                path.move(to: CGPoint(x: -size * 0.05, y: 0))
                                path.addQuadCurve(
                                    to: CGPoint(x: size * 0.05, y: 0),
                                    control: CGPoint(x: 0, y: -size * 0.02)
                                )
                            }
                            .stroke(Color.black, lineWidth: size * 0.02)
                        }
                        .offset(y: -size * 0.15)
                        
                        // Smile - simple curved line
                        Path { path in
                            path.move(to: CGPoint(x: -size * 0.15, y: 0))
                            path.addQuadCurve(
                                to: CGPoint(x: size * 0.15, y: 0),
                                control: CGPoint(x: 0, y: size * 0.05)
                            )
                        }
                        .stroke(Color.black, lineWidth: size * 0.03)
                        .offset(y: size * 0.1)
                    }
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
