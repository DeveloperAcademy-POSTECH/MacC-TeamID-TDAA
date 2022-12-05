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
    private let viewModel = MyPageViewModel.shared
    private let imagePicker = UIImagePickerController()
    private var isUserSelectedNewProfileImage: Bool = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.text = "LzUserTitle".localized
        label.font = .title1
        
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
        button.tintColor = .white
        button.backgroundColor = .beige600
        button.addTarget(self, action: #selector(onTapCameraButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "LzUserNickName".localized
        label.font = .title4
        
        return label
    }()
    
    private lazy var nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.font = .body
        textField.textColor = .gray400
        textField.setUnderLine(width: 1)
        textField.tintColor = .gray400
        textField.clearButtonMode = .always
        textField.placeholder = "LzUserNickNameMessage".localized
        
        return textField
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .beige600
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(onTapConfirmButton), for: .touchUpInside)
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14, weight: .semibold),NSAttributedString.Key.foregroundColor:UIColor.white.cgColor]
        let attributedString = NSAttributedString(string: "LzConfirm".localized, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)

        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.beige600.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(onTapCancelButton), for: .touchUpInside)
        let attributes = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14, weight: .semibold),NSAttributedString.Key.foregroundColor:UIColor.beige600.cgColor]
        let attributedString = NSAttributedString(string: "LzCancel".localized, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapView))
            self.view.addGestureRecognizer(tap)
            self.navigationController?.isNavigationBarHidden = true
            self.view.backgroundColor = UIColor.beige100
            self.profileImageView.layer.cornerRadius = Layout.setProfileProfileImageSize.width * 0.5
            self.profileCameraButton.layer.cornerRadius = Layout.setProfileProfileImageSize.width * 0.28 * 0.5
            self.configureImagePicker()
            self.configureViews()
            self.configureUserData()
        }
    }
    
    private func configureViews() {
        [titleLabel, profileImageView, profileCameraButton, nickNameTitleLabel, nickNameTextField, confirmButton, cancelButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Layout.myPageVerticalPadding2)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Layout.myPageHorizontalPadding)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Layout.myPageVerticalSpacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(Layout.setProfileProfileImageSize)
        }
        profileCameraButton.snp.makeConstraints { make in
            make.trailing.equalTo(profileImageView)
            make.bottom.equalTo(profileImageView).multipliedBy(0.94)
            make.size.equalTo(profileImageView.snp.size).multipliedBy(0.28)
        }
        nickNameTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Layout.myPageHorizontalPadding)
            make.top.equalTo(profileImageView.snp.bottom).offset(Layout.myPageVerticalSpacing3)
        }
        nickNameTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.myPageHorizontalPadding)
            make.top.equalTo(nickNameTitleLabel.snp.bottom).offset(Layout.myPageVerticalSpacing)
        }
        confirmButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.myPageHorizontalPadding2)
            make.height.equalTo(Layout.myPageButtonHeight)
            make.bottom.equalTo(cancelButton.snp.top).offset(-Layout.myPageVerticalSpacing)
        }
        cancelButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Layout.myPageHorizontalPadding2)
            make.height.equalTo(Layout.myPageButtonHeight)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Layout.myPageVerticalSpacing4)
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
    
    @objc private func onTapCancelButton() {
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
