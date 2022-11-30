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

    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    private var currentNonce: String?
    var completion: () -> Void = {}
    
    // MARK: - properties
    
    private lazy var appLogo: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "signInLogo"))
        return imageView
    }()
    
    private lazy var appTitle: UILabel = {
        let label = UILabel()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        var multipleAttributes: [NSAttributedString.Key : Any] = [:]
        multipleAttributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        multipleAttributes[NSAttributedString.Key.foregroundColor] = UIColor(named: "sandbrownColor")
        multipleAttributes[NSAttributedString.Key.font] = UIFont(name: "EF_Diary", size: 30) ?? UIFont.systemFont(ofSize: 30)
        multipleAttributes[NSAttributedString.Key.kern] = 10
        
        let attributedString = NSMutableAttributedString(string: "Travel Diary", attributes: multipleAttributes)
        
        label.attributedText = attributedString
        return label
    }()
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: device.logInButtonImagePointSize),forImageIn: .normal)
        button.setTitle("LzSignInLogin".localized, for: .normal)
        button.titleLabel?.font = device.loginButtonFont
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 4
        return button
    }()
    
    // MARK: - feature methods
    
    @objc private func appleLoginButtonPressed() {
        print("Sign In completed with Apple ID")
        startSignInWithAppleFlow {
            guard let currentUser = Auth.auth().currentUser else { return }
            let uid = currentUser.uid
            let userName = currentUser.displayName ?? ""

            let user = User(userUID: uid, userName: userName, userImageURL: "", diaryUUIDs: [])
            FirestoreClient().setMyUser(myUser: user, completion: nil)
        }
    }
    
    private func showMainView() {
        let signInTestVC = MyHomeViewController()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.pushViewController(signInTestVC, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        DispatchQueue.main.async {
            if let user = Auth.auth().currentUser {
                FirestoreClient().isExistingUser(user.uid) { value in
                    if value {
                        self.showMainView()
                    } else {
                        self.setup()
                    }
                }
            } else {
                self.setup()
            }
        }
    }
    
    private func initialSetup() {
        navigationController?.isNavigationBarHidden = true
        [appLogo, appTitle].forEach {
            view.addSubview($0)
        }
        
        appLogo.snp.makeConstraints {
            $0.width.equalToSuperview().dividedBy(3.9)
            $0.height.equalTo(appLogo.snp.width).multipliedBy(0.8)
            $0.bottom.equalTo(appTitle.snp.top).offset(-70)
            $0.centerX.equalToSuperview()
        }
        
        appTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(70)
        }
    }
    
    private func setup() {
        
        view.addSubview(appleLoginButton)
        
        appLogo.snp.makeConstraints {
            $0.width.equalToSuperview().dividedBy(3.9)
            $0.height.equalTo(appLogo.snp.width).multipliedBy(0.8)
            $0.bottom.equalTo(appTitle.snp.top).offset(-70)
            $0.centerX.equalToSuperview()
        }
        
        appTitle.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.size.equalTo(device.logInButtonSize)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(device.logInButtonBottomInset)
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
                guard let currentUser = Auth.auth().currentUser else { return }
                FirestoreClient().isExistingUser(currentUser.uid,completion: { i in
                    guard i else {
                        let user = User(userUID: currentUser.uid, userName: currentUser.displayName ?? "", userImageURL: "", diaryUUIDs: [])
                        FirestoreClient().setMyUser(myUser: user, completion: {
                            self.showMainView()
                            self.completion()
                        })
                        return
                    }
                    self.showMainView()
                    self.completion()
                })
            }
        }
    }
}

extension SignInViewController {
    // 애플에 인증 값을 요청할 때 리퀘스트를 생성해서 전달 (Nonce를 포함시켜서 Relay 공격 방지, Firebase 무결성 보장)
    private func startSignInWithAppleFlow(completion: () -> Void) {
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
        completion()
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
