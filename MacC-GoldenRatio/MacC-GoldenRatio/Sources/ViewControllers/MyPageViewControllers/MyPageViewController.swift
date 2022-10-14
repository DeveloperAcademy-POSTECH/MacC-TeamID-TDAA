//
//  MyPageViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import SnapKit
import UIKit

class MyPageViewController: UIViewController {
    let myDevice = UIScreen.getDevice()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "마이페이지"
        
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private lazy var nickNameTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "닉네임"
        
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "홀리 마운틴"
        
        return label
    }()
    
    private lazy var profileSettingButton: UIButton = {
        let button = UIButton()
        button.setTitle("프로필 설정", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onTapProfileSetting), for: .touchUpInside)
//        button.titleLabel?.font =
        
        return button
    }()
    
    private lazy var travelsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "가본 여행지"
        
        return label
    }()
    
    private lazy var travelsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.configureViews()
        }
    }
    
    private func configureViews() {
        [titleLabel, profileImageView, nickNameTitleLabel, nickNameLabel, profileSettingButton, travelsTitleLabel, travelsCollectionView, menuTableView].forEach{
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageVerticalPadding)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)
            make.size.equalTo(myDevice.myPageProfileImageSize)
        }
        nickNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(titleLabel).offset(myDevice.myPageVerticalPadding)
        }
        nickNameTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(myDevice.myPageHorizontalSpacing2)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing2)
        }
        profileSettingButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(myDevice.myPageVerticalSpacing)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(myDevice.myPageHorizontalPadding)

        }
        travelsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileSettingButton.snp.bottom).offset(myDevice.myPageVerticalSpacing3)
            make.leading.equalTo(view.safeAreaInsets).offset(myDevice.myPageHorizontalPadding)
        }
        travelsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(travelsTitleLabel.snp.bottom).offset(myDevice.myPageVerticalSpacing2)
            make.horizontalEdges.equalTo(view.safeAreaInsets).offset(myDevice.myPageHorizontalPadding)
        }
        menuTableView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaInsets)
            make.height.equalTo(myDevice.myPageMenuTableViewHeight)
        }
    }
    
    @objc private func onTapProfileSetting() {
        
    }
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ui = UICollectionViewCell()
        ui.backgroundView = UIImageView(image: UIImage(named: "plusButton"))
        return ui
    }
}

extension MyPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "앱 버전"
        
        return cell
    }
}


