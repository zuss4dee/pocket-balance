//
//  ProfileSettingsView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 07/10/2025.
//

import SwiftUI
import Supabase

struct ProfileSettingsView: View {
    let isPresentedAsSheet: Bool
    let onDismiss: (() -> Void)?
    
    @AppStorage("appearance") private var appearance: String = "system"
    @State private var userFullName: String = ""
    @State private var userPhone: String = ""
    @State private var userEmail: String = ""
    @State private var isLoadingProfile = true
    @State private var isSaving = false
    @State private var showEditName = false
    @State private var showEditPhone = false
    @State private var showEditEmail = false
    @State private var showChangePassword = false
    @State private var showDeleteAccount = false
    @State private var showDeleteConfirmation = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var isProfileIncomplete = false
    
    init(isPresentedAsSheet: Bool = false, onDismiss: (() -> Void)? = nil) {
        self.isPresentedAsSheet = isPresentedAsSheet
        self.onDismiss = onDismiss
    }
    
    private var userInitial: String {
        if let firstChar = userFullName.first {
            return String(firstChar).uppercased()
        }
        return "U"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Completion Prompt (if incomplete and presented as sheet)
                    if isPresentedAsSheet && isProfileIncomplete {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Complete Your Profile")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Please fill in your personal details to get the most out of Pocket Balance")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Group {
                                    if isLoadingProfile {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text(userInitial)
                                            .font(.system(size: 48, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        if isLoadingProfile {
                            ProgressView()
                                .padding(.top, 8)
                        } else {
                            VStack(spacing: 4) {
                                Text(userFullName.isEmpty ? "User" : userFullName)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                
                                if !userEmail.isEmpty {
                                    Text(userEmail)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.secondary)
                                } else if !userPhone.isEmpty {
                                    Text(userPhone)
                                        .font(.system(size: 15, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    
                    // Settings Sections
                    VStack(spacing: 16) {
                        // Appearance
                        SettingsSection(title: "Appearance") {
                            VStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Custom styled toggle for Light/Dark
                                    Toggle(isOn: Binding(
                                        get: { appearance == "dark" },
                                        set: { appearance = $0 ? "dark" : "light" }
                                    )) {
                                        Text("Dark Mode")
                                            .font(.system(size: 17, weight: .medium))
                                    }
                                    .toggleStyle(AccentPillToggleStyle())
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)

                                    // System option shortcut
                                    Button(action: { appearance = "system" }) {
                                        Text("Use System Appearance")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                }
                            }
                        }

                        // Personal Information
                        SettingsSection(title: "Personal Information") {
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "person.fill",
                                    title: "Name",
                                    value: userFullName.isEmpty ? "Not set" : userFullName,
                                    action: { showEditName = true }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                SettingsRow(
                                    icon: "phone.fill",
                                    title: "Phone",
                                    value: userPhone.isEmpty ? "Not set" : userPhone,
                                    action: { showEditPhone = true }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                SettingsRow(
                                    icon: "envelope.fill",
                                    title: "Email",
                                    value: userEmail.isEmpty ? "Not set" : userEmail,
                                    action: { showEditEmail = true }
                                )
                            }
                        }
                        
                        // Security
                        SettingsSection(title: "Security") {
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "lock.fill",
                                    title: "Change Password",
                                    value: "••••••••",
                                    action: { showChangePassword = true }
                                )
                            }
                        }
                        
                        // Account
                        SettingsSection(title: "Account") {
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "trash.fill",
                                    title: "Delete Account",
                                    value: "",
                                    isDestructive: true,
                                    action: { showDeleteAccount = true }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Messages
                    if let errorMessage = errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    if let successMessage = successMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(successMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isPresentedAsSheet {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            onDismiss?()
                        }
                    }
                }
            }
            .task {
                await loadUserProfile()
                checkProfileCompletion()
            }
            .sheet(isPresented: $showEditName) {
                EditNameSheet(
                    currentName: userFullName,
                    onSave: { newName in
                        Task {
                            await updateName(newName)
                        }
                    }
                )
            }
            .sheet(isPresented: $showEditPhone) {
                EditPhoneSheet(
                    currentPhone: userPhone,
                    onSave: { newPhone in
                        Task {
                            await updatePhone(newPhone)
                        }
                    }
                )
            }
            .sheet(isPresented: $showEditEmail) {
                EditEmailSheet(
                    currentEmail: userEmail,
                    onSave: { newEmail in
                        Task {
                            await updateEmail(newEmail)
                        }
                    }
                )
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordSheet()
            }
            .alert("Delete Account", isPresented: $showDeleteAccount) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showDeleteConfirmation = true
                }
            } message: {
                Text("⚠️ WARNING: This will permanently delete your account and ALL your data (income, expenses, budgets, credit cards). This action cannot be undone.")
            }
            .alert("Final Confirmation", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("DELETE FOREVER", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("🚨 LAST CHANCE: This will permanently delete your account and ALL data. You will NOT be able to log back in. Are you absolutely sure?")
            }
        }
    }
    
    // MARK: - Profile Loading
    
    @MainActor
    private func loadUserProfile() async {
        isLoadingProfile = true
        errorMessage = nil
        
        do {
            let user = try await SupabaseService.shared.client.auth.session.user
            
            // Get phone number
            if let phone = user.phone {
                userPhone = phone
            }
            
            // Get email
            if let email = user.email {
                userEmail = email
            }
            
            // Get full name from metadata
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
                    }
                }
            }
            
            print("✅ Loaded user profile for settings")
            
        } catch {
            print("❌ Error loading user profile: \(error.localizedDescription)")
            errorMessage = "Failed to load profile information"
        }
        
