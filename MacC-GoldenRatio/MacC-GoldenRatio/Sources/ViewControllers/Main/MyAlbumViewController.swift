//
//  MyAlbumsViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import SnapKit
import UIKit

class MyAlbumViewController: UIViewController {
	private var cancelBag = Set<AnyCancellable>()
	private let viewModel = MyAlbumViewModel()
	private let myDevice = UIScreen.getDevice()
	
	private var selectedAlbum = 0
	private var selectedPhoto = 0
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "앨범"
		label.font = myDevice.TabBarTitleFont
		label.textColor = UIColor.buttonColor
		
		return label
	}()
	
	private lazy var titleCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.frame = CGRect(x: self.view.center.x, y: 0, width: self.view.bounds.width, height: 25)

		collectionView.delegate = self
		collectionView.dataSource = self

		collectionView.backgroundColor = UIColor.clear
		
		collectionView.register(MyAlbumTitleCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumTitleCollectionViewCell")

		return collectionView
	}()
	
	private lazy var albumCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		collectionView.delegate = self
		collectionView.dataSource = self

		collectionView.backgroundColor = UIColor.clear
		
		collectionView.register(MyAlbumCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumCollectionViewCell")

		return collectionView
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		setupSubView()
		setupViewModel()
    }
	
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		viewModel.fetchLoadData()
//		setupViewModel()
//	}
	
	private func setup() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
	}
	
	private func setupSubView() {
		[titleLabel, titleCollectionView, albumCollectionView].forEach { view.addSubview($0) }
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview().inset(myDevice.TabBarTitleLabelTop+50)
			$0.leading.equalToSuperview().inset(myDevice.TabBarTitleLabelLeading)
		}
		titleCollectionView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(myDevice.TabBarTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview().inset(630)
		}
		albumCollectionView.snp.makeConstraints {
			$0.top.equalTo(titleCollectionView.snp.bottom).offset(30)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	private func isIndicator() {
		if viewModel.isInitializing {
			self.view.isUserInteractionEnabled = false
		} else {
			self.view.isUserInteractionEnabled = true
		}
	}
}

extension MyAlbumViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == albumCollectionView {
			if viewModel.albumDatas.isEmpty {
				if !viewModel.isInitializing {
					let label = UILabel()
					label.text = "추가하신 다이어리가 없어요."
					label.font = myDevice.collectionBackgoundViewFont
					label.textColor = UIColor.buttonColor
					label.textAlignment = .center
					collectionView.backgroundView = label
				} else {
					collectionView.backgroundView = nil
				}
			} else {
				if !viewModel.isInitializing && viewModel.albumDatas[selectedAlbum].images?.count == 0 {
					let label = UILabel()
					label.text = "추가하신 사진이 없어요."
					label.font = myDevice.collectionBackgoundViewFont
					label.textColor = UIColor.buttonColor
					label.textAlignment = .center
					collectionView.backgroundView = label
				} else {
					collectionView.backgroundView = nil
				}
			}
		}
		
		return collectionView == titleCollectionView ? viewModel.albumDatas.count : viewModel.albumDatas.isEmpty ? 0 : viewModel.albumDatas[selectedAlbum].imageURLs?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == titleCollectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumTitleCollectionViewCell", for: indexPath) as? MyAlbumTitleCollectionViewCell {
			if indexPath.row == 0 {
				cell.isFirstCell = true
			} else {
				cell.isFirstCell = false
			}
			cell.setup(title: viewModel.albumDatas[indexPath.item].diaryName)
			return cell
		} else if collectionView == albumCollectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumCollectionViewCell", for: indexPath) as? MyAlbumCollectionViewCell {
			cell.setup(image: viewModel.albumDatas[selectedAlbum].images?[indexPath.item] ?? UIImage())
			return cell
		}
		
		return UICollectionViewCell()
	}
}

extension MyAlbumViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == titleCollectionView {
			self.titleCollectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.isSelected = false
			selectedAlbum = indexPath.item
			albumCollectionView.reloadData()
		} else if collectionView == albumCollectionView {
			selectedPhoto = indexPath.item
			let vc = MyAlbumPhotoViewController(photoPage: selectedPhoto, totalCount: viewModel.albumDatas[selectedAlbum].images?.count ?? 0, albumData: viewModel.albumDatas[selectedAlbum])
			vc.modalPresentationStyle = .fullScreen
			self.present(vc, animated: true)
		}
	}
}

extension MyAlbumViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var width = 0
		if !viewModel.albumDatas.isEmpty && viewModel.albumDatas.count > indexPath.item {
			width = viewModel.albumDatas[indexPath.item].diaryName.count
		}
		return collectionView == titleCollectionView ? CGSize(width: width*20, height: 50) : CGSize(width: 110, height: 110)
	}
}

private extension MyAlbumViewController {
	func setupViewModel() {
		viewModel.$albumDatas
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				self?.titleCollectionView.reloadData()
				self?.albumCollectionView.reloadData()
				self?.isIndicator()
			}
			.store(in: &cancelBag)
	}
}
