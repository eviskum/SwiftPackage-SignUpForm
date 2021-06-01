//
//  SignUpViewModel.swift
//  SignUpForm-Master
//
//  Created by Esben Viskum on 31/05/2021.
//

import SwiftUI
import Combine

final class SignUpViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var usernameFieldText = "Username"
    
    var usernameValidationType: UsernameValidationType
    
    @Published var inlineErrorForUsername = ""
    @Published var inlineErrorForPassword = ""
    
    @Published var isUsernameValid = false
    @Published var isPasswordValid = false
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private static let predicateStandardPassword = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{8,}$")
    private static let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    private static let predicateEmail = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
    
    
    private var isUsernameValidPublisher: AnyPublisher<UsernameStatus, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {usr in
                if usr.isEmpty { return UsernameStatus.empty }
                if usr.count <= 3 { return UsernameStatus.notLongEnough }
                switch self.usernameValidationType {
                case .standard(let checkUnique):
                    if let checkUnique = checkUnique {
                        if checkUnique(usr) {
                            return UsernameStatus.validAndUnique
                        } else {
                            return UsernameStatus.notUniqueUsername
                        }
                    }
                    return UsernameStatus.valid
                case .email(let checkUnique):
                    if !Self.predicateEmail.evaluate(with: usr) { return UsernameStatus.notValidEmail }
                    if let checkUnique = checkUnique {
                        if checkUnique(usr) {
                            return UsernameStatus.validAndUnique
                        } else {
                            return UsernameStatus.notUniqueUsername
                        }
                    }
                    return UsernameStatus.valid
                }
            }
            .eraseToAnyPublisher()
    }

    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                $0.isEmpty
            }
            .eraseToAnyPublisher()
    }

    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map {
                $0 == $1
            }
            .eraseToAnyPublisher()
    }

    private var isPasswordsStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                Self.predicateStandardPassword.evaluate(with: $0)
            }
            .eraseToAnyPublisher()
    }


    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordsStrongPublisher, arePasswordsEqualPublisher)
            .map {
                if $0 { return PasswordStatus.empty }
                if !$1 { return PasswordStatus.notStrongEnough }
                if !$2 { return PasswordStatus.repeatedPasswordWrong }
                return PasswordStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValidPublisher, isUsernameValidPublisher)
            .map {
                $0 == .valid && $1 == .valid
            }
            .eraseToAnyPublisher()
    }
    
    init(usernameValidationType: UsernameValidationType? = nil) {
        if let usernameValidationType = usernameValidationType {
            self.usernameValidationType = usernameValidationType
        } else {
            self.usernameValidationType = .standard(nil)
        }
        
        switch  usernameValidationType {
        case .standard(_):
            usernameFieldText = "Username"
        case .email(_):
            usernameFieldText = "name@domain.abc"
        case .none:
            usernameFieldText = "Username"
        }

        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)

        isUsernameValidPublisher
            .receive(on: RunLoop.main)
            .map { usernameStatus in
                if usernameStatus == .valid || usernameStatus == .validAndUnique { return true }
                return false
            }
            .assign(to: \.isUsernameValid, on: self)
            .store(in: &cancellables)

        isPasswordValidPublisher
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                if passwordStatus == .valid { return true }
                return false
            }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty"
                case .notStrongEnough:
                    return "Password is too weak"
                case .repeatedPasswordWrong:
                    return "Passwords do not match"
                case .valid:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cancellables)

        isUsernameValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { usernameStatus in
                switch usernameStatus {
                case .empty:
                    return "Username cannot be empty"
                case .notLongEnough:
                    return "Username is too short"
                case .notValidEmail:
                    return "Username is not a valid email address"
                case .notUniqueUsername:
                    return "Username is not available"
                case .validAndUnique:
                    return "Username is available"
                case .valid:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForUsername, on: self)
            .store(in: &cancellables)
    }

}
