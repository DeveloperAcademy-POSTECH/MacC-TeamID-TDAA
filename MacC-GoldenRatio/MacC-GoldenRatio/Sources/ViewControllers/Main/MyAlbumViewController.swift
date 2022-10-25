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
	
	private var isInitializing = false {
		didSet {
			if isInitializing {
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                    LoadingIndicator.showLoading(loadingText: "앨범을 불러오는 중입니다.")
                    self.view.isUserInteractionEnabled = false
                }
			} else {
                DispatchQueue.main.async {
                    LoadingIndicator.hideLoading()
                    self.view.isUserInteractionEnabled = true
                }
			}
		}
	}
	
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
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.backgroundColor = UIColor.clear
		collectionView.register(MyAlbumTitleCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumTitleCollectionViewCell")
		return collectionView
	}()
	
	private lazy var albumCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		isInitializing = true
        viewModel.fetchLoadData(completion: {self.isInitializing = false})
		setupViewModel()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.isInitializing = false
	}
	
	private func setup() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
	}
	
	private func setupSubView() {
		[titleLabel, titleCollectionView, albumCollectionView].forEach { view.addSubview($0) }
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(self.view.safeAreaLayoutGuide).inset(myDevice.TabBarTitleLabelTop)
			$0.leading.equalToSuperview().inset(myDevice.TabBarTitleLabelLeading)
		}
		titleCollectionView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(myDevice.TabBarTitleLabelTop)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview().inset(self.view.bounds.height*0.78)
		}
		albumCollectionView.snp.makeConstraints {
			$0.top.equalTo(titleCollectionView.snp.bottom).offset(30)
			$0.leading.trailing.equalToSuperview().inset(20)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	private func isIndicator() {
		if self.isInitializing {
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
				if !self.isInitializing {
					collectionView.backgroundView = setEmptyView("추가하신 다이어리가 없어요.")
				} else {
					collectionView.backgroundView = nil
				}
			} else {
				if viewModel.albumDatas[selectedAlbum].images?.count == 0 {
					collectionView.backgroundView = setEmptyView("추가하신 사진이 없어요.")
				} else {
					collectionView.backgroundView = nil
				}
			}
		}
		return collectionView == titleCollectionView ? viewModel.albumDatas.count : viewModel.albumDatas.isEmpty ? 0 : viewModel.albumDatas[selectedAlbum].imageURLs?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == titleCollectionView, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumTitleCollectionViewCell", for: indexPath) as? MyAlbumTitleCollectionViewCell {
			cell.setup(title: viewModel.albumDatas[indexPath.item].diaryName, isFirstCell: indexPath.item == selectedAlbum ? true : false)
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
			self.titleCollectionView.cellForItem(at: IndexPath(row: selectedAlbum, section: 0))?.isSelected = false
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
		if collectionView == titleCollectionView {
			var width = 0
			if !viewModel.albumDatas.isEmpty && viewModel.albumDatas.count > indexPath.item {
				width = viewModel.albumDatas[indexPath.item].diaryName.count
			}
			return CGSize(width: width*20, height: 30)
		} else {
			let size = (self.view.bounds.width-60)/3
			return CGSize(width: size, height: size)
		}
	}
}

private extension MyAlbumViewController {
	func setupViewModel() {
		viewModel.$albumDatas
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				self?.titleCollectionView.reloadData()
				self?.albumCollectionView.reloadData()
			}
			.store(in: &cancelBag)
	}
}

private extension MyAlbumViewController {
	func setEmptyView(_ text: String) -> UIView {
		let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
		
		let label = UILabel()
		label.text = text
		label.font = myDevice.collectionBackgoundViewFont
		label.textColor = UIColor.subTextColor
		label.textAlignment = .center
		
		emptyView.addSubview(label)
		label.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.bottom.equalToSuperview().inset(myDevice.myAlbumBackgroundLabelBottom)
		}
		
		return emptyView
	}
}
