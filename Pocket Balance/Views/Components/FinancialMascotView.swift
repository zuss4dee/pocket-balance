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
        // Use the app logo instead of the black circle mascot
        Image("AppLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
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
