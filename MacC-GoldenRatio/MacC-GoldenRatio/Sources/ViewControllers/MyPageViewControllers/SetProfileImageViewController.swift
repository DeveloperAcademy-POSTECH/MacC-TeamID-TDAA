//
//  setProfileImageViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/14.
//

import Combine
import UIKit

class SetProfileImageViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    private let myDevice = UIScreen.getDevice()
    private let viewModel = MyPageViewModel.shared
    private let imagePicker = UIImagePickerController()
    private var isUserSelectedNewProfileImage: Bool = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkgrayColor
        label.text = "마이페이지"
        label.font = .tabTitleFont
        
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var profileCameraButton: UIButton = {
        let button = UIButton()
        let cameraImage = UIImage(systemName: "camera")
        button.setImage(cameraImage, for: .normal)
        button.tintColor = .buttonColor
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(onTapCameraButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "닉네임"
        label.font = .labelTitleFont
        
        return label
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .labelTtitleFont2
        textField.textColor = .buttonColor
        textField.setUnderLine(width: 1)
        textField.tintColor = .buttonColor
        textField.clearButtonMode = .always
        
        return textField
    }()
    
    private lazy var confirmButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14, weight: .semibold),NSAttributedString.Key.foregroundColor:UIColor.white.cgColor]
        let attributedString = NSAttributedString(string: "확인", attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .endDateColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(onTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapView))
            self.view.addGestureRecognizer(tap)
            self.navigationController?.isNavigationBarHidden = true
            self.view.backgroundColor = .backgroundTexture
            self.profileImageView.layer.cornerRadius = self.myDevice.setProfileProfileImageSize.width * 0.5
            self.profileCameraButton.layer.cornerRadius = self.myDevice.setProfileProfileImageSize.width * 0.25 * 0.5
            self.configureImagePicker()
            self.configureViews()
            self.configureUserData()
        }
    }
    
    private func configureViews() {
        [titleLabel, profileImageView, profileCameraButton, nickNameTitleLabel, nickNameTextField, confirmButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageVerticalPadding2)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(myDevice.setProfileProfileImageSize)
        }
        profileCameraButton.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(profileImageView)
            make.size.equalTo(profileImageView.snp.size).multipliedBy(0.25)
        }
        nickNameTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
            make.top.equalTo(profileImageView.snp.bottom).offset(myDevice.myPageVerticalSpacing3)
        }
        nickNameTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(myDevice.myPageHorizontalPadding)
            make.top.equalTo(nickNameTitleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing)
        }
        confirmButton.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-70)
        }
    }
    
    private func configureUserData() {
        self.profileImageView.image = viewModel.myProfileImage
        self.nickNameTextField.text = viewModel.myUser.userName
    }
    
    private func configureImagePicker() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
    }
    
    @objc private func onTapView() {
        nickNameTextField.resignFirstResponder()
    }
    
    @objc private func onTapCameraButton() {
        imagePicker.modalPresentationStyle = .fullScreen
        
        self.present(self.imagePicker, animated: true)
    }
    
    @objc private func onTapConfirmButton() {
        if viewModel.myUser.userName != nickNameTextField.text {
            viewModel.setNickName(string: nickNameTextField.text ?? "")
            viewModel.setUserData()
        }
        if isUserSelectedNewProfileImage {
            viewModel.setProfileImage(image: profileImageView.image ?? UIImage(), completion: {
                self.viewModel.setUserData()
            })
        }
        self.dismiss(animated: true)
    }
}

// MARK: ImagePikcerDelegate
extension SetProfileImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage? = nil
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        }
        
        self.imagePicker.dismiss(animated: true, completion: {
            self.isUserSelectedNewProfileImage = true
            self.profileImageView.image = selectedImage
        })
    }
}

private extension SetProfileImageViewController {
    func setupViewModel() {
        viewModel.$myUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureUserData()
            }
            .store(in: &cancelBag)
        
        viewModel.$myProfileImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureUserData()
            }
            .store(in: &cancelBag)
    }
}
