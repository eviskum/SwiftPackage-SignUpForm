//
//  SignUpSimpleView.swift
//  
//
//  Created by Esben Viskum on 23/06/2021.
//

import SwiftUI

public struct SignUpSimpleView: View {
    @StateObject var signUpViewModel = SignUpSimpleViewModel()
    private var completion: (String, String) -> Void
    private var usernameValidationType: UsernameValidationType?
    private var prefillUsername: String

    public init(usernameValidationType: UsernameValidationType? = nil,
                prefillUsername: String = "",
                completion: @escaping (String, String) -> Void) {
        
        self.completion = completion
        self.usernameValidationType = usernameValidationType
        self.prefillUsername = prefillUsername
    }
    
    public var body: some View {
        VStack {
            Form {
                Section(header: Text("USER ID"),
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
        .onAppear(perform: {
            signUpViewModel.setInit(usernameValidationType: usernameValidationType,
                                    username: prefillUsername,
                                    completion: completion)
        })
    }
}

struct SignUpSimpleView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpSimpleView(completion: { username, password in
            print("Username: \(username) Password: \(password)")
        })
    }
}
