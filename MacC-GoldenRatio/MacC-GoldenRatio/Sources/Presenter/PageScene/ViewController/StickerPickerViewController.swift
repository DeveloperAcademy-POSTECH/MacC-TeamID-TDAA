//
//  StickerPickerViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/04.
//

import SnapKit
import UIKit
class StickerPickerViewController: UIViewController {
    var completion: (_ sticker: String) -> Void = { sticker in }
    private let stickerArray: [String] = ["manLong", "manLong2", "womanLong", "womanLong2", "manShort", "womanShort", "neckPillow", "passport", "fork", "knife", "plate", "camera", "broom", "ghost1", "ghost2", "ghost3", "ghost4", "ghost5", "ghost6", "ghost7", "pot", "pumpkin1", "pumpkin2", "pumpkin3", "wizardHat"]
    
    private lazy var xMarkButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "xmark")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapXMarkButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var stickerPickerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.register(StickerPickerCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: StickerPickerCollectionViewCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.view.backgroundColor = .white
            self.stickerPickerCollectionView.dataSource = self
            self.stickerPickerCollectionView.delegate = self
            self.setShadowEffect()
            self.addSubviews()
            self.configureConstraints()
            self.configureButtonSize()
        }
    }
    
    private func setShadowEffect() {
        view.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 5, height: 5) // 반경에 대해서 너무 적용이 되어서 4point 정도 ㅐ림.
        view.layer.shadowRadius = 8 // 반경?
        view.layer.shadowOpacity = 0.5
    }
    
    private func addSubviews() {
        [xMarkButton, stickerPickerCollectionView].forEach{
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        xMarkButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(Layout.stickerPickerPadding)
            make.size.equalTo(Layout.stickerPickerButtonFrameSize)
        }
        
        stickerPickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(xMarkButton.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview().inset(Layout.stickerPickerPadding)
        }
    }
    
    private func configureButtonSize() {
        [xMarkButton].forEach{
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: Layout.stickerPickerButtonPointSize)
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.preferredSymbolConfigurationForImage = imageConfig
                $0.configuration = config
            } else {
                $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
            }
            
        }
    }
    // MARK: Actions
    @objc private func onTapXMarkButton() {
        self.dismiss(animated: true)
    }
}

extension StickerPickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return stickerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerPickerCollectionViewCell.identifier, for: indexPath) as? StickerPickerCollectionViewCell else { return UICollectionViewCell() }
        let imageString = stickerArray[indexPath.item]
        guard let image = UIImage(named: imageString) else { return cell }
        cell.setImage(image)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 20 - 60) / 4
        let cellHeight = (collectionView.frame.height - 60) / 2
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageString = stickerArray[indexPath.item]
        self.completion(imageString)
        self.dismiss(animated: true)
    }
}
