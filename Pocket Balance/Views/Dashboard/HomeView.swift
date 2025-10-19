//
//  HomeView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI
import Supabase

// MARK: - Currency Formatter Extension

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        
        if let formatted = formatter.string(from: NSNumber(value: self)) {
            return "£\(formatted)"
        }
        return "£\(String(format: "%.2f", self))"
    }
    
    func formatAsShortCurrency() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""
        
        if absValue >= 1_000_000 {
            let millions = absValue / 1_000_000
            return String(format: "%@£%.1fM", sign, millions)
        } else if absValue >= 1_000 {
            let thousands = absValue / 1_000
            return String(format: "%@£%.1fK", sign, thousands)
        } else {
            return String(format: "%@£%.0f", sign, absValue)
        }
    }
}

// MARK: - Data Models

struct IncomeItem: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var source: String
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, source: String, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.source = source
        self.date = date
    }
}

struct ExpenseItem: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var description: String
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, description: String, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
    }
}

struct SubscriptionItem: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var name: String
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, name: String, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.name = name
        self.date = date
    }
}


struct HomeView: View {
    @Binding var incomes: [IncomeItem]
    @Binding var expenses: [ExpenseItem]
    @Binding var subscriptions: [SubscriptionItem]
    
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var showAddSubscription = false
    @State private var showIncomesList = false
    @State private var showExpensesList = false
    @State private var showSubscriptionsList = false
    @State private var userFullName: String = "User"
    @State private var isLoadingUserName = true
    @State private var isRefreshing = false
    @State private var isDataLoading = true
    
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
    
    // MARK: - View Components
    
