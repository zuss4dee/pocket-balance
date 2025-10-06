//
//  ContentView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI
import Combine

// Shared AppData to pass between tabs
class AppData: ObservableObject {
    @Published var totalIncome: Double = 0.0
    @Published var expenses: [ExpenseItem] = []
    @Published var subscriptions: [SubscriptionItem] = []
    @Published var budgetCategories: [BudgetCategory] = []
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalSubscriptions: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        totalIncome - totalExpenses - totalSubscriptions
    }
    
    var totalBudgeted: Double {
        budgetCategories.reduce(0) { $0 + $1.amount }
    }
    
    var unbudgetedBalance: Double {
        remainingBalance - totalBudgeted
    }
}

struct ContentView: View {
    @StateObject private var appData = AppData()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeViewWrapper()
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            BudgetViewWrapper()
                .environmentObject(appData)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "chart.pie.fill" : "chart.pie")
                    Text("Budget")
                }
                .tag(1)
            
            CreditCardsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "creditcard.fill" : "creditcard")
                    Text("Cards")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// Wrapper views to connect shared data
struct HomeViewWrapper: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        HomeView(
            totalIncome: $appData.totalIncome,
            expenses: $appData.expenses,
            subscriptions: $appData.subscriptions
        )
    }
}

struct BudgetViewWrapper: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        BudgetingViewStandalone(
            budgetCategories: $appData.budgetCategories,
            remainingBalance: appData.remainingBalance,
            totalBudgeted: appData.totalBudgeted
        )
    }
}

// MARK: - Tab Views

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("D")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        Text("Dami")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                        
                        Text("dami@example.com")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Profile Options
                    VStack(spacing: 0) {
                        ProfileOptionRow(icon: "gear", title: "Settings", color: .gray)
                        Divider().padding(.leading, 56)
                        ProfileOptionRow(icon: "bell", title: "Notifications", color: .orange)
                        Divider().padding(.leading, 56)
                        ProfileOptionRow(icon: "lock", title: "Privacy", color: .blue)
                        Divider().padding(.leading, 56)
                        ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", color: .green)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal, 20)
                    
                    // Sign Out Button
                    Button(action: {
                        print("Sign out tapped")
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            print("\(title) tapped")
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Credit Card Models

enum CardBrand: String, Codable {
    case visa
    case mastercard
    case amex
    case discover
    case chase
    case capitalOne
    case generic
    
    var logo: String {
        switch self {
        case .visa: return "creditcard.fill"
        case .mastercard: return "circle.circle.fill"
        case .amex: return "rectangle.fill"
        case .discover: return "diamond.fill"
        case .chase: return "octagon.fill"
        case .capitalOne: return "capsule.fill"
        case .generic: return "creditcard.fill"
        }
    }
    
    var brandColor: Color {
        switch self {
        case .visa: return Color(red: 0.09, green: 0.19, blue: 0.51) // Visa Blue
        case .mastercard: return Color(red: 0.92, green: 0.31, blue: 0.13) // Mastercard Red
        case .amex: return Color(red: 0.0, green: 0.42, blue: 0.65) // Amex Blue
        case .discover: return Color(red: 0.97, green: 0.48, blue: 0.0) // Discover Orange
        case .chase: return Color(red: 0.0, green: 0.31, blue: 0.62) // Chase Blue
        case .capitalOne: return Color(red: 0.91, green: 0.16, blue: 0.22) // Capital One Red
        case .generic: return .blue
        }
    }
    
    var brandName: String {
        switch self {
        case .visa: return "Visa"
        case .mastercard: return "Mastercard"
        case .amex: return "American Express"
        case .discover: return "Discover"
        case .chase: return "Chase"
        case .capitalOne: return "Capital One"
        case .generic: return "Card"
        }
    }
}

struct CreditCard: Identifiable, Codable {
    let id: UUID
    var name: String
    var limit: Double
    var color: String // Store color as string for Codable
    var detectedBrand: CardBrand
    
    init(id: UUID = UUID(), name: String, limit: Double, color: String = "blue") {
        self.id = id
        self.name = name
        self.limit = limit
        self.color = color
        self.detectedBrand = CreditCard.detectBrand(from: name)
    }
    
    var cardColor: Color {
        // Use brand color if detected, otherwise use custom color
        if detectedBrand != .generic {
            return detectedBrand.brandColor
        }
        switch color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var displayLogo: String {
        return detectedBrand.logo
    }
    
    static func detectBrand(from name: String) -> CardBrand {
        let lowercasedName = name.lowercased()
        
        if lowercasedName.contains("visa") {
            return .visa
        } else if lowercasedName.contains("mastercard") || lowercasedName.contains("master card") {
            return .mastercard
        } else if lowercasedName.contains("amex") || lowercasedName.contains("american express") {
            return .amex
        } else if lowercasedName.contains("discover") {
            return .discover
        } else if lowercasedName.contains("chase") {
            return .chase
        } else if lowercasedName.contains("capital one") || lowercasedName.contains("capitalone") {
            return .capitalOne
        }
        
        return .generic
    }
    
    mutating func updateBrand() {
        self.detectedBrand = CreditCard.detectBrand(from: name)
    }
}

struct CreditCardsView: View {
    @State private var creditCards: [CreditCard] = []
    @State private var showAddCard = false
    @State private var editingCard: CreditCard?
    
    var totalCredit: Double {
        creditCards.reduce(0) { $0 + $1.limit }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if creditCards.isEmpty {
                    // Empty State
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Illustration
                        ZStack {
                            // Phone
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.82, green: 0.71, blue: 0.55), Color(red: 0.78, green: 0.67, blue: 0.51)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 260)
                                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                            
                            // Phone Screen
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.53, green: 0.68, blue: 0.68), Color(red: 0.48, green: 0.63, blue: 0.63)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 120, height: 200)
                                .offset(y: -10)
                            
                            // Home Button
                            Circle()
                                .fill(Color(red: 0.53, green: 0.68, blue: 0.68))
                                .frame(width: 16, height: 16)
                                .offset(y: 110)
                            
                            // Credit Card
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.84, green: 0.49, blue: 0.42), Color(red: 0.78, green: 0.45, blue: 0.38)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 160, height: 100)
                                .shadow(color: Color.black.opacity(0.2), radius: 15, x: 5, y: 5)
                                .offset(x: 60, y: 0)
                            
                            // Card Stripe
                            Rectangle()
                                .fill(Color(red: 0.82, green: 0.71, blue: 0.55))
                                .frame(width: 160, height: 24)
                                .offset(x: 60, y: -20)
                            
                            // Plus Icon
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .offset(x: 70, y: -80)
                        }
                        .padding(.bottom, 40)
                        
                        // Title
                        Text("Add card to your wallet")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Description
                        Text("Add your card to track your credit limits and manage your spending.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                        
                        Spacer()
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Total Credit Card
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Total Credit Available")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Spacer()
                                }
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("£")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                    
                                    Text(String(format: "%.2f", totalCredit))
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                
                                Text("Across \(creditCards.count) card\(creditCards.count == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Cards List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Cards")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 20)
                                
                                ForEach(creditCards) { card in
                                    CreditCardRow(
                                        card: card,
                                        onEdit: {
                                            editingCard = card
                                        },
                                        onDelete: {
                                            withAnimation {
                                                creditCards.removeAll { $0.id == card.id }
                                            }
                                        }
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Credit Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddCard = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddCard) {
                AddCreditCardSheet(creditCards: $creditCards)
            }
            .sheet(item: $editingCard) { card in
                EditCreditCardSheet(creditCards: $creditCards, card: card)
            }
        }
    }
}

