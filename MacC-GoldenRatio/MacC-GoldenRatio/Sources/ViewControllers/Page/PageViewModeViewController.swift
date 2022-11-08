//
//  PageViewModeViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/08.
//

import RxCocoa
import RxSwift
import UIKit
import SnapKit

class PageViewModeViewController: UIViewController {
    
    private var pageViewModel: PageViewModel!

    private lazy var pageCollectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumInteritemSpacing = 0
        collectionViewFlowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(PageViewModeCollectionViewCell.self, forCellWithReuseIdentifier: PageViewModeCollectionViewCell.identifier)
        collectionView.delegate = self

        return collectionView
    }()
    
    // MARK: init
    init(diary: Diary, selectedDay: Int) async {
        super.init(nibName: nil, bundle: nil)
        self.pageViewModel = await PageViewModel(diary: diary, selectedDay: selectedDay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureSubView()
               
        Observable
            .combineLatest(self.pageViewModel.allPageItemKeys, self.pageViewModel.allPageItemObservable) { (keys, itemDic) in
            return keys.map {
                itemDic[$0]
            }
        }
        .debug()
        .bind(to: pageCollectionView.rx.items(cellIdentifier: PageViewModeCollectionViewCell.identifier, cellType: PageViewModeCollectionViewCell.self)) { (index, items, cell) in
            if let items = items {
                cell.setStickerView(items: items)
            }
        }
        .disposed(by: self.pageViewModel.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigation()

    }
    
    private func configureSubView() {
        self.view.addSubview(self.pageCollectionView)
        
        self.pageCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(onTapNavigationBack))
        let rightBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(onTapNavigationMenu))
        
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.pageViewModel.selectedDay
            .subscribe(on: MainScheduler.instance)
            .map{
                ($0 + 1).description + "일차"
            }
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.pageViewModel.disposeBag)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.black]
    }
    
    @objc private func onTapNavigationBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func onTapNavigationMenu() {
        let popUp = PopUpViewController(popUpPosition: .top)
        popUp.addButton(buttonTitle: "현재 페이지 편집", action: onTapEditCurrentPage)
        popUp.addButton(buttonTitle: "현재 페이지 공유", action: onTapShareCurrentPage)

        self.present(popUp, animated: false)
    }
    
    @objc private func onTapEditCurrentPage() {
        let viewController = PageViewController(pageViewModel: self.pageViewModel)
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func onTapShareCurrentPage() {

    }
}

extension PageViewModeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        let cellHeight = collectionView.frame.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

class PageViewModeCollectionViewCell: UICollectionViewCell {
    
    private let pageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        // TODO: border 설정해주기
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.5
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.pageBackgroundView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func configureSubView() {
        DispatchQueue.main.async {
            [self.pageBackgroundView].forEach {
                self.contentView.addSubview($0)
            }
            
            self.pageBackgroundView.snp.makeConstraints { make in
                make.edges.equalTo(self.contentView)
            }
        }
    }
    
    func setStickerView(items: [Item]) {
        DispatchQueue.main.async {
            let stickerViews: [StickerView] = items.map { item in
                
                switch item.itemType {
                case .text:
                    return TextStickerView(item: item)
                case .image:
                    return ImageStickerView(item: item)
                case .sticker:
                    return StickerStickerView(item: item)
                case .location:
                    return MapStickerView(item: item)
                }
                
            }
            
            stickerViews.forEach {
                self.pageBackgroundView.addSubview($0)
            }
        }
    }
}
