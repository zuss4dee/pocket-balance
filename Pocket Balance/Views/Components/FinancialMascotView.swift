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
            // Main orange circle (mascot)
            Circle()
                .fill(Color.orange)
                .frame(width: size, height: size)
                .overlay(
                    // Eyes
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
            
            // Financial icons around the mascot
            // Top Left - Security Shield
            VStack {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: size * 0.15))
                        .foregroundColor(.green)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.25, height: size * 0.25)
                        )
                    Spacer()
                }
                Spacer()
            }
            .offset(x: -size * 0.4, y: -size * 0.3)
            
            // Top Right - Safe
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: size * 0.15))
                        .foregroundColor(.gray)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.25, height: size * 0.25)
                        )
                }
                Spacer()
            }
            .offset(x: size * 0.4, y: -size * 0.3)
            
            // Bottom Left - Piggy Bank
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.green)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.2, height: size * 0.2)
                        )
                    Spacer()
                }
            }
            .offset(x: -size * 0.4, y: size * 0.3)
            
            // Bottom Right - Growth Arrow
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: size * 0.15))
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.25, height: size * 0.25)
                        )
                }
            }
            .offset(x: size * 0.4, y: size * 0.3)
            
            // Middle Left - Money
            VStack {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.green)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.2, height: size * 0.2)
                        )
                    Spacer()
                }
                Spacer()
            }
            .offset(x: -size * 0.35, y: 0)
            
            // Middle Right - Calendar
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.2, height: size * 0.2)
                        )
                }
                Spacer()
            }
            .offset(x: size * 0.35, y: 0)
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
