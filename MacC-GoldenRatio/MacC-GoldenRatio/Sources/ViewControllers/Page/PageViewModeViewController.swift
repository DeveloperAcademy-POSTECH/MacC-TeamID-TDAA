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
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        collectionViewFlowLayout.minimumLineSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(PageViewModeCollectionViewCell.self, forCellWithReuseIdentifier: PageViewModeCollectionViewCell.identifier)
        collectionView.delegate = self

        return collectionView
    }()
    
    // MARK: init
    init(diary: Diary, selectedDayIndex: Int) async {
        super.init(nibName: nil, bundle: nil)
        self.pageViewModel = await PageViewModel(diary: diary, selectedDayIndex: selectedDayIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = .white

        self.configureSubView()
        self.configureNavigationBar()
        self.configurePageCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pageViewModel.pageCollectionViewCurrentCellIndex
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                self.pageCollectionView.scrollToItem(at: $0, at: .top, animated: true)
            })
            .disposed(by: pageViewModel.disposeBag)
    }
    
    private func configureSubView() {
        self.view.addSubview(self.pageCollectionView)
        
        self.pageCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(onTapNavigationBack))
        let rightBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(onTapNavigationMenu))
        
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.layer.addBorder([.bottom], color: .lightGray, width: 1)
        
        self.pageViewModel.selectedDayIndex
            .subscribe(on: MainScheduler.instance)
            .map{
                ($0 + 1).description + "일차"
            }
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.pageViewModel.disposeBag)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.black]
    }
    
    private func configurePageCollectionView() {
        var itemsCount = 0
        Observable
            .combineLatest(self.pageViewModel.allPageItemKeys, self.pageViewModel.allPageItemObservable) { (keys, itemDic) in
                let items = keys.map {
                    itemDic[$0]
                }
                itemsCount = items.count
                
                return items
            }
            .bind(to: pageCollectionView.rx.items(cellIdentifier: PageViewModeCollectionViewCell.identifier, cellType: PageViewModeCollectionViewCell.self)) { (index, items, cell) in
                if let items = items {
                    cell.setStickerView(items: items)
                }
                if index == itemsCount - 1 {
                    cell.separatorView.backgroundColor = .white
                } else {
                    cell.separatorView.backgroundColor = .lightGray
                }
            }
            .disposed(by: self.pageViewModel.disposeBag)
        
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
