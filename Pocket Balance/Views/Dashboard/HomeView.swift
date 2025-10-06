//
//  HomeView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    
    // State for tracking amounts
    @State private var totalIncome: Double = 0.0
    @State private var totalExpenses: Double = 0.0
    
    var remainingBalance: Double {
        totalIncome - totalExpenses
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
                    
                    // Dashboard Cards
                    VStack(spacing: 12) {
                        // Income Card - Tappable
                        Button(action: {
                            showAddIncome = true
                        }) {
                            DashboardCardView(
                                title: "Total Income",
                                metric: "£\(String(format: "%.2f", totalIncome))",
                                context: "Tap to add income",
                                iconSystemName: "arrow.up.circle",
                                iconColor: .green
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Expenses Card - Tappable
                        Button(action: {
                            showAddExpense = true
                        }) {
                            DashboardCardView(
                                title: "Expenses This Month",
                                metric: "£\(String(format: "%.2f", totalExpenses))",
                                context: "Tap to add expenses",
                                iconSystemName: "arrow.down.circle",
                                iconColor: .red
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // Balance Card - Calculated
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Remaining Balance")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                
                                Text("£\(String(format: "%.2f", remainingBalance))")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(remainingBalance >= 0 ? .blue : .red)
                                
                                Text(remainingBalance >= 0 ? "left to spend" : "over budget")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer(minLength: 16)
                            
                            // Owl Mascot
                            Text(remainingBalance >= 0 ? "🦉" : "⚠️")
                                .font(.system(size: 36))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.background)
                        )
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
                    HStack(spacing: 20) {
                        // Notification button
                        Button(action: {
                            print("Notifications tapped")
                        }) {
                            Image(systemName: "bell")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.primary)
                        }
                        
                        // Settings button
                        Button(action: {
                            print("Settings tapped")
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(totalIncome: $totalIncome)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(totalExpenses: $totalExpenses)
            }
        }
    }
}

// MARK: - Add Income Sheet

struct AddIncomeSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var totalIncome: Double
    @State private var amount: String = ""
    @State private var description: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Amount Input
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
                
                // Description
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
                
                Spacer()
                
                // Add Button
                Button(action: {
                    addIncome()
                }) {
                    Text("Add Income")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.green)
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
    
    private func addIncome() {
        guard let value = Double(amount) else { return }
        totalIncome += value
        dismiss()
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var totalExpenses: Double
    @State private var expenses: [ExpenseItem] = []
    @State private var currentAmount: String = ""
    @State private var currentDescription: String = ""
    @State private var showingTotal = false
    
    struct ExpenseItem: Identifiable {
        let id = UUID()
        let amount: Double
        let description: String
    }
    
    var calculatedTotal: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with total
                if !expenses.isEmpty {
                    VStack(spacing: 8) {
                        Text("Total Expenses")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                        
                        Text("£\(String(format: "%.2f", calculatedTotal))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                }
                
                // Expense List
                if !expenses.isEmpty {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(expenses) { expense in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        if !expense.description.isEmpty {
                                            Text(expense.description)
                                                .font(.system(size: 15, weight: .medium))
                                        } else {
                                            Text("Expense")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("£\(String(format: "%.2f", expense.amount))")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    
                                    Button(action: {
                                        removeExpense(expense)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                
                                if expense.id != expenses.last?.id {
                                    Divider()
                                        .padding(.leading, 20)
                                }
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                    }
                }
                
                Spacer()
                
                // Add expense form
                VStack(spacing: 16) {
                    Divider()
                    
                    Text(expenses.isEmpty ? "Add Expenses" : "Add Another")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("£")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.red)
                        
                        TextField("0.00", text: $currentAmount)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 20)
                    
                    TextField("Description (Optional)", text: $currentDescription)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        addExpenseItem()
                    }) {
                        Text("Add to List")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.blue)
                            )
                    }
                    .padding(.horizontal, 20)
                    .disabled(currentAmount.isEmpty)
                    .opacity(currentAmount.isEmpty ? 0.5 : 1.0)
                    
                    if !expenses.isEmpty {
                        Button(action: {
                            saveExpenses()
                        }) {
                            Text("Save All Expenses")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.red)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
                .background(Color(UIColor.systemGroupedBackground))
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
    
    private func addExpenseItem() {
        guard let value = Double(currentAmount) else { return }
        let expense = ExpenseItem(amount: value, description: currentDescription)
        expenses.append(expense)
        currentAmount = ""
        currentDescription = ""
    }
    
    private func removeExpense(_ expense: ExpenseItem) {
        expenses.removeAll { $0.id == expense.id }
    }
    
    private func saveExpenses() {
        totalExpenses += calculatedTotal
        dismiss()
    }
}

#Preview {
    HomeView()
}
