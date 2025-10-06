//
//  HomeView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

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

struct BudgetCategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var icon: String
    var color: String
    
    init(id: UUID = UUID(), name: String, amount: Double, icon: String = "tag.fill", color: String = "blue") {
        self.id = id
        self.name = name
        self.amount = amount
        self.icon = icon
        self.color = color
    }
    
    var categoryColor: Color {
        switch color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
}

struct HomeView: View {
    @Binding var totalIncome: Double
    @Binding var expenses: [ExpenseItem]
    @Binding var subscriptions: [SubscriptionItem]
    
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var showAddSubscription = false
    @State private var showExpensesList = false
    @State private var showSubscriptionsList = false
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var totalSubscriptions: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var remainingBalance: Double {
        totalIncome - totalExpenses - totalSubscriptions
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Greeting Header
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Good evening,")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            Text("Dami")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Remaining Balance - Hero Card
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
                    
                    // Section Divider
                    VStack(spacing: 6) {
                        Divider()
                            .padding(.horizontal, 20)
                        
                        Text("BREAKDOWN")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                    .padding(.vertical, 8)
                    
                    // Dashboard Cards
                    VStack(spacing: 12) {
                        // Income Card
                        Button(action: {
                            showAddIncome = true
                        }) {
                            DashboardCardView(
                                title: "Total Income",
                                metric: totalIncome.formatAsShortCurrency(),
                                context: "Tap to add income",
                                iconSystemName: "arrow.up.circle",
                                iconColor: .green
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Expenses Card
                        Button(action: {
                            if expenses.isEmpty {
                                showAddExpense = true
                            } else {
                                showExpensesList = true
                            }
                        }) {
                            DashboardCardView(
                                title: "Expenses This Month",
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
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Pocket Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Notifications tapped")
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(totalIncome: $totalIncome)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(expenses: $expenses)
            }
            .sheet(isPresented: $showAddSubscription) {
                AddSubscriptionSheet(subscriptions: $subscriptions)
            }
            .sheet(isPresented: $showExpensesList) {
                ExpensesListView(expenses: $expenses)
            }
            .sheet(isPresented: $showSubscriptionsList) {
                SubscriptionsListView(subscriptions: $subscriptions)
            }
        }
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
                        Text("Tap + to add your first expense")
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
                                    withAnimation {
                                        expenses.removeAll { $0.id == expense.id }
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
            .navigationTitle("Expenses (\(expenses.reduce(0) { $0 + $1.amount }.formatAsCurrency()))")
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
                                    withAnimation {
                                        subscriptions.removeAll { $0.id == subscription.id }
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
    @Binding var totalIncome: Double
    @State private var amount: String = ""
    @State private var description: String = ""
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
                    Text("Description (Optional)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Salary, Freelance", text: $description)
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
        
        // All validations passed
        totalIncome += value
        dismiss()
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
                    Text("Add Expense")
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
                    
                    TextField("e.g., Groceries, Transport", text: $description)
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
        
        // All validations passed
        let expense = ExpenseItem(amount: value, description: description)
        expenses.append(expense)
        dismiss()
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
                    Text("Edit Expense")
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
                    
                    TextField("e.g., Groceries, Transport", text: $description)
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
        
        // All validations passed
        let subscription = SubscriptionItem(amount: value, name: name)
        subscriptions.append(subscription)
        dismiss()
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
        
        subscriptions[index].amount = value
        subscriptions[index].name = name
        dismiss()
    }
}

// MARK: - Budgeting View

struct BudgetingView: View {
    @Environment(\.dismiss) var dismiss
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
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

struct BudgetCategoryRow: View {
    let category: BudgetCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(category.categoryColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(category.categoryColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Budget allocation")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(category.amount.formatAsCurrency())
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

// MARK: - Add Budget Category Sheet

struct AddBudgetCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var budgetCategories: [BudgetCategory]
    let availableBalance: Double
    @State private var categoryName: String = ""
    @State private var amount: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColor: String = "blue"
    @State private var errorMessage: String = ""
    
    let availableIcons = ["tag.fill", "cart.fill", "fork.knife", "house.fill", "car.fill", "airplane", "gamecontroller.fill", "book.fill", "gift.fill", "heart.fill"]
    let availableColors = ["blue", "purple", "green", "orange", "red", "pink", "yellow", "teal"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header - Available Balance
                    VStack(spacing: 6) {
                        Text("Available to Budget")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(availableBalance.formatAsCurrency())
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.bottom, 32)
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Category Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CATEGORY NAME")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            TextField("e.g., Groceries, Rent, Entertainment", text: $categoryName)
                                .font(.system(size: 17))
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                )
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AMOUNT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            HStack(spacing: 8) {
                                Text("£")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.primary)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            )
                        }
                        
                        // Icon & Color Combined
                        VStack(spacing: 16) {
                            // Icon Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ICON")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(availableIcons, id: \.self) { icon in
                                            Circle()
                                                .fill(selectedIcon == icon ? colorFromString(selectedColor).opacity(0.15) : Color(UIColor.tertiarySystemGroupedBackground))
                                                .frame(width: 46, height: 46)
                                                .overlay(
                                                    Image(systemName: icon)
                                                        .font(.system(size: 20))
                                                        .foregroundColor(selectedIcon == icon ? colorFromString(selectedColor) : .secondary)
                                                )
                                                .onTapGesture {
                                                    selectedIcon = icon
                                                }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("COLOR")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                                
                                HStack(spacing: 10) {
                                    ForEach(availableColors, id: \.self) { colorName in
                                        Circle()
                                            .fill(colorFromString(colorName))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(UIColor.systemBackground), lineWidth: selectedColor == colorName ? 3 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(colorFromString(colorName).opacity(0.3), lineWidth: selectedColor == colorName ? 2 : 0)
                                                    .padding(selectedColor == colorName ? -2 : 0)
                                            )
                                            .onTapGesture {
                                                selectedColor = colorName
                                            }
                                    }
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
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                // Add Button
                Button(action: {
                    validateAndAddCategory()
                }) {
                    Text("Add Budget Category")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(categoryName.isEmpty || amount.isEmpty ? Color.gray : .blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGroupedBackground))
                .disabled(categoryName.isEmpty || amount.isEmpty)
                .opacity(categoryName.isEmpty || amount.isEmpty ? 0.6 : 1.0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Budget")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 17))
                }
            }
        }
    }
    
    private func validateAndAddCategory() {
        errorMessage = ""
        
        // Check if category name is empty
        if categoryName.isEmpty {
            errorMessage = "Please enter a category name"
            return
        }
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 500 or 500.50)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // Check if amount exceeds available balance
        if value > availableBalance {
            errorMessage = "Amount exceeds available balance (\(availableBalance.formatAsCurrency()))"
            return
        }
        
        // All validations passed
        let category = BudgetCategory(name: categoryName, amount: value, icon: selectedIcon, color: selectedColor)
        budgetCategories.append(category)
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
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
}

// MARK: - Edit Budget Category Sheet

struct EditBudgetCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var budgetCategories: [BudgetCategory]
    let category: BudgetCategory
    let availableBalance: Double
    @State private var categoryName: String = ""
    @State private var amount: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColor: String = "blue"
    @State private var errorMessage: String = ""
    
    let availableIcons = ["tag.fill", "cart.fill", "fork.knife", "house.fill", "car.fill", "airplane", "gamecontroller.fill", "book.fill", "gift.fill", "heart.fill"]
    let availableColors = ["blue", "purple", "green", "orange", "red", "pink", "yellow", "teal"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header - Available Balance
                    VStack(spacing: 6) {
                        Text("Available to Budget")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(availableBalance.formatAsCurrency())
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .padding(.bottom, 32)
                    
                    // Form Section
                    VStack(spacing: 20) {
                        // Category Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CATEGORY NAME")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            TextField("e.g., Groceries, Rent, Entertainment", text: $categoryName)
                                .font(.system(size: 17))
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                                )
                        }
                        
                        // Amount
                        VStack(alignment: .leading, spacing: 6) {
                            Text("AMOUNT")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            
                            HStack(spacing: 8) {
                                Text("£")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .foregroundStyle(.primary)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            )
                        }
                        
                        // Icon & Color Combined
                        VStack(spacing: 16) {
                            // Icon Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ICON")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(availableIcons, id: \.self) { icon in
                                            Circle()
                                                .fill(selectedIcon == icon ? colorFromString(selectedColor).opacity(0.15) : Color(UIColor.tertiarySystemGroupedBackground))
                                                .frame(width: 46, height: 46)
                                                .overlay(
                                                    Image(systemName: icon)
                                                        .font(.system(size: 20))
                                                        .foregroundColor(selectedIcon == icon ? colorFromString(selectedColor) : .secondary)
                                                )
                                                .onTapGesture {
                                                    selectedIcon = icon
                                                }
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            
                            // Color Picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("COLOR")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.8)
                                
                                HStack(spacing: 10) {
                                    ForEach(availableColors, id: \.self) { colorName in
                                        Circle()
                                            .fill(colorFromString(colorName))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(UIColor.systemBackground), lineWidth: selectedColor == colorName ? 3 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(colorFromString(colorName).opacity(0.3), lineWidth: selectedColor == colorName ? 2 : 0)
                                                    .padding(selectedColor == colorName ? -2 : 0)
                                            )
                                            .onTapGesture {
                                                selectedColor = colorName
                                            }
                                    }
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
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                // Save Button
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
                                .fill(categoryName.isEmpty || amount.isEmpty ? Color.gray : .blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(UIColor.systemGroupedBackground))
                .disabled(categoryName.isEmpty || amount.isEmpty)
                .opacity(categoryName.isEmpty || amount.isEmpty ? 0.6 : 1.0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Budget")
                        .font(.system(size: 17, weight: .semibold))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 17))
                }
            }
            .onAppear {
                categoryName = category.name
                amount = String(format: "%.2f", category.amount)
                selectedIcon = category.icon
                selectedColor = category.color
            }
        }
    }
    
    private func validateAndSaveChanges() {
        errorMessage = ""
        
        // Check if category name is empty
        if categoryName.isEmpty {
            errorMessage = "Please enter a category name"
            return
        }
        
        // Check if amount is empty
        if amount.isEmpty {
            errorMessage = "Please enter an amount"
            return
        }
        
        // Check if amount is a valid number
        guard let value = Double(amount) else {
            errorMessage = "Please enter numbers only (e.g., 500 or 500.50)"
            return
        }
        
        // Check if amount is positive
        if value <= 0 {
            errorMessage = "Amount must be greater than zero"
            return
        }
        
        // Check if amount exceeds available balance
        if value > availableBalance {
            errorMessage = "Amount exceeds available balance (\(availableBalance.formatAsCurrency()))"
            return
        }
        
        // All validations passed
        guard let index = budgetCategories.firstIndex(where: { $0.id == category.id }) else { return }
        budgetCategories[index].name = categoryName
        budgetCategories[index].amount = value
        budgetCategories[index].icon = selectedIcon
        budgetCategories[index].color = selectedColor
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
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
}

#Preview {
    HomeView(
        totalIncome: .constant(2500.0),
        expenses: .constant([]),
        subscriptions: .constant([])
    )
}
