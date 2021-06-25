//
//  SignUpModel.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI

public enum UsernameValidationType {
    case standard(((String) -> Bool)? = nil)
    case email(((String) -> Bool)? = nil)
}

public enum ResetPwdStatus {
    case usernameNotExists
    case unableToReset
    case success
}

public enum SignInStatus {
    case usernameNotExists
    case passwordWrong
    case unableToSignIn
    case success
}

enum FullnameStatus {
    case empty
    case notLongEnough
    case valid
}

enum UsernameStatus {
    case empty
    case notLongEnough
    case notValidEmail
    case notUniqueUsername
    case validAndUnique
    case valid
}

enum PasswordStatus {
    case empty
    case notStrongEnough
    case repeatedPasswordWrong
    case valid
}
