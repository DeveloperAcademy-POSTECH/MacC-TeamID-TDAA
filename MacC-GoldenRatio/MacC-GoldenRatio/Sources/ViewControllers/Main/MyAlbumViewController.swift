//
//  MyAlbumsViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class MyAlbumViewController: UIViewController {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	
	private var selectedAlbum = 0
	private var selectedPhoto = 0
	
	private lazy var collectionView = AlbumCollectionView()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		setupSubView()
	}
	
	private func setup() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
	}
	
	private func setupSubView() {
		view.addSubview(collectionView)
		collectionView.snp.makeConstraints {
			$0.edges.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	func bind(viewModel: AlbumCollectionViewModel) {
		collectionView.bind(viewModel)
		collectionView.rx
			.itemSelected
			.subscribe(onNext: { index in
				let vc = MyAlbumPhotoViewController(photoPage: index.item, totalCount: viewModel.collectionCellData.value.count)
				vc.bind(viewModel: viewModel)
				vc.modalPresentationStyle = .fullScreen
				self.present(vc, animated: true)
			})
			.disposed(by: disposeBag)
	}
}
