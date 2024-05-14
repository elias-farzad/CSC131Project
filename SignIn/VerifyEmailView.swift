//
//  VerifyEmailView.swift
//  MedAuth
//
//  Created by Elias Farzad  on 5/9/24.
//

import SwiftUI
import FirebaseAuth

struct VerifyEmailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Text("Please check your email to verify your account and then press the button below.")
                .padding()
                .multilineTextAlignment(.center)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button("I have verified") {
                checkEmailVerification()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(5.0)

            Spacer()
        }
        .padding()
        .navigationTitle("Verify Email")
    }

    private func checkEmailVerification() {
        Auth.auth().currentUser?.reload { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            if Auth.auth().currentUser?.isEmailVerified ?? false {
                // Dismiss this view to go back to the sign-in view
                presentationMode.wrappedValue.dismiss()
            } else {
                self.errorMessage = "Your email has not been verified. Please check your email and verify."
            }
        }
    }
}

struct VerifyEmailView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyEmailView()
    }
}
