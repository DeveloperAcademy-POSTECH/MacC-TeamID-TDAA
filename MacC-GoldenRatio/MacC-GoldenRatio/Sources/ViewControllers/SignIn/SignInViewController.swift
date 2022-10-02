//
//  SignInViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/29.
//
import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth
import SnapKit
import UIKit

class SignInViewController: UIViewController {

    private var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        if Auth.auth().currentUser != nil {
            showTestView()
            // showMainView()
        }
        
        setup()
    }
    
    // MARK: - properties
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 21.4),forImageIn: .normal)
        button.setTitle("  Apple로 로그인", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21.4)
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 4
        return button
    }()
    
    // MARK: - feature methods
    
    @objc private func appleLoginButtonPressed() {
        print("Sign In completed with Apple ID")
        startSignInWithAppleFlow()
    }
    
    private func showTestView() {
        let signInTestVC = SignInTestViewController()
        self.navigationController?.pushViewController(signInTestVC, animated: true)
    }
    
    private func showMainView() {
        let signInTestVC = TabBarController()
        self.navigationController?.pushViewController(signInTestVC, animated: true)
    }
    
    // MARK: - setup
    
    private func setup() {
        view.addSubview(appleLoginButton)
        
        appleLoginButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 268, height: 50))
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(80)
        }

    }
    
}

    // MARK: - Extensions
extension SignInViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                self.showTestView()
            }
        }
    }
}

extension SignInViewController {
    // 애플에 인증 값을 요청할 때 리퀘스트를 생성해서 전달 (Nonce를 포함시켜서 Relay 공격 방지, Firebase 무결성 보장)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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
}

extension SignInViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
