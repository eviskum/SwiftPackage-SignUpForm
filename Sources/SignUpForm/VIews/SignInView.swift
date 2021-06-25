//
//  SignInView.swift
//  
//
//  Created by Esben Viskum on 23/06/2021.
//

import SwiftUI

public struct SignInView: View {
    @StateObject var signInViewModel = SignInViewModel()
    private var signInCompletion: (String, String) -> SignInStatus
    private var resetPwdCompletion: ((String) -> ResetPwdStatus)?
    private var usernameValidationType: UsernameValidationType?
    private var prefillUsername: String
    @State private var stateResetPwd: Bool

    public init(usernameValidationType: UsernameValidationType? = nil,
                prefillUsername: String = "",
                resetPwdCompletion: ((String) -> ResetPwdStatus)? = nil,
                signInCompletion: @escaping (String, String) -> SignInStatus) {
        
        self.signInCompletion = signInCompletion
        self.resetPwdCompletion = resetPwdCompletion
        self.usernameValidationType = usernameValidationType
        self.prefillUsername = prefillUsername
        self.stateResetPwd = false
    }
    
    public var body: some View {
        VStack {
            Form {
                Section(header: Text("USER ID"),
                        footer: Text(signInViewModel.inlineErrorForUsername)
                            .foregroundColor(.red)
                ) {
                    TextField(signInViewModel.usernameFieldText,
                              text: $signInViewModel.username
                    )
                    .autocapitalization(.none)
                }
                
                Section(header: Text("PASSWORD"),
                        footer: Text(signInViewModel.inlineErrorForPassword)
                            .foregroundColor(.red)
                ) {
                    SecureField("Password", text: $signInViewModel.password)
                }
                
            }

            if !stateResetPwd && resetPwdCompletion != nil {
                Button(action: {
                    self.stateResetPwd = true
                }, label: {
                    HStack {
                        Spacer()
                        Text("Forgot password?").padding(.trailing)
                    }
                })
            }
            
            if stateResetPwd {
                Text("Send password reset email to:")
                    .padding(.top)
                Text("\(signInViewModel.username)")
            }
            
            Button(action: {
                if stateResetPwd {
                    resetPwd()
                    self.stateResetPwd.toggle()
                } else { signIn() }
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 60)
                    .overlay(
                        Text(stateResetPwd ? "Reset password" : "Continue login")
                            .foregroundColor(.white)
                    )
            })
            .padding()
            .disabled(
                (!signInViewModel.isValid) &&
                    (!(stateResetPwd && signInViewModel.isUsernameValid))
            )
        }
        .onAppear(perform: {
            signInViewModel.setInit(usernameValidationType: usernameValidationType,
                                    username: prefillUsername)
        })
    }
    
    func signIn() {
        let status = signInCompletion(signInViewModel.username, signInViewModel.password)
        switch status {
        case .usernameNotExists:
            signInViewModel.setError(usernameError: "User name does not exist")
        case .passwordWrong:
            signInViewModel.setError(passwordError: "Error: wrong password")
        case .unableToSignIn:
            signInViewModel.setError(usernameError: "Unable to sign in", passwordError: "Unable to sign in")
        case .success:
            break
        }
    }
    
    func resetPwd() {
        let status = resetPwdCompletion!(signInViewModel.username)
        switch status {
        case .usernameNotExists:
            signInViewModel.setError(usernameError: "User name does not exist")
        case .unableToReset:
            signInViewModel.setError(usernameError: "Unable to send reset email", passwordError: "Unable to send reset email")
        case .success:
            signInViewModel.setError(passwordError: "Reset email sent")
            break
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(signInCompletion: { username, password in
            print("Username: \(username) Password: \(password)")
            return SignInStatus.success
        })
    }
}
