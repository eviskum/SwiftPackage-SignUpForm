//
//  SignInViewModel.swift
//  
//
//  Created by Esben Viskum on 23/06/2021.
//

import SwiftUI
import Combine


class SignInViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    
    @Published var usernameFieldText = "User ID"
    
    fileprivate var usernameValidationType: UsernameValidationType
    
    @Published var inlineErrorForUsername = ""
    @Published var inlineErrorForPassword = ""
    
    @Published var isUsernameValid = false
    @Published var isPasswordValid = false
    @Published var isValid = false

        
    fileprivate var cancellables = Set<AnyCancellable>()
    
    private static let emailRegEx = "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    private static let predicateEmail = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
    
    
    fileprivate var isUsernameValidPublisher: AnyPublisher<UsernameStatus, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {usr in
                if usr.isEmpty { return UsernameStatus.empty }
                if usr.count <= 3 { return UsernameStatus.notLongEnough }
                switch self.usernameValidationType {
                case .standard(_):
                    return UsernameStatus.valid
                case .email(_):
                    if !Self.predicateEmail.evaluate(with: usr) { return UsernameStatus.notValidEmail }
                    return UsernameStatus.valid
                }
            }
            .eraseToAnyPublisher()
    }

    fileprivate var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                if $0.isEmpty { return PasswordStatus.empty }
                return PasswordStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValidPublisher, isUsernameValidPublisher)
            .map {
                let validUsername: Bool = $1 == .valid || $1 == .validAndUnique
                return $0 == .valid && validUsername
            }
            .eraseToAnyPublisher()
    }

    func setError(usernameError: String? = nil, passwordError: String? = nil) {
        if let usernameError = usernameError {
            self.inlineErrorForUsername = usernameError
        }
        if let passwordError = passwordError {
            self.inlineErrorForPassword = passwordError
        }
    }

    func setInit(usernameValidationType: UsernameValidationType? = nil,
                 username: String = "") {
    
        if let usernameValidationType = usernameValidationType {
            self.usernameValidationType = usernameValidationType
        } else {
            self.usernameValidationType = .standard(nil)
        }
                
        if username.count > 0 { self.username = username }

        switch  usernameValidationType {
        case .standard(_):
            usernameFieldText = "Username"
        case .email(_):
            usernameFieldText = "name@domain.abc"
        case .none:
            usernameFieldText = "Username"
        }
    }
    
    init() {
        self.usernameValidationType = .standard(nil)
        
        switch  usernameValidationType {
        case .standard(_):
            usernameFieldText = "User ID"
        case .email(_):
            usernameFieldText = "name@domain.abc"
        }

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

    
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }

}
