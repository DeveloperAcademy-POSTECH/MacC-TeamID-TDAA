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
	}
}
