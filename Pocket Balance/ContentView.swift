//
//  ContentView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI
import Combine
import Supabase

// Shared AppData to pass between tabs
class AppData: ObservableObject {
    @Published var incomes: [IncomeItem] = []
    @Published var expenses: [ExpenseItem] = []
    @Published var subscriptions: [SubscriptionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefreshDate: Date?
    
    private let supabaseService = SupabaseService.shared
    
    var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalSubscriptions: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        totalIncome - totalExpenses - totalSubscriptions
    }
    
    
    // MARK: - Load Data from Supabase
    
    @MainActor
    func loadAllData() async {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Starting data load from Supabase...")
        
        do {
            // Use fetchAllIncome for complete data loading
            async let fetchedIncomes = supabaseService.fetchAllIncome()
            async let fetchedExpenses = supabaseService.fetchExpenses()
            async let fetchedSubscriptions = supabaseService.fetchSubscriptions()
            let (incomes, expenses, subscriptions) = try await (fetchedIncomes, fetchedExpenses, fetchedSubscriptions)
            
            self.incomes = incomes
            self.expenses = expenses
            self.subscriptions = subscriptions
            self.lastRefreshDate = Date()
            
            print("✅ Data loaded from Supabase successfully:")
            print("   📊 Incomes: \(incomes.count) items")
            print("   💸 Expenses: \(expenses.count) items")
            print("   🔄 Subscriptions: \(subscriptions.count) items")
        } catch {
            let errorMsg = "Failed to load data: \(error.localizedDescription)"
            print("❌ \(errorMsg)")
            self.errorMessage = errorMsg
        }
        
        isLoading = false
    }
    
    @MainActor
    func refreshData() async {
        await loadAllData()
    }
    
    @MainActor
    func clearError() {
        errorMessage = nil
    }
    
    @MainActor
    func clearAllData() {
        incomes = []
        expenses = []
        subscriptions = []
        lastRefreshDate = nil
        errorMessage = nil
        print("🧹 Cleared all user data")
    }
}

struct ContentView: View {
    @StateObject private var appData = AppData()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Lazy load views only when needed
            if selectedTab == 0 {
                HomeViewWrapper()
                    .environmentObject(appData)
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                    .tag(0)
            } else {
                // Placeholder for performance
                Color.clear
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
            }
            
            if selectedTab == 1 {
                CreditCardsView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "creditcard.fill" : "creditcard")
                        Text("Cards")
                    }
                    .tag(1)
            } else {
                Color.clear
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Cards")
                    }
                    .tag(1)
            }
            
            if selectedTab == 2 {
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                        Text("Profile")
                    }
                    .tag(2)
            } else {
                Color.clear
                    .tabItem {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                    .tag(2)
            }
        }
        .accentColor(.blue)
        .onAppear {
            Task {
                print("🔄 ContentView appeared - loading data...")
                await appData.loadAllData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Only refresh data if user is on the home tab (performance optimization)
            if selectedTab == 0 {
                Task {
                    print("🔄 App became active - refreshing data...")
                    await appData.refreshData()
                }
            }
        }
    }
}

// Wrapper views to connect shared data
struct HomeViewWrapper: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        HomeView(
            incomes: $appData.incomes,
            expenses: $appData.expenses,
            subscriptions: $appData.subscriptions
        )
    }
}


// MARK: - Tab Views

struct ProfileView: View {
    @State private var showingSignOutAlert = false
    @State private var isSigningOut = false
    @State private var userFullName: String = ""
    @State private var userPhone: String = ""
    @State private var userEmail: String = ""
    @State private var isLoadingProfile = true
    
    private var userInitial: String {
        if let firstChar = userFullName.first {
            return String(firstChar).uppercased()
        }
        return "U"
    }
    
