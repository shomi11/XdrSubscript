//
//  LoginView.swift
//  XdrSubscript
//
//  Created by Malovic, Milos on 18.11.22..
//

import SwiftUI
import AuthenticationServices
import GoogleSignInSwift
import GoogleSignIn
import FirebaseAuth
import Firebase
import CryptoKit

struct AuthView: View {
    
    @Environment(\.colorScheme) var scheme
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var currentNonce: String?
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var showLoader: Bool = false
    @State private var showSignInAlert: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 32) {
                Text("Track your subscription's")
                    .font(.title)
                    .fontWeight(.heavy)
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $email)
                        Divider()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Password", text: $password)
                        Divider()
                    }
                }
                .textFieldStyle(.plain)
                
                Button {
                    handleRegularAccountCreate()
                } label: {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                
                HStack(alignment: .bottom, spacing: 6) {
                    Text("Already have an account?")
                        .foregroundColor(.secondary)
                    Button {
                        showSignInAlert = true
                    } label: {
                        Text("Sign In")
                            .fontWeight(.medium)
                    }
                }
                
                HStack(alignment: .center, spacing: 8) {
                    Rectangle()
                        .frame(height: 1, alignment: .center)
                        .foregroundColor(.gray)
                    Text("OR")
                        .fontWeight(.medium)
                    Rectangle()
                        .frame(height: 1, alignment: .center)
                        .foregroundColor(.gray)
                }
                
                SignInWithAppleButton { appleIdRequest in
                    handleSignInWithAplleRequest(appleIdRequest)
                } onCompletion: { result in
                    signInWithAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(scheme == .light ? .whiteOutline : .black)
                .frame(minHeight: 44, maxHeight: 44)
               
                
                GoogleSignInButton(viewModel: .init(scheme: scheme == .dark ? .dark : .light, style: .wide, state: .normal)) {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                    guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
                    GIDSignIn.sharedInstance.signIn(with: GIDConfiguration(clientID: "813406690578-eaofqd8ed5i5foggnt19ovck5ljecuv9.apps.googleusercontent.com"), presenting: rootViewController, hint: nil, additionalScopes: nil) { user, error in
                        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
                        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                        showLoader = true
                        Auth.auth().signIn(with: credential) { result, err in
                            showLoader = false
                            guard err == nil else {
                                errorMessage = err!.localizedDescription
                                showAlert = true
                                return
                            }
                            switch result {
                            case .some(let authData):
                                print("auth data \(authData.user.providerID)")
                            case .none:
                                return
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            if showLoader {
                SpinnerView()
            }
        }
        .ignoresSafeArea()
        .alert("Sorry Something went wrong", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel, action: {})
        }, message: {
            Text(errorMessage)
        })
        .alert(
            "Enter your credentials",
            isPresented: $showSignInAlert,
            actions: {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Cancel", role: .cancel, action: {})
            Button("Sign In", role: .none, action: {
                handleRegularSignIn()
            })
        })
    }
    
    private func handleRegularSignIn() {
        showLoader = true
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            showLoader = false
            guard error == nil else {
                errorMessage = error!.localizedDescription
                showAlert = true
                return
            }
            switch result {
            case .none:
                errorMessage = "Sign in failed"
                showAlert = true
            case .some(let authData):
                print("auth data \(authData.user.providerID)")
            }
        }
    }
    
    private func handleRegularAccountCreate() {
        
        guard email.isEmpty == false else {
            errorMessage = "Email is empty."
            showAlert = true
            return
        }
        
        guard password.isEmpty == false else {
            errorMessage = "Password is empty."
            showAlert = true
            return
        }
        
        showLoader = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            showLoader = false
            guard error == nil else {
                errorMessage = error!.localizedDescription
                showAlert = true
                return
            }
            switch result {
            case .none:
                errorMessage = "Sign in failed"
                showAlert = true
            case .some(let authData):
                print("auth data \(authData.user.providerID)")
            }
        }
    }
    
    private func handleSignInWithAplleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    private func signInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            errorMessage = failure.localizedDescription
            showAlert = true
        }
        else if case .success(let success) = result {
            if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else { fatalError("invalid state")}
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("coudnt receive apple id token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                
                showLoader = true
                Task {
                    do {
                        let result = try await Auth.auth().signIn(with: credential)
                        showLoader = false
                        if let cred = result.credential {
                            print("auth data \(cred)")
                        }
                    }
                    catch {
                        showLoader = false
                        errorMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

extension AuthView {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
