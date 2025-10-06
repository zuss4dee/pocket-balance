//
//  OTPVerificationView.swift
//  Pocket Balance
//
//  Created by Damilare Adeosun on 05/10/2025.
//

import SwiftUI

struct OTPVerificationView: View {
    @EnvironmentObject var authState: AuthenticationState
    @State private var otpDigits: [String] = ["", "", "", "", "", ""]
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
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
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
                .frame(height: 40)
            
            // Title
            Text("Verify mobile number")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            Spacer()
                .frame(height: 16)
            
            // Subtitle
            Text("Ding! We've sent a text message to:")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            // Phone number display
            Text(authState.phoneNumber)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.top, 8)
            
            Spacer()
                .frame(height: 40)
            
            // OTP Input boxes
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPDigitField(
                        text: $otpDigits[index],
                        index: index,
                        focusedField: $focusedField
                    )
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 32)
            
            // Resend code button
            Button(action: {
                print("Resend OTP code")
            }) {
                Text("Resend code")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            // Error message
            if let errorMessage = authState.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Verify button
            Button(action: {
                let code = otpDigits.joined()
                authState.verificationCode = code
                Task {
                    await authState.verifyOTP()
                }
            }) {
                HStack {
                    Text("Verify")
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
                    .background(isOTPComplete ? Color(red: 0.2, green: 0.25, blue: 0.3) : Color.gray.opacity(0.3))
                    .cornerRadius(28)
            }
            .disabled(!isOTPComplete || authState.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .background(Color.white)
        .onAppear {
            focusedField = 0
        }
    }
    
    private var isOTPComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }
}

struct OTPDigitField: View {
    @Binding var text: String
    let index: Int
    @FocusState.Binding var focusedField: Int?
    
    var body: some View {
        TextField("", text: $text)
            .font(.system(size: 24, weight: .medium))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .frame(width: 50, height: 56)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .focused($focusedField, equals: index)
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
                
                if !newValue.isEmpty && index < 5 {
                    focusedField = index + 1
                }
            }
    }
}

#Preview {
    OTPVerificationView()
        .environmentObject(AuthenticationState())
}
