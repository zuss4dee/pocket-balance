//
//  DashboardCardView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct DashboardCardView: View {
    let title: String
    let metric: String
    let context: String
    let iconSystemName: String
    let iconColor: Color
    let isLargeMetric: Bool
    
    init(
        title: String,
        metric: String,
        context: String,
        iconSystemName: String,
        iconColor: Color = .blue,
        isLargeMetric: Bool = false
    ) {
        self.title = title
        self.metric = metric
        self.context = context
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.isLargeMetric = isLargeMetric
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side: Text content
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(metric)
                    .font(.system(size: isLargeMetric ? 32 : 26, weight: .bold, design: .rounded))
                    .foregroundColor(iconColor)
                
                Text(context)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            // Right side: Simple icon
            Image(systemName: iconSystemName)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(iconColor)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        DashboardCardView(
            title: "Total Income",
            metric: "£2,500.00",
            context: "from 2 sources",
            iconSystemName: "arrow.up.circle.fill",
            iconColor: .green
        )
        
        DashboardCardView(
            title: "Remaining Balance",
            metric: "£1,269.50",
            context: "left to spend",
            iconSystemName: "bitcoinsign.circle.fill",
            iconColor: .blue,
            isLargeMetric: true
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}