        isLoadingProfile = false
    }
    
    // MARK: - Profile Completion Check
    
    private func checkProfileCompletion() {
        let hasName = !userFullName.isEmpty
        let hasEmail = !userEmail.isEmpty
        let hasPhone = !userPhone.isEmpty
        
        // Profile is incomplete if name is missing OR both email and phone are missing
        isProfileIncomplete = !hasName || (!hasEmail && !hasPhone)
    }
    
    // MARK: - Update Functions
    
    @MainActor
    private func updateName(_ newName: String) async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let attributes = UserAttributes(data: ["full_name": .string(newName)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            userFullName = newName
            successMessage = "Name updated successfully"
            
            // Update profile completion status
            checkProfileCompletion()
            
            // Clear success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                successMessage = nil
            }
            
        } catch {
            errorMessage = "Failed to update name. Please try again."
        }
        
        isSaving = false
    }
    
    @MainActor
    private func updatePhone(_ newPhone: String) async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // Check if the phone number is already in use by querying the database
            let response = try await SupabaseService.shared.client
                .from("profiles")
                .select("id")
                .eq("phone", value: newPhone)
                .execute()
            
            // If we get results, the phone number is already in use
            if !response.data.isEmpty {
                errorMessage = "This phone number is already associated with another account. Please use a different number."
                isSaving = false
                return
            }
            
            // Phone number is available, show a simple confirmation dialog
            // For now, we'll just update the phone number directly since we've verified it's not in use
            // In a production app, you'd want to implement a proper OTP system that doesn't interfere with auth
            let attributes = UserAttributes(data: ["phone": .string(newPhone)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            userPhone = newPhone
            successMessage = "Phone number updated successfully"
            
            // Update profile completion status
            checkProfileCompletion()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                successMessage = nil
            }
            
        } catch {
            errorMessage = "Failed to update phone number. Please try again."
        }
        
        isSaving = false
    }
    
    
    @MainActor
    private func updateEmail(_ newEmail: String) async {
        isSaving = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let attributes = UserAttributes(data: ["email": .string(newEmail)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            userEmail = newEmail
            successMessage = "Email updated successfully"
            
            // Update profile completion status
            checkProfileCompletion()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                successMessage = nil
            }
            
        } catch {
            errorMessage = "Failed to update email. Please try again."
        }
        
        isSaving = false
    }
    
    @MainActor
    private func deleteAccount() async {
        isSaving = true
        errorMessage = nil
        
        do {
            // Actually delete the user account and all their data
            try await SupabaseService.shared.deleteUserAccount()
            successMessage = "Account and all data deleted successfully."
            
            // Force sign out to ensure user is logged out
            print("🔄 Attempting to sign out user after account deletion...")
            try await SupabaseService.shared.client.auth.signOut()
            print("✅ User signed out successfully after account deletion")
            
            // Dismiss the sheet after successful deletion
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onDismiss?()
            }
            
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

// MARK: - Settings Components

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            content
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(icon: String, title: String, value: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.value = value
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(isDestructive ? .red : .primary)
                    
                    if !value.isEmpty {
                        Text(value)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Custom Toggle Style (CSS-like pill switch)

struct AccentPillToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { configuration.isOn.toggle() } }) {
            HStack {
                configuration.label
                Spacer()
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(configuration.isOn ? Color(red: 148/255, green: 118/255, blue: 255/255) : Color(white: 0.32))
                        .frame(width: 50, height: 30)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 5)
                        .background(Circle().fill(configuration.isOn ? Color.white : Color.clear))
                        .frame(width: 20, height: 20)
                        .shadow(color: Color.black.opacity(0.26), radius: 7, x: 5, y: 2)
                        .padding(.horizontal, 5)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edit Sheets

struct EditNameSheet: View {
    @Environment(\.dismiss) var dismiss
    let currentName: String
    let onSave: (String) -> Void
    
    @State private var newName: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text("Edit Name")
                    .font(.system(size: 24, weight: .bold))
                
                TextField("Enter your full name", text: $newName)
                    .font(.system(size: 17))
                    .padding()
                    .frame(height: 56)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                
                if let errorMessage = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await saveName()
                    }
                }) {
                    HStack {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(newName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(28)
                }
                .disabled(newName.isEmpty || isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                newName = currentName
            }
        }
    }
    
    @MainActor
    private func saveName() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let attributes = UserAttributes(data: ["full_name": .string(newName)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            // Success - call the onSave callback and dismiss
            onSave(newName)
            dismiss()
            
        } catch {
            errorMessage = "Failed to update name. Please try again."
        }
        
        isLoading = false
    }
}

