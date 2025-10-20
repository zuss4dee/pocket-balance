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
    
    private let supabaseURL = URL(string: AppConfig.supabaseURL)!
    private let supabaseKey = AppConfig.supabaseAnonKey
    
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
        
        // Clear user metadata and settings from auth.users
        try await clearUserAuthData()
        
        // Clear any local storage/cache
        try await clearLocalStorage()
        
        // Delete the user from auth.users using Admin API
        try await deleteUserFromAuth(userId: userId)
        
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
    
    private func clearUserAuthData() async throws {
        // Clear user metadata to remove any settings/preferences stored there
        let emptyMetadata = UserAttributes(data: [:])
        try await client.auth.update(user: emptyMetadata)
        
        print("✅ User auth metadata cleared")
    }
    
    private func clearLocalStorage() async throws {
        // Clear any local storage that might contain user settings
        UserDefaults.standard.removeObject(forKey: "user_preferences")
        UserDefaults.standard.removeObject(forKey: "cached_user_data")
        UserDefaults.standard.removeObject(forKey: "last_sync_date")
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        UserDefaults.standard.removeObject(forKey: "profile_setup_completed")
        
        // Clear any other potential user-specific keys
        let userDefaults = UserDefaults.standard
        let allKeys = userDefaults.dictionaryRepresentation().keys
        for key in allKeys {
            if key.contains("user_") || key.contains("profile_") || key.contains("settings_") {
                userDefaults.removeObject(forKey: key)
            }
        }
        
        // Force synchronize to ensure changes are saved
        userDefaults.synchronize()
        
        print("✅ Local storage cleared")
    }
    
    private func deleteUserFromAuth(userId: UUID) async throws {
        // Use direct Admin API approach since Edge Function has syntax issues
        // This uses the service role key to delete the user from auth.users
        
        // Create admin client with service role key
        let adminClient = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: AppConfig.supabaseServiceRoleKey
        )
        
        print("🔄 Attempting to delete user from auth.users: \(userId)")
        
        // Delete user from auth.users using admin privileges
        _ = try await adminClient.auth.admin.deleteUser(id: userId)
        
        print("✅ User deleted from auth.users")
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
    
    // MARK: - CREDIT CARDS OPERATIONS
    
    func fetchCreditCards() async throws -> [CreditCard] {
        let userId = try await getCurrentUserId()
        
        let response: [DatabaseCreditCard] = try await client
            .from("credit_cards")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toCreditCard() }
    }
    
    func createCreditCard(name: String, limit: Double, color: String) async throws -> CreditCard {
        let userId = try await getCurrentUserId()
        
        let newCreditCard = DatabaseCreditCardInsert(user_id: userId, card_name: name, credit_limit: limit, card_color: color)
        
        let response: DatabaseCreditCard = try await client
            .from("credit_cards")
            .insert(newCreditCard)
            .select()
            .single()
            .execute()
            .value
        
        return response.toCreditCard()
    }
    
    func updateCreditCard(id: UUID, name: String, limit: Double, color: String) async throws {
        let update = DatabaseCreditCardUpdate(card_name: name, credit_limit: limit, card_color: color)
        
        try await client
            .from("credit_cards")
            .update(update)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func deleteCreditCard(id: UUID) async throws {
        try await client
            .from("credit_cards")
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

// Credit Card Models
struct DatabaseCreditCard: Codable {
    let id: UUID
    let user_id: UUID
    let card_name: String
    let credit_limit: Double
    let card_color: String
    let created_at: Date
    let updated_at: Date
    
    func toCreditCard() -> CreditCard {
        let card = CreditCard(id: id, name: card_name, limit: credit_limit, color: card_color)
        return card
    }
}

struct DatabaseCreditCardInsert: Codable {
    let user_id: UUID
    let card_name: String
    let credit_limit: Double
    let card_color: String
}

struct DatabaseCreditCardUpdate: Codable {
    let card_name: String
    let credit_limit: Double
    let card_color: String
}

