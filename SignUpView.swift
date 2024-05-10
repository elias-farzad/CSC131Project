//
//  SignUpView.swift
//  MedAuth
//
//  Created by Elias Farzad  on 5/9/24.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var shouldNavigateToVerifyEmail = false // State to trigger navigation

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
                
                Button("Sign Up") {
                    createUser()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(5.0)

                NavigationLink("", destination: VerifyEmailView(), isActive: $shouldNavigateToVerifyEmail) // Invisible NavigationLink

                NavigationLink("Already have an account? Sign In", destination: SignInView())
                    .padding(.top, 50)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sign Up")
        }
    }
    
    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            authResult?.user.sendEmailVerification(completion: { (error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.shouldNavigateToVerifyEmail = true // Trigger navigation on successful email verification trigger
            })
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
