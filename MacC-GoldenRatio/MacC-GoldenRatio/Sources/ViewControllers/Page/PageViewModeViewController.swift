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
import RxDataSources

class PageViewModeViewController: UIViewController {
    
    private var pageViewModeViewModel: PageViewModeViewModel!
    
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    
    private var source: RxCollectionViewSectionedReloadDataSource<PageSection>!

    private var completion: ((Diary) -> Void)!
    
    private lazy var pageCollectionView: UICollectionView = {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumInteritemSpacing = 1
        collectionViewFlowLayout.minimumLineSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        collectionView.register(PageViewModeCollectionViewCell.self, forCellWithReuseIdentifier: PageViewModeCollectionViewCell.identifier)
        collectionView.register(PageCollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PageCollectionViewHeaderCell")
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.appBackgroundColor
        
        return collectionView
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.stickerBackgroundColor
        label.textColor = .white
        label.textAlignment = .center
        label.font = .navigationTitleFont
        label.layer.cornerRadius = 12.5
        label.clipsToBounds = true
        
        return label
    }()
    
    // MARK: init
    init(diary: Diary, selectedDayIndex: Int, completion: @escaping (Diary) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.completion = completion
        self.pageViewModeViewModel = PageViewModeViewModel(diary: diary, selectedDayIndex: selectedDayIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureNavigationBar()
        self.view.backgroundColor = UIColor.appBackgroundColor

        self.configureSubView()
        self.bindPageDescription()
        self.configurePageCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pageViewModeViewModel.selectedPageIndexSubject
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                self.pageCollectionView.scrollToItem(at: IndexPath(item: $0.1, section: $0.0), at: .top, animated: true)
            })
            .disposed(by: pageViewModeViewModel.disposeBag)
    }
    
    private func configureSubView() {
        [self.pageCollectionView, self.pageDescriptionLabel].forEach {
            self.view.addSubview($0)
        }
        
        self.pageCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        self.pageDescriptionLabel.snp.makeConstraints { make in
            make.trailing.top.equalTo(view.safeAreaLayoutGuide).inset(self.myDevice.pagePadding)
            make.width.equalTo(47)
            make.height.equalTo(25)
        }
    }
    
    private func bindPageDescription() {
        self.pageViewModeViewModel.pageIndexDescriptionObservable
            .observe(on: MainScheduler.instance)
            .bind(to: self.pageDescriptionLabel.rx.text)
            .disposed(by: self.pageViewModeViewModel.disposeBag)
    }
    
    private func configureNavigationBar() {
        let leftBarButtonImage = UIImage(systemName: "chevron.left")
        let leftBarButtonItem = UIBarButtonItem(image: leftBarButtonImage, style: .plain, target: self, action: #selector(onTapNavigationBack))
        leftBarButtonItem.tintColor = .black
        
        let rightBarButtonImage = UIImage(systemName: "ellipsis")
        let rightBarButtonItem = UIBarButtonItem(image: rightBarButtonImage, style: .plain, target: self, action: #selector(onTapNavigationMenu))
        rightBarButtonItem.tintColor = .black
        
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.appBackgroundColor
        self.navigationController?.navigationBar.layer.addBorder([.bottom], color: UIColor.separatorColor, width: 1)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.pageViewModeViewModel.selectedPageIndexSubject
            .observe(on: MainScheduler.instance)
            .map{
                ($0.0 + 1).description + "일차"
            }
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.pageViewModeViewModel.disposeBag)
    }
    
    private func configurePageCollectionView() {
        source = RxCollectionViewSectionedReloadDataSource<PageSection>(configureCell: { dataSource, collectionView, indexPath, item in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageViewModeCollectionViewCell.identifier, for: indexPath) as? PageViewModeCollectionViewCell {
                cell.setStickerView(items: item.items)
                
                let maxSectionIndex = self.pageCollectionView.numberOfSections - 1
                let lastItemIndex = self.pageCollectionView.numberOfItems(inSection: maxSectionIndex) - 1
                let lastIndexPath = IndexPath(item: lastItemIndex, section: maxSectionIndex)
                
                if lastIndexPath == indexPath{
                    cell.separatorView.backgroundColor = UIColor.appBackgroundColor
                }
                return cell
            } else {
                return UICollectionViewCell()
            }
        }, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PageCollectionViewHeaderCell", for: indexPath) as? PageCollectionViewHeaderCell {
                    return header
                } else {
                    return UICollectionReusableView()
                }
            default:
                fatalError()
            }
        })
        
        pageViewModeViewModel.pageCollectionViewData
            .bind(to: pageCollectionView.rx.items(dataSource: source))
            .disposed(by: pageViewModeViewModel.disposeBag)
    }
    
    @objc private func onTapNavigationBack() {
        self.pageViewModeViewModel.diaryObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.completion($0)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.pageViewModeViewModel.disposeBag)
    }
    
    @objc private func onTapNavigationMenu() {
        let popUp = PopUpViewController(popUpPosition: .top)
        popUp.addButton(buttonTitle: " 페이지 편집", buttonSymbol: "square.and.pencil", buttonSize: 17, action: onTapEditCurrentPage)
        popUp.addButton(buttonTitle: " 페이지 공유", buttonSymbol: "square.and.arrow.up", buttonSize: 17 , action: onTapShareCurrentPage)

        self.present(popUp, animated: false)
    }
    
    @objc private func onTapEditCurrentPage() {
        guard let diary = try? self.pageViewModeViewModel.diaryObservable.value() else  { return }
        guard let selectedPageIndex = try? self.pageViewModeViewModel.selectedPageIndexSubject.value() else  { return }
        
        let viewController = PageEditModeViewController(diary: diary, selectedPageIndex: selectedPageIndex, completion: { newDiary, selectedPageIndex in
            self.pageViewModeViewModel.diaryObservable.onNext(newDiary)
            self.pageViewModeViewModel.selectedPageIndexSubject.onNext(selectedPageIndex)
        })
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func onTapShareCurrentPage() {
        
        self.pageViewModeViewModel.selectedPageIndexSubject
            .take(1)
            .subscribe(onNext: { targetIndex in

                guard let targetCell = self.pageCollectionView.cellForItem(at: IndexPath(item: targetIndex.1, section: targetIndex.0)) as? PageViewModeCollectionViewCell else { return }
                guard let targetImage = targetCell.pageBackgroundView.transformToImage() else { return }

                let activityViewController = UIActivityViewController(activityItems: [targetImage], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)

            })
            .disposed(by: self.pageViewModeViewModel.disposeBag)

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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let visibleCellIndex = collectionView.indexPathsForVisibleItems.first else { return }
        print("fuckyou1")
        self.pageViewModeViewModel.selectedPageIndexSubject.onNext((visibleCellIndex.section, visibleCellIndex.item))
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let visibleCellIndex = collectionView.indexPathsForVisibleItems.first else { return }
        print("fuckyou2")
        self.pageViewModeViewModel.selectedPageIndexSubject.onNext((visibleCellIndex.section, visibleCellIndex.item))

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
           return CGSize(width: collectionView.frame.width, height: 0)
        }
        return CGSize(width: collectionView.frame.width, height: 10)
    }
}