struct CreditCardRow: View {
    let card: CreditCard
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Card Icon with Brand Logo
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [card.cardColor, card.cardColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                
                Image(systemName: card.displayLogo)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
            }
            
            // Card Info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name.isEmpty ? "Credit Card" : card.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(card.name.isEmpty ? .secondary : .primary)
                
                HStack(spacing: 4) {
                    if card.detectedBrand != .generic {
                        Text(card.detectedBrand.brandName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(card.cardColor)
                        Text("•")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    Text("Credit Limit")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Limit Amount
            Text(card.limit.formatAsCurrency())
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Menu
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Add Credit Card Sheet

struct AddCreditCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var creditCards: [CreditCard]
    @State private var cardName: String = ""
    @State private var limit: String = ""
    @State private var selectedColor: String = "blue"
    @State private var errorMessage: String = ""
    
    let availableColors = ["blue", "purple", "green", "orange", "red", "pink"]
    
    var detectedBrand: CardBrand {
        CreditCard.detectBrand(from: cardName)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Card Name
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Card Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Brand Detection Indicator
                        if detectedBrand != .generic {
                            HStack(spacing: 6) {
                                Image(systemName: detectedBrand.logo)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(detectedBrand.brandColor)
                                Text(detectedBrand.brandName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(detectedBrand.brandColor)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(detectedBrand.brandColor.opacity(0.15))
                            )
                        }
                    }
                    
                    TextField("e.g., Visa Platinum, Amex Gold", text: $cardName)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .padding(.horizontal, 20)
                
                // Credit Limit
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credit Limit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        
                        TextField("0.00", text: $limit)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.blue)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                }
                .padding(.horizontal, 20)
                
                // Color Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Color")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { colorName in
                            Circle()
                                .fill(colorFromString(colorName))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = colorName
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Error Message
                if !errorMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Add Button
                Button(action: {
                    validateAndAddCard()
                }) {
                    Text("Add Credit Card")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(cardName.isEmpty || limit.isEmpty ? Color.gray.opacity(0.5) : .blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(cardName.isEmpty || limit.isEmpty)
                .opacity(cardName.isEmpty || limit.isEmpty ? 0.5 : 1.0)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func validateAndAddCard() {
        errorMessage = ""
        
        // Check if card name is empty
        if cardName.isEmpty {
            errorMessage = "Please enter a card name"
            return
        }
        
        // Check if limit is empty
        if limit.isEmpty {
            errorMessage = "Please enter a credit limit"
            return
        }
        
        // Check if limit is a valid number
        guard let limitValue = Double(limit) else {
            errorMessage = "Please enter numbers only (e.g., 5000 or 5000.00)"
            return
        }
        
        // Check if limit is positive
        if limitValue <= 0 {
            errorMessage = "Credit limit must be greater than zero"
            return
        }
        
        // All validations passed
        let card = CreditCard(name: cardName, limit: limitValue, color: selectedColor)
        creditCards.append(card)
        dismiss()
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
}

// MARK: - Edit Credit Card Sheet

struct EditCreditCardSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var creditCards: [CreditCard]
    let card: CreditCard
    
    @State private var cardName: String = ""
    @State private var limit: String = ""
    @State private var selectedColor: String = "blue"
    
    let availableColors = ["blue", "purple", "green", "orange", "red", "pink"]
    
    var detectedBrand: CardBrand {
        CreditCard.detectBrand(from: cardName)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Card Name
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Card Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Brand Detection Indicator
                        if detectedBrand != .generic {
                            HStack(spacing: 6) {
                                Image(systemName: detectedBrand.logo)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(detectedBrand.brandColor)
                                Text(detectedBrand.brandName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(detectedBrand.brandColor)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(detectedBrand.brandColor.opacity(0.15))
                            )
                        }
                    }
                    
                    TextField("e.g., Visa Platinum, Amex Gold", text: $cardName)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .padding(.horizontal, 20)
                
                // Credit Limit
                VStack(alignment: .leading, spacing: 8) {
                    Text("Credit Limit")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)
                        
                        TextField("0.00", text: $limit)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.blue)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                }
                .padding(.horizontal, 20)
                
                // Color Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Color")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { colorName in
                            Circle()
                                .fill(colorFromString(colorName))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == colorName ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = colorName
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    saveChanges()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(cardName.isEmpty || limit.isEmpty)
                .opacity(cardName.isEmpty || limit.isEmpty ? 0.5 : 1.0)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                cardName = card.name
                limit = String(format: "%.2f", card.limit)
                selectedColor = card.color
            }
        }
    }
    
