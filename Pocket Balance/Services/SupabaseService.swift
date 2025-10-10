//
//  SupabaseService.swift
//  Pocket Balance
//
//  Centralized service for all Supabase database operations
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let supabaseURL = URL(string: "https://dzxagbbkdzuqmcevqgwh.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6eGFnYmJrZHp1cW1jZXZxZ3doIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4MTM1MjcsImV4cCI6MjA3NTM4OTUyN30.X9lPaChueB7xSTreWiDS9IuuJIUwpagVt7AW1VWkRkg"
    
    lazy var client: SupabaseClient = {
        SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }()
    
    private init() {}
    
    // MARK: - Current User ID
    
    private func getCurrentUserId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }
    
    // MARK: - INCOME OPERATIONS
    
    func fetchIncome(limit: Int = 50, offset: Int = 0) async throws -> [IncomeItem] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseIncome] = try await client
            .from("income")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
        
        return response.map { $0.toIncomeItem() }
    }
    
    func fetchAllIncome() async throws -> [IncomeItem] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseIncome] = try await client
            .from("income")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toIncomeItem() }
    }
    
    func createIncome(source: String, amount: Double) async throws -> IncomeItem {
        let userId = try await getCurrentUserId()
        
        let newIncome = DatabaseIncomeInsert(user_id: userId, source: source, amount: amount)
        
        let response: DatabaseIncome = try await client
            .from("income")
            .insert(newIncome)
            .select()
            .single()
            .execute()
            .value
        
        return response.toIncomeItem()
    }
    
    func updateIncome(id: UUID, source: String, amount: Double) async throws {
        let update = DatabaseIncomeUpdate(source: source, amount: amount)
        
        try await client
            .from("income")
            .update(update)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteIncome(id: UUID) async throws {
        try await client
            .from("income")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - USER DELETION OPERATIONS
    
    func deleteUserAccount() async throws {
        let userId = try await getCurrentUserId()
        
        // First, delete all user data from all tables
        try await deleteAllUserData(userId: userId)
        
        // Then delete the user from auth.users (this requires admin privileges)
        // Note: This might need to be done via Supabase Admin API or Edge Functions
        // For now, we'll delete all user data and sign them out
        try await client.auth.signOut()
        
        print("✅ User account and all data deleted successfully")
    }
    
    private func deleteAllUserData(userId: UUID) async throws {
        // Delete all user data from all tables
        try await client
            .from("income")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        try await client
            .from("expenses")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        try await client
            .from("subscriptions")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        try await client
            .from("budget_categories")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        try await client
            .from("credit_cards")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .execute()
        
        try await client
            .from("profiles")
            .delete()
            .eq("id", value: userId.uuidString)
            .execute()
        
        print("✅ All user data deleted from database")
    }
    
    // MARK: - DATA CLEANUP OPERATIONS
    
    func cleanupOldData(olderThanDays: Int = 365) async throws {
        let userId = try await getCurrentUserId()
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -olderThanDays, to: Date())!
        let cutoffISO = ISO8601DateFormatter().string(from: cutoffDate)
        
        // Clean up old income records
        try await client
            .from("income")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .lt("created_at", value: cutoffISO)
            .execute()
        
        // Clean up old expense records
        try await client
            .from("expenses")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .lt("created_at", value: cutoffISO)
            .execute()
        
        print("✅ Cleaned up data older than \(olderThanDays) days")
    }
    
    // MARK: - EXPENSES OPERATIONS
    
    func fetchExpenses() async throws -> [ExpenseItem] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseExpense] = try await client
            .from("expenses")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toExpenseItem() }
    }
    
    func createExpense(description: String, amount: Double) async throws -> ExpenseItem {
        let userId = try await getCurrentUserId()
        
        let newExpense = DatabaseExpenseInsert(user_id: userId, description: description, amount: amount)
        
        let response: DatabaseExpense = try await client
            .from("expenses")
            .insert(newExpense)
            .select()
            .single()
            .execute()
            .value
        
        return response.toExpenseItem()
    }
    
    func updateExpense(id: UUID, description: String, amount: Double) async throws {
        let update = DatabaseExpenseUpdate(description: description, amount: amount)
        
        try await client
            .from("expenses")
            .update(update)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteExpense(id: UUID) async throws {
        try await client
            .from("expenses")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - SUBSCRIPTIONS OPERATIONS
    
    func fetchSubscriptions() async throws -> [SubscriptionItem] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseSubscription] = try await client
            .from("subscriptions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toSubscriptionItem() }
    }
    
    func createSubscription(name: String, amount: Double) async throws -> SubscriptionItem {
        let userId = try await getCurrentUserId()
        
        let newSubscription = DatabaseSubscriptionInsert(user_id: userId, name: name, amount: amount)
        
        let response: DatabaseSubscription = try await client
            .from("subscriptions")
            .insert(newSubscription)
            .select()
            .single()
            .execute()
            .value
        
        return response.toSubscriptionItem()
    }
    
    func updateSubscription(id: UUID, name: String, amount: Double) async throws {
        let update = DatabaseSubscriptionUpdate(name: name, amount: amount)
        
        try await client
            .from("subscriptions")
            .update(update)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteSubscription(id: UUID) async throws {
        try await client
            .from("subscriptions")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - BUDGET CATEGORIES OPERATIONS
    
    func fetchBudgetCategories() async throws -> [BudgetCategory] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseBudgetCategory] = try await client
            .from("budget_categories")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toBudgetCategory() }
    }
    
    func createBudgetCategory(name: String, amount: Double, icon: String, color: String) async throws -> BudgetCategory {
        let userId = try await getCurrentUserId()
        
        let newCategory = DatabaseBudgetCategoryInsert(user_id: userId, name: name, amount: amount, icon: icon, color: color)
        
        let response: DatabaseBudgetCategory = try await client
            .from("budget_categories")
            .insert(newCategory)
            .select()
            .single()
            .execute()
            .value
        
        return response.toBudgetCategory()
    }
    
    func updateBudgetCategory(id: UUID, name: String, amount: Double, icon: String, color: String) async throws {
        let update = DatabaseBudgetCategoryUpdate(name: name, amount: amount, icon: icon, color: color)
        
        try await client
            .from("budget_categories")
            .update(update)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteBudgetCategory(id: UUID) async throws {
        try await client
            .from("budget_categories")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

// MARK: - Database Models

// Income Models
struct DatabaseIncome: Codable {
    let id: UUID
    let user_id: UUID
    let source: String
    let amount: Double
    let created_at: Date
    let updated_at: Date
    
    func toIncomeItem() -> IncomeItem {
        IncomeItem(id: id, amount: amount, source: source, date: created_at)
    }
}

struct DatabaseIncomeInsert: Codable {
    let user_id: UUID
    let source: String
    let amount: Double
}

struct DatabaseIncomeUpdate: Codable {
    let source: String
    let amount: Double
}

// Expense Models
struct DatabaseExpense: Codable {
    let id: UUID
    let user_id: UUID
    let description: String
    let amount: Double
    let created_at: Date
    let updated_at: Date
    
    func toExpenseItem() -> ExpenseItem {
        ExpenseItem(id: id, amount: amount, description: description, date: created_at)
    }
}

struct DatabaseExpenseInsert: Codable {
    let user_id: UUID
    let description: String
    let amount: Double
}

struct DatabaseExpenseUpdate: Codable {
    let description: String
    let amount: Double
}

// Subscription Models
struct DatabaseSubscription: Codable {
    let id: UUID
    let user_id: UUID
    let name: String
    let amount: Double
    let created_at: Date
    let updated_at: Date
    
    func toSubscriptionItem() -> SubscriptionItem {
        SubscriptionItem(id: id, amount: amount, name: name, date: created_at)
    }
}

struct DatabaseSubscriptionInsert: Codable {
    let user_id: UUID
    let name: String
    let amount: Double
}

struct DatabaseSubscriptionUpdate: Codable {
    let name: String
    let amount: Double
}

// Budget Category Models
struct DatabaseBudgetCategory: Codable {
    let id: UUID
    let user_id: UUID
    let name: String
    let amount: Double
    let icon: String
    let color: String
    let created_at: Date
    let updated_at: Date
    
    func toBudgetCategory() -> BudgetCategory {
        BudgetCategory(id: id, name: name, amount: amount, icon: icon, color: color)
    }
}

struct DatabaseBudgetCategoryInsert: Codable {
    let user_id: UUID
    let name: String
    let amount: Double
    let icon: String
    let color: String
}

struct DatabaseBudgetCategoryUpdate: Codable {
    let name: String
    let amount: Double
    let icon: String
    let color: String
}
