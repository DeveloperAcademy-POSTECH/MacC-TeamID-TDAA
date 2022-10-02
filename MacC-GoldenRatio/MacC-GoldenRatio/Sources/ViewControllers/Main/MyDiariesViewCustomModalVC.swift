//
//  CustomMenuModalViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/01.
//

import SnapKit
import UIKit

protocol MyDiariesViewCustomModalDelegate: class {
	func tapGestureHandler()
	func createDiaryButtonTapped()
	func joinDiaryButtonTapped()
}

class MyDiariesViewCustomModalVC: UIViewController {
	
	weak var delegate: MyDiariesViewCustomModalDelegate?
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.backgroundColor = .systemBackground
		stackView.layer.cornerRadius = 20
		return stackView
	}()
	
	private var createDiaryButton: UIButton = {
		let button = UIButton()
		button.setTitle("다이어리 생성", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(createDiaryButtonTapped), for: .touchUpInside)
		
		button.snp.makeConstraints {
			$0.height.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewButtonHeight)
		}
		
		return button
	}()
	
	private var joinDiaryButton: UIButton = {
		let button = UIButton()
		button.setTitle("초대코드로 참가", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(joinDiaryButtonTapped), for: .touchUpInside)
		
		button.snp.makeConstraints {
			$0.height.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewButtonHeight)
		}
		
		return button
	}()
	
	static func instance() -> MyDiariesViewCustomModalVC {
		let customMenuModalVC = MyDiariesViewCustomModalVC(nibName: nil, bundle: nil)
		customMenuModalVC.modalPresentationStyle = .overFullScreen
		return customMenuModalVC
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		setupSubView()
	}
	
	private func setup() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
		self.view.addGestureRecognizer(tapGesture)
	}
	
	private func setupSubView() {
		view.backgroundColor = .clear
		
		view.addSubview(stackView)
		stackView.addArrangedSubview(createDiaryButton)
		stackView.addArrangedSubview(joinDiaryButton)
		
		stackView.snp.makeConstraints {
			$0.width.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewStackWidth)
			$0.height.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewStackHeight)
			$0.bottom.equalToSuperview().inset(UIScreen.getDevice().MyDiariesViewCustomModalViewStackBottomPadding)
			$0.trailing.equalToSuperview().inset(UIScreen.getDevice().MyDiariesViewCustomModalViewStackTrailingPadding)
		}
	}
	
	// TODO: Cali 작업 완료 시 View 연결 로직 구현 예정
	@objc private func createDiaryButtonTapped() {
		print("create")
		
		delegate?.createDiaryButtonTapped()
		dismiss(animated: true, completion: nil)
	}
	
	// TODO: Cali 작업 완료 시 View 연결 로직 구현 예정
	@objc private func joinDiaryButtonTapped() {
		let joinDiaryAlert = UIAlertController(title: "초대코드 입력", message: "받은 초대코드를 입력해주세요.", preferredStyle: .alert)
		let joinAction = UIAlertAction(title: "확인", style: .default) { action in
			if let textField = joinDiaryAlert.textFields?.first {
				// TODO: 초대 코드 복사 로직 추가 예정
				print(textField.text)
				self.delegate?.tapGestureHandler()
				self.dismiss(animated: true, completion: nil)
			}
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
			self.delegate?.tapGestureHandler()
			self.dismiss(animated: true, completion: nil)
		}
		joinDiaryAlert.addTextField()
		joinDiaryAlert.addAction(joinAction)
		joinDiaryAlert.addAction(cancelAction)
		self.present(joinDiaryAlert, animated: true)	}
	
	@objc private func tapGestureHandler() {
		delegate?.tapGestureHandler()
		dismiss(animated: true, completion: nil)
	}
}
