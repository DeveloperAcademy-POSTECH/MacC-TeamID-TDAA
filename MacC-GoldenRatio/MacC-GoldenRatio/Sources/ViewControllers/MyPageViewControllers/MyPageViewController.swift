//
//  MyPageViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import FirebaseAuth
import SnapKit
import UIKit
import AuthenticationServices
import CryptoKit

class MyPageViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    private let myDevice = UIScreen.getDevice()
    private let viewModel = MyPageViewModel.shared
    private var currentNonce: String?

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "마이페이지"
		label.font = myDevice.myAlbumPhotoPageLabelFont
		label.textColor = .black
		
		return label
	}()
	
	private lazy var backButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "chevron.left")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.imageEdgeInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
		button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var lineView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(named: "separatorColor") ?? .placeholderText
		
		return view
	}()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "닉네임"
        label.font = .labelSubTitleFont2
        
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "홀리 마운틴"
        label.font = .labelTtitleFont2
        
        return label
    }()
    
    private lazy var profileSettingButton: UIButton = {
        let button = UIButton()

        let title = "프로필 설정"
        let attributes = [NSAttributedString.Key.font:UIFont.labelSubTitleFont2]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: title.count))
        button.setAttributedTitle(mutableAttributedString, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onTapProfileSetting), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var travelsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "가본 여행지"
        label.font = .labelSubTitleFont2

        return label
    }()
    
    private lazy var travelsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.register(TravelsCollectionViewCell.self, forCellWithReuseIdentifier: TravelsCollectionViewCell.identifier)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: MenuTableViewCell.identifier)
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
			self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
			self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.view.backgroundColor = .backgroundTexture
            self.setupViewModel()
            self.configureViews()
            self.configureNickName()
            self.configureProfileImage()
            self.configureTravelLocations()
            self.profileImageView.layer.cornerRadius = self.myDevice.myPageProfileImageSize.width * 0.5
        }
    }
	
    private func configureViews() {
        [titleLabel, profileImageView, nickNameTitleLabel, nickNameLabel, profileSettingButton, travelsTitleLabel, travelsCollectionView, menuTableView, backButton, lineView].forEach{
            view.addSubview($0)
        }
        
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(11)
			$0.centerX.equalToSuperview()
		}
		
		backButton.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(11)
			$0.leading.equalToSuperview().offset(9)
		}
		
		lineView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(9)
			$0.width.equalTo(view.bounds.width)
			$0.height.equalTo(1)
			$0.centerX.equalToSuperview()
		}
		
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(myDevice.myPageVerticalSpacing4)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
            make.size.equalTo(myDevice.myPageProfileImageSize)
        }
        nickNameTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(profileImageView.snp.top)
            make.bottom.equalTo(profileImageView.snp.centerY)
        }
        nickNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(profileImageView.snp.centerY)
            make.bottom.equalTo(profileImageView.snp.bottom)
        }
        profileSettingButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)

        }
        travelsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileSettingButton.snp.bottom).offset(myDevice.myPageVerticalSpacing3)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
        }
        travelsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(travelsTitleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing2)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(myDevice.myPageHorizontalPadding)
            make.bottom.equalTo(menuTableView.snp.top).offset(-myDevice.myPageVerticalSpacing2)
        }
        menuTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(myDevice.myPageMenuTableViewHeight)
        }
    }
    
    private func configureNickName() {
        self.nickNameLabel.text = self.viewModel.myUser.userName
    }
    
    private func configureTravelLocations() {
        self.travelsCollectionView.reloadData()
    }
    
    private func configureProfileImage() {
        self.profileImageView.image = self.viewModel.myProfileImage
    }
    
    @objc private func onTapProfileSetting() {
        let viewController = SetProfileImageViewController()
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
	
	@objc private func backButtonTapped() {
		self.navigationController?.popViewController(animated: true)
	}
    
    private func onTapRateApp() {
        guard let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id6443840961?ls=1&mt=8&action=write-review") else { return }
        if UIApplication.shared.canOpenURL(reviewURL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
    
    private func onTapLogOutButtonTapped() {
        let ac = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in
            self.authLogout()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func onTapWithdrawalButtonTapped() {
        let ac = UIAlertController(title: "회원탈퇴 하시겠습니까?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .destructive) { _ in
            self.authWithdrawal()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func authLogout() {
        let firebaseAuth = Auth.auth()
        
        do{
            try firebaseAuth.signOut()
            print("Sign Out completed with Apple ID")
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("ERROR: signOut \(signOutError.localizedDescription)")
        }
    }
    
    private func authWithdrawal() {
        self.startSignInWithAppleFlow()

    }
    
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.myTravelLocations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelsCollectionViewCell.identifier, for: indexPath) as? TravelsCollectionViewCell else {
            return UICollectionViewCell()
        }
        guard let image = UIImage(named: "stamp") else { return UICollectionViewCell() }
        let travelLocation = viewModel.myTravelLocations[indexPath.item]
        cell.setUI(image: image, location: travelLocation)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 50) / 6
        let height = width
        return CGSize(width: width, height: height)
    }
    
}

extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableViewCell.identifier, for: indexPath) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        let menuTitle = viewModel.menuArray[indexPath.item]
        
        cell.setUI(title: menuTitle.0, subTitle: menuTitle.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.menuArray[indexPath.item].0 {
        case "오픈소스":
            let viewController = LicenseViewController()
            self.present(viewController, animated: true)
            break
        case "앱 평가하기":
            self.onTapRateApp()
            break
        case "로그아웃":
            self.onTapLogOutButtonTapped()
            break
        case "회원탈퇴":
            self.onTapWithdrawalButtonTapped()
            break
        default: break
        }
    }
}

private extension MyPageViewController {
    func setupViewModel() {
        viewModel.$myUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureNickName()
            }
            .store(in: &cancelBag)
        
        viewModel.$myTravelLocations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureTravelLocations()
            }
            .store(in: &cancelBag)
        
        viewModel.$myProfileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureProfileImage()
            }
            .store(in: &cancelBag)
    }
}

// MARK: - Extensions
extension MyPageViewController: ASAuthorizationControllerDelegate {
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
        
        let user = Auth.auth().currentUser

        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

        user?.reauthenticate(with: credential) { auth, error  in
            if let error = error {
                print(error)
            }else{
                self.viewModel.deleteUserDB()
                user?.delete { error in
                    if let withdrawalError = error {
                        print("ERROR: withdrawal \(withdrawalError.localizedDescription)")
                    } else {
                        print("Withdrawal completed with Apple ID")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
}
}

extension MyPageViewController {
// 애플에 인증 값을 요청할 때 리퀘스트를 생성해서 전달 (Nonce를 포함시켜서 Relay 공격 방지, Firebase 무결성 보장)
private func startSignInWithAppleFlow() {
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

extension MyPageViewController : ASAuthorizationControllerPresentationContextProviding {
func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
}
}

extension MyPageViewController: UIGestureRecognizerDelegate {
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		return navigationController?.viewControllers.count ?? 0 > 2
	}
}
