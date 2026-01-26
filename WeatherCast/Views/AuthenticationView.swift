//
//  AuthenticationView.swift
//  WeatherCast
//
//  Created by kuldeep Singh on 18/01/26.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var showSignupSuccess = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.68, green: 0.85, blue: 0.95), Color(red: 0.75, green: 0.88, blue: 0.98)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    Text("Weather App")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(white: 0.3))
                }
                
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Full Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                            .textContentType(.name)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    if !isSignUp {
                        HStack {
                            Spacer()
                            Button(action: {
                                Task {
                                    if !email.isEmpty {
                                        await authManager.resetPassword(email: email)
                                    } else {
                                        authManager.errorMessage = "Enter your email first."
                                    }
                                }
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, -8)
                    }
                    
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(error.contains("sent") ? .green : .red)
                    }
                    
                    Button(action: {
                        Task {
                            isLoading = true
                            authManager.errorMessage = nil
                            
                            if isSignUp {
                                await authManager.signUp(email: email, password: password, name: name)
                                if authManager.errorMessage == nil {
                                    showSignupSuccess = true
                                }
                            } else {
                                await authManager.signIn(email: email, password: password)
                            }
                            isLoading = false
                        }
                    }) {
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isSignUp ? "Sign Up" : "Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    
                    Button(action: {
                        withAnimation {
                            isSignUp.toggle()
                            authManager.errorMessage = nil
                        }
                    }) {
                        Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.4))
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .alert("Signup Successful", isPresented: $showSignupSuccess) {
            Button("Login Now") {
                withAnimation {
                    isSignUp = false
                }
            }
        } message: {
            Text("Your account has been created. Please sign in to continue.")
        }
    }
}
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
    }
}


#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
}