    private func saveChanges() {
        guard let limitValue = Double(limit),
              let index = creditCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        creditCards[index].name = cardName
        creditCards[index].limit = limitValue
        creditCards[index].color = selectedColor
        creditCards[index].updateBrand() // Update brand detection
        dismiss()
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
}

// MARK: - Budget View (Standalone for Tab)

struct BudgetingViewStandalone: View {
    @Binding var budgetCategories: [BudgetCategory]
    let remainingBalance: Double
    let totalBudgeted: Double
    @State private var showAddCategory = false
    @State private var editingCategory: BudgetCategory?
    
    var unbudgetedBalance: Double {
        remainingBalance - totalBudgeted
    }
    
    var budgetProgress: Double {
        guard remainingBalance > 0 else { return 0 }
        return min(totalBudgeted / remainingBalance, 1.0)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if budgetCategories.isEmpty && remainingBalance <= 0 {
                    // No balance to budget
                    VStack(spacing: 20) {
                        Image(systemName: "chart.pie")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No balance to budget")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Add income to start budgeting")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Budget Overview Card
                            VStack(spacing: 20) {
                                // Remaining Balance
                                VStack(spacing: 8) {
                                    Text("Available to Budget")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                    
                                    Text(remainingBalance.formatAsCurrency())
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                }
                                
                                // Progress Bar
                                VStack(spacing: 12) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            // Background
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(height: 12)
                                            
                                            // Progress
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: budgetProgress < 1.0 ? [.blue, .purple] : [.red, .orange],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * budgetProgress, height: 12)
                                        }
                                    }
                                    .frame(height: 12)
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Budgeted")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text(totalBudgeted.formatAsCurrency())
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Unbudgeted")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.secondary)
                                            Text(unbudgetedBalance.formatAsCurrency())
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(unbudgetedBalance >= 0 ? .green : .red)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            // Budget Categories
                            if !budgetCategories.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Budget Categories")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(budgetCategories) { category in
                                        BudgetCategoryRow(
                                            category: category,
                                            onEdit: {
                                                editingCategory = category
                                            },
                                            onDelete: {
                                                withAnimation {
                                                    budgetCategories.removeAll { $0.id == category.id }
                                                }
                                            }
                                        )
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.bottom, 40)
                            } else {
                                // Empty State
                                VStack(spacing: 16) {
                                    Image(systemName: "folder")
                                        .font(.system(size: 50))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No budget categories yet")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Text("Tap + to create your first budget category")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.vertical, 40)
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Budget Manager")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddCategory = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                    .disabled(remainingBalance <= 0)
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddBudgetCategorySheet(budgetCategories: $budgetCategories, availableBalance: unbudgetedBalance)
            }
            .sheet(item: $editingCategory) { category in
                EditBudgetCategorySheet(budgetCategories: $budgetCategories, category: category, availableBalance: unbudgetedBalance + category.amount)
            }
        }
    }
}

#Preview {
    ContentView()
}