    private var displayContact: String {
        // Show email if available, otherwise show phone
        if !userEmail.isEmpty {
            return userEmail
        } else if !userPhone.isEmpty {
            return userPhone
        }
        return ""
    }
    
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
                                Group {
                                    if isLoadingProfile {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(userInitial)
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        if isLoadingProfile {
                            ProgressView()
                                .padding(.top, 8)
                        } else {
                            Text(userFullName.isEmpty ? "User" : userFullName)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            
                            if !displayContact.isEmpty {
                                Text(displayContact)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Profile Options
                    VStack(spacing: 0) {
                        NavigationLink(destination: ProfileSettingsView(isPresentedAsSheet: false, onDismiss: nil)) {
                            ProfileOptionRow(icon: "gear", title: "Settings", color: .gray)
                        }
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
                        showingSignOutAlert = true
                    }) {
                        HStack {
                            if isSigningOut {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .padding(.trailing, 8)
                            }
                            Text(isSigningOut ? "Signing Out..." : "Sign Out")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                    }
                    .disabled(isSigningOut)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .task {
                await loadUserProfile()
            }
        }
    }
    
    @MainActor
    private func loadUserProfile() async {
        isLoadingProfile = true
        
        do {
            // Get current user from Supabase
            let user = try await SupabaseService.shared.client.auth.session.user
            
            // Get phone number (if available)
            if let phone = user.phone {
                userPhone = phone
            }
            
            // Get email (if available)
            if let email = user.email {
                userEmail = email
            }
            
            // Get full name from user metadata
            // userMetadata is [String: AnyJSON]
            if let fullNameJSON = user.userMetadata["full_name"] {
                // Try to extract string from AnyJSON
                switch fullNameJSON {
                case .string(let fullName):
                    userFullName = fullName
                default:
                    // Try encoding/decoding approach
                    do {
                        let data = try JSONEncoder().encode(fullNameJSON)
                        let fullName = try JSONDecoder().decode(String.self, from: data)
                        userFullName = fullName
                    } catch {
                        print("⚠️ Could not decode full_name from metadata")
                    }
                }
            }
            
            print("✅ Loaded user profile:")
            print("   👤 Name: \(userFullName)")
            print("   📧 Email: \(userEmail)")
            print("   📱 Phone: \(userPhone)")
            print("   🔍 Metadata: \(user.userMetadata)")
            
        } catch {
            print("❌ Error loading user profile: \(error.localizedDescription)")
            // Set defaults if error
            userFullName = "User"
        }
        
        isLoadingProfile = false
    }
    
    private func signOut() {
        isSigningOut = true
        
        Task {
            do {
                try await SupabaseService.shared.client.auth.signOut()
                print("✅ Successfully signed out")
                // The auth listener in AppRootView will automatically handle the navigation
            } catch {
                print("❌ Error signing out: \(error.localizedDescription)")
                await MainActor.run {
                    isSigningOut = false
                }
            }
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
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
                    // Ultra-Modern Empty State
                    ZStack {
                        // Minimal background
                        Color.clear
                        
                        VStack(spacing: 40) {
                            Spacer()
                        
                        // Minimal Illustration
                        ZStack {
                            // Simple Credit Card
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 90)
                                .shadow(
                                    color: .blue.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                            // Minimal Card Stripe
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 140, height: 20)
                                .offset(y: -15)
                            
                            // Simple Plus Icon
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 50, height: 50)
                                    .shadow(
                                        color: .black.opacity(0.1),
                                        radius: 4,
                                        x: 0,
                                        y: 2
                                    )
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .offset(x: 60, y: -40)
                        }
                        .padding(.bottom, 50)
                        
                        // Enhanced Title with better typography
                        VStack(spacing: 24) {
                            Text("Add your credit card")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .shadow(color: .primary.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Text("Track your credit limits and manage your spending with ease")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, 32)
                            
                        }
                        
                            Spacer()
                            Spacer()
                        }
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Modern Total Credit Card
                            VStack(spacing: 24) {
                                VStack(spacing: 12) {
                                    Text("TOTAL CREDIT AVAILABLE")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                        .tracking(1.5)
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text("£")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                        
                                        Text(String(format: "%.2f", totalCredit))
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                            .shadow(color: .blue.opacity(0.2), radius: 4, x: 0, y: 2)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack {
                                        Text("Across \(creditCards.count) card\(creditCards.count == 1 ? "" : "s")")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        // Credit utilization indicator
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(.green)
                                                .frame(width: 8, height: 8)
                                            
                                            Text("Available")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding(28)
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(.background)
                                    
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.03)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.08)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: .blue.opacity(0.1),
                                radius: 20,
                                x: 0,
                                y: 8
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            
                            // Modern Cards List
                            VStack(alignment: .leading, spacing: 20) {
                                HStack {
                                    Text("Your Cards")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 16) {
                                    ForEach(creditCards) { card in
                                        ModernCreditCardRow(
                                            card: card,
                                            onEdit: {
                                                editingCard = card
                                            },
                                            onDelete: {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    creditCards.removeAll { $0.id == card.id }
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(UIColor.systemGroupedBackground),
                        Color(UIColor.systemGroupedBackground).opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Credit Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddCard = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .shadow(
                                    color: .blue.opacity(0.2),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.blue)
                        }
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
        HStack(spacing: 12) {
            // Card Icon with Brand Logo (smaller)
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [card.cardColor, card.cardColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: card.displayLogo)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
            }
            
            // Card Info (more compact)
            VStack(alignment: .leading, spacing: 2) {
                Text(card.name.isEmpty ? "Credit Card" : card.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(card.name.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 3) {
                    if card.detectedBrand != .generic {
                        Text(card.detectedBrand.brandName)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(card.cardColor)
                        Text("•")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    Text("Limit")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Limit Amount (smaller font)
            VStack(alignment: .trailing, spacing: 2) {
                Text(card.limit.formatAsCurrency())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Available")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            // Menu (smaller)
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Modern Credit Card Row

struct ModernCreditCardRow: View {
    let card: CreditCard
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Enhanced Card Icon with Brand Logo
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [card.cardColor, card.cardColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: card.cardColor.opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: card.displayLogo)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Enhanced Card Info
            VStack(alignment: .leading, spacing: 8) {
                Text(card.name.isEmpty ? "Credit Card" : card.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(card.name.isEmpty ? .secondary : .primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if card.detectedBrand != .generic {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(card.cardColor)
                                .frame(width: 6, height: 6)
                            
                            Text(card.detectedBrand.brandName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(card.cardColor)
                        }
                    }
                    
                    Text("Credit Limit")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Enhanced Amount Display
            VStack(alignment: .trailing, spacing: 6) {
                Text(card.limit.formatAsCurrency())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .shadow(color: .primary.opacity(0.1), radius: 1, x: 0, y: 1)
                
                Text("Available")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.green)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            // Modern Menu Button
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                card.cardColor.opacity(0.05),
                                card.cardColor.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            card.cardColor.opacity(0.15),
                            card.cardColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: card.cardColor.opacity(0.08),
            radius: 12,
            x: 0,
            y: 6
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


#Preview {
    ContentView()
}
