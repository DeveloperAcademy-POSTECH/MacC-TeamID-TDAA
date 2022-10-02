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
	
	private var bgView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.layer.cornerRadius = 20
		return view
	}()
	
	private var createDiaryButton: UIButton = {
		let button = UIButton()
		button.frame.size = CGSize(width: 150, height: 50)
		button.layer.cornerRadius = 20
		button.setTitle("다이어리 생성", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(createDiaryButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private var joinDiaryButton: UIButton = {
		let button = UIButton()
		button.frame.size = CGSize(width: 150, height: 50)
		button.layer.cornerRadius = 20
		button.setTitle("초대코드로 참가", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(joinDiaryButtonTapped), for: .touchUpInside)
		return button
	}()
	
	static func instance() -> MyDiariesViewCustomModalVC {
		let customMenuModalVC = MyDiariesViewCustomModalVC(nibName: nil, bundle: nil)
		customMenuModalVC.modalPresentationStyle = .overFullScreen
		return customMenuModalVC
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupSubView()
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
		self.view.addGestureRecognizer(tapGesture)
	}
	
	private func setupSubView() {
		view.backgroundColor = .clear
		view.addSubview(bgView)
		bgView.addSubview(createDiaryButton)
		bgView.addSubview(joinDiaryButton)
		bgView.snp.makeConstraints {
			$0.top.equalToSuperview().inset(view.bounds.height-270)
			$0.bottom.equalToSuperview().inset(170)
			$0.leading.equalToSuperview().inset(220)
			$0.trailing.equalToSuperview().inset(20)
		}
		createDiaryButton.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.bottom.equalToSuperview().inset(50)
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
		}
		joinDiaryButton.snp.makeConstraints {
			$0.top.equalToSuperview().inset(50)
			$0.bottom.equalTo(bgView.snp.bottom)
			$0.leading.equalToSuperview()
			$0.trailing.equalToSuperview()
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
