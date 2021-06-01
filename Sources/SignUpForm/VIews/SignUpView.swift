//
//  SignUpView.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("USERNAME"),
                        footer: Text(signUpViewModel.inlineErrorForUsername)
                            .foregroundColor(
                                signUpViewModel.isUsernameValid ? .primary : .red)
                ) {
                    TextField(signUpViewModel.usernameFieldText,
                              text: $signUpViewModel.username
                    )
                    .autocapitalization(.none)
                }
                
                Section(header: Text("PASSWORD"),
                        footer: Text(signUpViewModel.inlineErrorForPassword)
                            .foregroundColor(
                                signUpViewModel.isPasswordValid ? .primary : .red)
                ) {
                    SecureField("Password", text: $signUpViewModel.password)
                    SecureField("Password again", text: $signUpViewModel.passwordAgain)
                }
            }
            Button(action: {}, label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 60)
                    .overlay(
                        Text("Continue")
                            .foregroundColor(.white)
                    )
            })
            .padding()
            .disabled(!signUpViewModel.isValid)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(signUpViewModel: SignUpViewModel())
    }
}
