//
//  SignUpView.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI

public struct SignUpView: View {
    @ObservedObject var signUpViewModel: SignUpViewModel

    public init(completion: @escaping (String, String) -> Void, usernameValidationType: UsernameValidationType? = nil) {
        self.signUpViewModel = SignUpViewModel(completion: completion, usernameValidationType: usernameValidationType)
    }
    
    public var body: some View {
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
            Button(action: {
                signUpViewModel.completion(signUpViewModel.username, signUpViewModel.password)
            }, label: {
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
        SignUpView(completion: { username, password in
            print("Username: \(username) Password: \(password)")
        })
    }
}