    private var greetingHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting())
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
                
                if isLoadingUserName {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text(userFullName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            
            Spacer()
            
            // Refresh indicator
            if isRefreshing {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("Your Balance")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(1)
            
            Text(remainingBalance.formatAsShortCurrency())
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(remainingBalance >= 0 ? .green : .red)
            
            Text(remainingBalance >= 0 ? "Available to spend" : "Over budget")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(remainingBalance >= 0 ? .green.opacity(0.8) : .red.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var balanceCardWithBackground: some View {
        balanceCard
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(remainingBalance >= 0 ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(remainingBalance >= 0 ? Color.green.opacity(0.2) : Color.red.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 20)
    }
    
    private var sectionDivider: some View {
        VStack(spacing: 6) {
            Divider()
                .padding(.horizontal, 20)
            
            Text("BREAKDOWN")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(1)
        }
        .padding(.vertical, 8)
    }
    
    private var dashboardCards: some View {
        VStack(spacing: 12) {
            // Income Card
            Button(action: {
                if incomes.isEmpty {
                    showAddIncome = true
                } else {
                    showIncomesList = true
                }
            }) {
                DashboardCardView(
                    title: "Total Income",
                    metric: totalIncome.formatAsShortCurrency(),
                    context: incomes.isEmpty ? "Tap to add income" : "\(incomes.count) income source\(incomes.count == 1 ? "" : "s") • Tap to view",
                    iconSystemName: "arrow.up.circle",
                    iconColor: .green
                )
            }
            .buttonStyle(.plain)
            
            // Primary Monthly Expenses Card
            Button(action: {
                if expenses.isEmpty {
                    showAddExpense = true
                } else {
                    showExpensesList = true
                }
            }) {
                DashboardCardView(
                    title: "Primary Monthly Expenses",
                    metric: totalExpenses.formatAsShortCurrency(),
                    context: expenses.isEmpty ? "Tap to add expenses" : "\(expenses.count) expense\(expenses.count == 1 ? "" : "s") • Tap to view",
                    iconSystemName: "arrow.down.circle",
                    iconColor: .red
                )
            }
            .buttonStyle(.plain)
            
            // Recurring Payments Card
            Button(action: {
                if subscriptions.isEmpty {
                    showAddSubscription = true
                } else {
                    showSubscriptionsList = true
                }
            }) {
                DashboardCardView(
                    title: "Recurring Payments",
                    metric: totalSubscriptions.formatAsShortCurrency(),
                    context: subscriptions.isEmpty ? "Tap to add subscriptions" : "\(subscriptions.count) subscription\(subscriptions.count == 1 ? "" : "s") • Tap to view",
                    iconSystemName: "repeat.circle",
                    iconColor: .purple
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    greetingHeader
                    balanceCardWithBackground
                    sectionDivider
                    dashboardCards
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Pocket Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // No toolbar items needed
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(incomes: $incomes)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(expenses: $expenses)
            }
            .sheet(isPresented: $showAddSubscription) {
                AddSubscriptionSheet(subscriptions: $subscriptions)
            }
            .sheet(isPresented: $showIncomesList) {
                IncomesListView(incomes: $incomes)
            }
            .sheet(isPresented: $showExpensesList) {
                ExpensesListView(expenses: $expenses)
            }
            .sheet(isPresented: $showSubscriptionsList) {
                SubscriptionsListView(subscriptions: $subscriptions)
            }
            .refreshable {
                await refreshData()
            }
            .task {
                await loadUserName()
                // Set data loading to false immediately after loading
                isDataLoading = false
            }
            .overlay(
                // Loading overlay
                Group {
                    if isDataLoading {
                        ZStack {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.white)
                                
                                Text("Loading your data...")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                }
            )
        }
    }
    
    // MARK: - Helper Functions
    
    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good morning,"
        case 12..<17:
            return "Good afternoon,"
        case 17..<22:
            return "Good evening,"
        default:
            return "Good night,"
        }
    }
    
    @MainActor
    private func refreshData() async {
        isRefreshing = true
        await loadUserName()
        isRefreshing = false
    }
    
    @MainActor
    private func loadUserName() async {
        isLoadingUserName = true
        
        do {
            let user = try await SupabaseService.shared.client.auth.session.user
            
            // Get full name from user metadata
            if let fullNameJSON = user.userMetadata["full_name"] {
                switch fullNameJSON {
                case .string(let fullName):
                    userFullName = fullName
                default:
                    do {
                        let data = try JSONEncoder().encode(fullNameJSON)
                        let fullName = try JSONDecoder().decode(String.self, from: data)
                        userFullName = fullName
                    } catch {
                        print("⚠️ Could not decode full_name from metadata")
                        userFullName = "User"
                    }
                }
            } else {
                // If no name in metadata, try to get first name from phone or email
                if let phone = user.phone {
                    userFullName = "User"
                } else if let email = user.email {
                    // Extract first part of email as fallback
                    let emailParts = email.components(separatedBy: "@")
                    userFullName = emailParts.first?.capitalized ?? "User"
                } else {
                    userFullName = "User"
                }
            }
            
            print("✅ Loaded user name for HomeView: \(userFullName)")
            
        } catch {
            print("❌ Error loading user name: \(error.localizedDescription)")
            userFullName = "User"
        }
        
        isLoadingUserName = false
    }
}

// MARK: - Incomes List View

struct IncomesListView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var incomes: [IncomeItem]
    @State private var showAddIncome = false
    @State private var editingIncome: IncomeItem?
    
    var totalIncome: Double {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if incomes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No income yet")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Tap + to add your first income")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(incomes) { income in
                            IncomeRowView(
                                income: income,
                                onEdit: {
                                    editingIncome = income
                                },
                                onDelete: {
                                    Task {
                                        do {
                                            try await SupabaseService.shared.deleteIncome(id: income.id)
                                            await MainActor.run {
                                                withAnimation {
                                                    incomes.removeAll { $0.id == income.id }
                                                }
                                            }
                                        } catch {
                                            print("Failed to delete income: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Income • \(totalIncome.formatAsCurrency())")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddIncome = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.green)
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(incomes: $incomes)
            }
            .sheet(item: $editingIncome) { income in
                EditIncomeSheet(incomes: $incomes, income: income)
            }
        }
    }
}

// MARK: - Income Row View

struct IncomeRowView: View {
    let income: IncomeItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(income.source)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(income.date, style: .date)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(income.amount.formatAsCurrency())
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
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
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
        )
    }
}

// MARK: - Expenses List View

struct ExpensesListView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expenses: [ExpenseItem]
    @State private var showAddExpense = false
    @State private var editingExpense: ExpenseItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if expenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No expenses yet")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Tap + to add your first primary expense")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(expenses) { expense in
                            ExpenseRowView(
                                expense: expense,
                                onEdit: {
                                    editingExpense = expense
                                },
                                onDelete: {
                                    Task {
                                        do {
                                            try await SupabaseService.shared.deleteExpense(id: expense.id)
                                            await MainActor.run {
                                                withAnimation {
                                                    expenses.removeAll { $0.id == expense.id }
                                                }
                                            }
                                        } catch {
                                            print("Failed to delete expense: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Primary Monthly Expenses • \(expenses.reduce(0) { $0 + $1.amount }.formatAsCurrency())")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddExpense = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(expenses: $expenses)
            }
            .sheet(item: $editingExpense) { expense in
                EditExpenseSheet(expenses: $expenses, expense: expense)
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: ExpenseItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.red.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.description.isEmpty ? "Expense" : expense.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(expense.description.isEmpty ? .secondary : .primary)
                
                Text(expense.date, style: .date)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(expense.amount.formatAsCurrency())
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Subscriptions List View

struct SubscriptionsListView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var subscriptions: [SubscriptionItem]
    @State private var showAddSubscription = false
    @State private var editingSubscription: SubscriptionItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if subscriptions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No subscriptions yet")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Tap + to add your first subscription")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(subscriptions) { subscription in
                            SubscriptionRowView(
                                subscription: subscription,
                                onEdit: {
                                    editingSubscription = subscription
                                },
                                onDelete: {
                                    Task {
                                        do {
                                            try await SupabaseService.shared.deleteSubscription(id: subscription.id)
                                            await MainActor.run {
                                                withAnimation {
                                                    subscriptions.removeAll { $0.id == subscription.id }
                                                }
                                            }
                                        } catch {
                                            print("Failed to delete subscription: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Subscriptions (\(subscriptions.reduce(0) { $0 + $1.amount }.formatAsCurrency()))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddSubscription = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            .sheet(isPresented: $showAddSubscription) {
                AddSubscriptionSheet(subscriptions: $subscriptions)
            }
            .sheet(item: $editingSubscription) { subscription in
                EditSubscriptionSheet(subscriptions: $subscriptions, subscription: subscription)
            }
        }
    }
}

struct SubscriptionRowView: View {
    let subscription: SubscriptionItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.purple.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "repeat.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.purple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name.isEmpty ? "Subscription" : subscription.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(subscription.name.isEmpty ? .secondary : .primary)
                
                Text("Monthly • Added \(subscription.date, style: .date)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(subscription.amount.formatAsCurrency())
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
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
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Add Income Sheet

struct AddIncomeSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var incomes: [IncomeItem]
    @State private var amount: String = ""
    @State private var source: String = ""
    @State private var errorMessage: String = ""
    
    var isValidAmount: Bool {
        guard !amount.isEmpty else { return false }
        return Double(amount) != nil && Double(amount)! > 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Add Income")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Salary, Freelance, Bonus", text: $source)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
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
                
                Button(action: {
                    validateAndAddIncome()
                }) {
                    Text("Add Income")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(amount.isEmpty ? Color.gray.opacity(0.5) : .green)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.5 : 1.0)
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
    
    private func validateAndAddIncome() {
        errorMessage = ""
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 2500 or 2500.50)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // All validations passed - Save to Supabase
        Task {
            do {
                let newIncome = try await SupabaseService.shared.createIncome(
                    source: source.isEmpty ? "Income" : source,
                    amount: value
                )
                await MainActor.run {
                    incomes.append(newIncome)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Edit Income Sheet

struct EditIncomeSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var incomes: [IncomeItem]
    let income: IncomeItem
    @State private var amount: String = ""
    @State private var source: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Edit Income")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Source")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Salary, Freelance, Bonus", text: $source)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
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
                
                Button(action: {
                    validateAndSaveChanges()
                }) {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(amount.isEmpty ? Color.gray.opacity(0.5) : .green)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.5 : 1.0)
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
                amount = String(format: "%.2f", income.amount)
                source = income.source
            }
        }
    }
    
    private func validateAndSaveChanges() {
        errorMessage = ""
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 2500 or 2500.50)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // All validations passed - Update in Supabase
        Task {
            do {
                try await SupabaseService.shared.updateIncome(
                    id: income.id,
                    source: source.isEmpty ? "Income" : source,
                    amount: value
                )
                await MainActor.run {
                    if let index = incomes.firstIndex(where: { $0.id == income.id }) {
                        incomes[index].amount = value
                        incomes[index].source = source.isEmpty ? "Income" : source
                    }
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to update: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expenses: [ExpenseItem]
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Add Primary Expense")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Rent, Utilities, Groceries", text: $description)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
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
                
                Button(action: {
                    validateAndAddExpense()
                }) {
                    Text("Add Expense")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(amount.isEmpty ? Color.gray.opacity(0.5) : .red)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.5 : 1.0)
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
    
    private func validateAndAddExpense() {
        errorMessage = ""
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 50 or 50.99)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // All validations passed - Save to Supabase
        Task {
            do {
                let newExpense = try await SupabaseService.shared.createExpense(
                    description: description.isEmpty ? "Expense" : description,
                    amount: value
                )
                await MainActor.run {
                    expenses.append(newExpense)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Edit Expense Sheet

struct EditExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var expenses: [ExpenseItem]
    let expense: ExpenseItem
    
    @State private var amount: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Edit Primary Expense")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Rent, Utilities, Groceries", text: $description)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
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
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.5 : 1.0)
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
                amount = String(format: "%.2f", expense.amount)
                description = expense.description
            }
        }
    }
    
    private func saveChanges() {
        guard let value = Double(amount),
              let index = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        
        expenses[index].amount = value
        expenses[index].description = description
        dismiss()
    }
}

// MARK: - Add Subscription Sheet

struct AddSubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var subscriptions: [SubscriptionItem]
    @State private var amount: String = ""
    @State private var name: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Add Subscription")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.purple)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.purple)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subscription Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Netflix, Spotify", text: $name)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .padding(.horizontal, 20)
                
                Text("This will be counted monthly")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
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
                
                Button(action: {
                    validateAndAddSubscription()
                }) {
                    Text("Add Subscription")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(amount.isEmpty || name.isEmpty ? Color.gray.opacity(0.5) : .purple)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .disabled(amount.isEmpty || name.isEmpty)
                .opacity(amount.isEmpty || name.isEmpty ? 0.5 : 1.0)
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
    
    private func validateAndAddSubscription() {
        errorMessage = ""
        
        // Check if name is empty
        if name.isEmpty {
            errorMessage = "Please enter a subscription name"
            return
        }
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 9.99 or 15)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // All validations passed - Save to database
        Task {
            do {
                let newSubscription = try await SupabaseService.shared.createSubscription(name: name, amount: value)
                await MainActor.run {
                    subscriptions.append(newSubscription)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to save subscription: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Edit Subscription Sheet

struct EditSubscriptionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var subscriptions: [SubscriptionItem]
    let subscription: SubscriptionItem
    
    @State private var amount: String = ""
    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Edit Subscription")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.purple)
                        
                        TextField("0.00", text: $amount)
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.purple)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subscription Name")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Netflix, Spotify", text: $name)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
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
                .disabled(amount.isEmpty)
                .opacity(amount.isEmpty ? 0.5 : 1.0)
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
                amount = String(format: "%.2f", subscription.amount)
                name = subscription.name
            }
        }
    }
    
    private func saveChanges() {
        guard let value = Double(amount),
              let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else { return }
        
        // Save to database
        Task {
            do {
                try await SupabaseService.shared.updateSubscription(id: subscription.id, name: name, amount: value)
                await MainActor.run {
                    subscriptions[index].amount = value
                    subscriptions[index].name = name
                    dismiss()
                }
            } catch {
                print("Failed to update subscription: \(error.localizedDescription)")
            }
        }
    }
}

