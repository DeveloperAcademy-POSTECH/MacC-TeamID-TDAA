//
//  MyDiariesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import SnapKit
import UIKit

final class MyDiariesViewController: UIViewController {
	let diary = [Diary(diaryUUID: "", diaryName: "🌊포항항", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [0.0]), diaryStartDate: Date(), diaryEndDate: Date(), diaryPages: [[Page(pageUUID: "", items: [Item(itemUUID: "", itemType: ItemType.text, contents: "", itemSize: [0.0], itemPosition: [0.0], itemAngle: 0.0)])]], userUIDs: [User(userUID: "", userName: "칼리", userImageURL: ""), User(userUID: "", userName: "드록바", userImageURL: ""), User(userUID: "", userName: "해츨링", userImageURL: ""), User(userUID: "", userName: "라우", userImageURL: ""), User(userUID: "", userName: "산", userImageURL: "")])]
	
	private lazy var diaryCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		collectionView.backgroundColor = .systemBackground
		collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		collectionView.register(DiaryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DiaryCollectionHeaderView")
		
		return collectionView
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		view.addSubview(diaryCollectionView)
		diaryCollectionView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
			$0.leading.equalTo(view.safeAreaLayoutGuide)
			$0.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
    }

}

extension MyDiariesViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let label = UILabel()
		label.text = "다이어리를 추가해주세요."
		label.textAlignment = .center
		
		if diary.count == 0 {
			collectionView.backgroundView = label
		}
		
		return diary.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell
		
		var imageViews = [UIImageView]()
		
		for i in 0..<diary[0].userUIDs.count {
			let imageView = UIImageView(image: UIImage(systemName: "person"))
			imageView.contentMode = .scaleToFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = 12.0
			imageView.backgroundColor = .gray
			imageViews.append(imageView)
		}
		
		cell?.setup(title: diary[0].diaryName, imageViews: imageViews)

		cell?.layer.borderWidth = 0.5
		cell?.layer.cornerRadius = 20
		cell?.layer.borderColor = UIColor.gray.cgColor

		return cell ?? UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard kind == UICollectionView.elementKindSectionHeader,
			  let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DiaryCollectionHeaderView", for: indexPath) as? DiaryCollectionHeaderView
		else {
			return UICollectionReusableView()
		}
		
		header.setupViews()
		
		return header
	}
}

extension MyDiariesViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: 350, height: 166)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		CGSize(width: collectionView.frame.width - 32.0, height: 100.0)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		return UIEdgeInsets(top: 30, left: 20, bottom: 10, right: 20)
	}
}
