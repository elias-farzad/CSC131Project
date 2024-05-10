//
//  SignInView.swift
//  MedAuth
//
//  Created by Elias Farzad  on 5/9/24.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isUserAuthenticated = false  // State to manage navigation to ContentView
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Sign In") {
                    signInUser()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(5.0)
                
                NavigationLink("", destination: ContentView(), isActive: $isUserAuthenticated)  // Invisible NavigationLink
                
                NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                    .padding(.top, 50)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }

    private func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            // Check if email is verified
            if Auth.auth().currentUser?.isEmailVerified ?? false {
                self.isUserAuthenticated = true  // Trigger navigation on success
            } else {
                self.errorMessage = "Please verify your email before signing in."
            }
        }
    }
}

// Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

