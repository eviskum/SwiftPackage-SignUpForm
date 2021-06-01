//
//  SignUpModel.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI

enum UsernameValidationType {
    case standard(((String) -> Bool)? = nil)
    case email(((String) -> Bool)? = nil)
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