struct EditPhoneSheet: View {
    @Environment(\.dismiss) var dismiss
    let currentPhone: String
    let onSave: (String) -> Void
    
    @State private var countryCode: String = "+44"
    @State private var phoneNumber: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var formattedPhoneNumber: String {
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        return "\(countryCode)\(cleaned)"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text("Edit Phone Number")
                    .font(.system(size: 24, weight: .bold))
                
                HStack(spacing: 12) {
                    Menu {
                        Button("+44 (UK)") { countryCode = "+44" }
                        Button("+1 (US)") { countryCode = "+1" }
                        Button("+234 (NG)") { countryCode = "+234" }
                        Button("+91 (IN)") { countryCode = "+91" }
                    } label: {
                        HStack {
                            Text(countryCode)
                                .font(.system(size: 18))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    
                    TextField("7911 123456", text: $phoneNumber)
                        .font(.system(size: 18))
                        .keyboardType(.phonePad)
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Text("Format: \(formattedPhoneNumber)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                if let errorMessage = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await savePhoneNumber()
                    }
                }) {
                    HStack {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(phoneNumber.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(28)
                }
                .disabled(phoneNumber.isEmpty || isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Edit Phone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !currentPhone.isEmpty {
                    // Extract country code and number from current phone
                    if currentPhone.hasPrefix("+") {
                        let components = currentPhone.dropFirst().components(separatedBy: " ")
                        if components.count >= 2 {
                            countryCode = "+\(components[0])"
                            phoneNumber = components[1...].joined(separator: " ")
                        } else {
                            countryCode = String(currentPhone.prefix(4))
                            phoneNumber = String(currentPhone.dropFirst(4))
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func savePhoneNumber() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if the phone number is already in use by querying the database
            let response = try await SupabaseService.shared.client
                .from("profiles")
                .select("id")
                .eq("phone", value: formattedPhoneNumber)
                .execute()
            
            // If we get results, the phone number is already in use
            if !response.data.isEmpty {
                errorMessage = "This phone number is already associated with another account. Please use a different number."
                isLoading = false
                return
            }
            
            // Phone number is available, update it
            let attributes = UserAttributes(data: ["phone": .string(formattedPhoneNumber)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            // Success - call the onSave callback and dismiss
            onSave(formattedPhoneNumber)
            dismiss()
            
        } catch {
            errorMessage = "Failed to update phone number. Please try again."
        }
        
        isLoading = false
    }
}

struct EditEmailSheet: View {
    @Environment(\.dismiss) var dismiss
    let currentEmail: String
    let onSave: (String) -> Void
    
    @State private var newEmail: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isValidEmail: Bool {
        newEmail.contains("@") && newEmail.contains(".")
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text("Edit Email")
                    .font(.system(size: 24, weight: .bold))
                
                TextField("Enter your email", text: $newEmail)
                    .font(.system(size: 17))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .frame(height: 56)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                
                if let errorMessage = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await saveEmail()
                    }
                }) {
                    HStack {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold))
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background((newEmail.isEmpty || !isValidEmail) ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(28)
                }
                .disabled(newEmail.isEmpty || !isValidEmail || isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Edit Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                newEmail = currentEmail
            }
        }
    }
    
    @MainActor
    private func saveEmail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Check if the email is already in use by querying the database
            let response = try await SupabaseService.shared.client
                .from("profiles")
                .select("id")
                .eq("email", value: newEmail)
                .execute()
            
            // If we get results, the email is already in use
            if !response.data.isEmpty {
                errorMessage = "This email is already associated with another account. Please use a different email."
                isLoading = false
                return
            }
            
            // Email is available, update it
            let attributes = UserAttributes(data: ["email": .string(newEmail)])
            try await SupabaseService.shared.client.auth.update(user: attributes)
            
            // Success - call the onSave callback and dismiss
            onSave(newEmail)
            dismiss()
            
        } catch {
            errorMessage = "Failed to update email. Please try again."
        }
        
        isLoading = false
    }
}

struct ChangePasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var isValidPassword: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                Text("Change Password")
                    .font(.system(size: 24, weight: .bold))
                
                VStack(spacing: 16) {
                    SecureField("Current password", text: $currentPassword)
                        .font(.system(size: 17))
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    
                    SecureField("New password", text: $newPassword)
                        .font(.system(size: 17))
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    
                    SecureField("Confirm new password", text: $confirmPassword)
                        .font(.system(size: 17))
                        .padding()
                        .frame(height: 56)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                if let errorMessage = errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await changePassword()
                    }
                }) {
                    HStack {
                        Text("Change Password")
                            .font(.system(size: 17, weight: .semibold))
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background((currentPassword.isEmpty || !isValidPassword) ? Color.gray.opacity(0.3) : Color.blue)
                    .cornerRadius(28)
                }
                .disabled(currentPassword.isEmpty || !isValidPassword || isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Change Password")
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
    
    @MainActor
    private func changePassword() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await SupabaseService.shared.client.auth.update(user: UserAttributes(
                data: ["password": .string(newPassword)]
            ))
            
            dismiss()
            
        } catch {
            errorMessage = "Failed to change password. Please try again."
        }
        
        isLoading = false
    }
}


#Preview {
    ProfileSettingsView()
}
