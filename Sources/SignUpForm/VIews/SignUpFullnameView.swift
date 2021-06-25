//
//  SignUpView.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI

public struct SignUpFullnameView: View {
    @StateObject var signUpViewModel = SignUpFullnameViewModel()
    private var completion: (String, String, String) -> Void
    private var usernameValidationType: UsernameValidationType?
    private var prefillFullname: String
    private var prefillUsername: String

    public init(usernameValidationType: UsernameValidationType? = nil,
                prefillFullname: String = "",
                prefillUsername: String = "",
                completion: @escaping (String, String, String) -> Void) {
        self.completion = completion
        self.usernameValidationType = usernameValidationType
        self.prefillFullname = prefillFullname
        self.prefillUsername = prefillUsername
    }
    
    public var body: some View {
        VStack {
            Form {
                Section(header: Text("FULL NAME"),
                        footer: Text(signUpViewModel.inlineErrorForFullname)
                            .foregroundColor(
                                signUpViewModel.isFullnameValid ? .primary : .red)
                ) {
                    TextField(signUpViewModel.fullnameFieldText,
                              text: $signUpViewModel.fullname
                    )
                    .autocapitalization(.words)
                }

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
                signUpViewModel.completion(signUpViewModel.fullname, signUpViewModel.username, signUpViewModel.password)
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
                                    fullname: prefillFullname, username: prefillUsername,
                                    completion: completion)
        })
    }
}

struct SignUpFullnameView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpFullnameView(completion: { fullname, username, password in
            print("Fullname: \(fullname), Username: \(username) Password: \(password)")
        })
    }
}
