//
//  PhoneEntryView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var countryCode: String = "+44" // Default to UK
    @State private var phoneNumber: String = ""
    @State private var showCountryPicker = false
    
    private var isValidPhoneNumber: Bool {
        // Remove spaces and check if it's a valid length
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "")
        return cleaned.count >= 10 && cleaned.count <= 15
    }
    
    private var formattedPhoneNumber: String {
        // Combine country code with phone number (remove any leading zeros)
        let cleaned = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
        return "\(countryCode)\(cleaned)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Back button
            Button(action: {
                authState.moveToPreviousStep()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
            .padding(.leading, 24)
            .padding(.top, 16)
            
            Spacer()
                .frame(height: 40)
            
            // Title
            Text("Enter mobile number")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text("Enter your mobile number in international format")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
                .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 32)
            
            // Country Code + Phone number input
            HStack(spacing: 12) {
                // Country code picker
                Menu {
                    Button("+44 (UK)") { countryCode = "+44" }
                    Button("+1 (US)") { countryCode = "+1" }
                    Button("+234 (NG)") { countryCode = "+234" }
                    Button("+91 (IN)") { countryCode = "+91" }
                } label: {
                    HStack {
                        Text(countryCode)
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Phone number input
                TextField("7911 123456", text: $phoneNumber)
                    .font(.system(size: 18))
                    .keyboardType(.phonePad)
                    .padding()
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 32)
            
            // Format hint
            Text("Format: \(formattedPhoneNumber)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.top, 8)
            
            Spacer()
            
            // Error message
            if let errorMessage = authState.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
            
            // Next button
            Button(action: {
                // Set the formatted phone number in auth state
                authState.phoneNumber = formattedPhoneNumber
                Task {
                    await authState.sendOTP()
                }
            }) {
                HStack {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                    
                    if authState.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.leading, 8)
                    }
                }
                .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isValidPhoneNumber ? Color(red: 0.2, green: 0.25, blue: 0.3) : Color.gray.opacity(0.3))
                    .cornerRadius(28)
            }
            .disabled(!isValidPhoneNumber || authState.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
    }
}

#Preview {
    PhoneEntryView()
        .environmentObject(AuthenticationState())
}
