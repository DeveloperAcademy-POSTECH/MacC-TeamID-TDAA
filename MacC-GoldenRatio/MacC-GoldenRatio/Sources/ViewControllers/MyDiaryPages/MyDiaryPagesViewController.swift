//
//  MyDiaryPagesViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/08.
//

import SnapKit
import UIKit

class MyDiaryPagesViewController: UIViewController {
    
    private let device = UIScreen.getDevice()
    private var viewModel = MyDiaryPagesViewModel()
    private let itemSpacing: CGFloat = 20 // TODO: UIScreen+ 추가 예정
    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 1 {
        didSet {
            if currentPage == 0 {
                currentPage = 1
            } else if currentPage > pageCount {
                currentPage = pageCount
            }
            self.dayLabel.text = "\(currentPage)일차"
        }
    }
    var pageCount: Int
	var diaryData: Diary

	init(diaryData: Diary) {
		self.diaryData = diaryData
        self.pageCount = diaryData.pageThumbnails.count
        
        super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: configuration), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: configuration), for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = diaryData.diaryName
        label.font = UIFont(name: "EF_Diary", size: 24) ?? UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.text = "1일차"
        label.font = UIFont(name: "EF_Diary", size: 20) ?? UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var myPagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = itemSpacing
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.frame.width - 100, height: view.frame.height / 1.61)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "diaryInnerTexture.png") ?? UIImage())
        collectionView.register(MyDiaryPagesViewCollectionViewCell.self, forCellWithReuseIdentifier: "MyDiaryPagesViewCollectionViewCell")
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        
        return collectionView
        
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.compact.left", withConfiguration: configuration), for: .normal)
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.compact.right", withConfiguration: configuration), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Full Modal dismiss 이후 호출, 업데이트된 다이어리 정보 반영
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true

        // TODO: - modal completion handler 필요?
        Task {
            do {
                diaryData = try await self.viewModel.getDiaryData(uuid: self.diaryData.diaryUUID) ?? self.diaryData
            } catch {
                print(error.localizedDescription)
            }
            print(diaryData)
            
            self.collectionViewSetup()
            self.componentsSetup()
            
        }
    }
    
    // MARK: - Feature methods
    @objc private func backButtonTapped() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonTapped() {
        let popUp = PopUpViewController(popUpPosition: .top)
        popUp.addButton(buttonTitle: "초대 코드 복사", action: copyButtonTapped)
        popUp.addButton(buttonTitle: "다이어리 수정", action: modifyButtonTapped)
        popUp.addButton(buttonTitle: "다이어리 나가기", action: outButtonTapped)
        present(popUp, animated: false)
    }
    
    @objc func copyButtonTapped() {
        UIPasteboard.general.string = diaryData.diaryUUID
        
        let ac = UIAlertController(title: "초대코드 복사 완료!", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func modifyButtonTapped() {
        let vc = DiaryConfigViewController(mode: .modify, diary: diaryData)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func outButtonTapped() {
        let ac = UIAlertController(title: "다이어리를 나가시겠습니까?", message: "다이어리를 나가면 공동편집을 할 수 없습니다.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "다이어리 나가기", style: .destructive) { _ in
            print("다이어리 나가기")
            self.viewModel.outCurrentDiary(diary: self.diaryData)
            self.backButtonTapped()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func previousButtonTapped(_ sender: UIButton) {
        if self.currentPage != 1 {
            currentPage -= 1
            updatePageOffset()
        }
    }
    
    @objc private func nextButtonTapped() {
        if self.currentPage != self.pageCount {
            currentPage += 1
            updatePageOffset()
        }
    }
    
    private func updatePageOffset() {
        let newXPoint = CGFloat(self.currentPage-1) * (self.myPagesCollectionView.frame.width + self.itemSpacing)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
                self.myPagesCollectionView.setContentOffset(CGPoint(x: newXPoint, y: 0), animated: true)
            }, completion: nil)
        }
    }
    
    // MARK: - Setup methods
    
    private func collectionViewSetup() {
        
        view.addSubview(myPagesCollectionView)
        myPagesCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.centerY.equalToSuperview().offset(55)
            $0.height.equalToSuperview().dividedBy(1.6)
        }
    }
    
    private func componentsSetup() {
        [titleLabel, dayLabel, backButton, menuButton, previousButton, nextButton].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(myPagesCollectionView)
            $0.bottom.equalTo(dayLabel.snp.top).offset(-20)
        }
        
        dayLabel.snp.makeConstraints {
            $0.leading.equalTo(myPagesCollectionView)
            $0.bottom.equalTo(myPagesCollectionView.snp.top).offset(-30)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(13)
        }
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(13)
        }
        
        previousButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalTo(myPagesCollectionView)
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(myPagesCollectionView)
        }
    }
}

// MARK: - Extensions
extension MyDiaryPagesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyDiaryPagesViewCollectionViewCell", for: indexPath) as? MyDiaryPagesViewCollectionViewCell else { return UICollectionViewCell() }
        
        if diaryData.pageThumbnails[indexPath.row] != "NoURL" {
            // TODO: 이미지 로드 해서 cell에 할당
            Task {
                let imageURL = diaryData.pageThumbnails[indexPath.row]
                guard let image = ImageManager.shared.searchImage(url: imageURL) else {
                    FirebaseStorageManager.downloadImage(urlString: imageURL) { image in
                        ImageManager.shared.cacheImage(url: imageURL, image: image ?? UIImage())
                        cell.previewImageView.image = image
                        print("network")
                    }
                    return
                }
                print("cache")
                cell.previewImageView.image = image
            }
        }
        
        return cell
    }
    
}

extension MyDiaryPagesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDay = indexPath.item
        
        let pageViewController = PageViewController(diary: diaryData, selectedDay: selectedDay)
        
        debugPrint(diaryData)
        print(selectedDay)
        self.navigationController?.pushViewController(pageViewController, animated: false)
        self.navigationController?.isNavigationBarHidden = false
    }

}

extension MyDiaryPagesViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let point = self.targetContentOffset(scrollView, withVelocity: velocity)
        targetContentOffset.pointee = point
        
        UIView.animate(withDuration: 0.2, delay: 0.2, usingSpringWithDamping: 0, initialSpringVelocity: velocity.x, options: .allowUserInteraction, animations: {
            self.myPagesCollectionView.setContentOffset(point, animated: true)
        }, completion: nil)
    }
    
    func targetContentOffset(_ scrollView: UIScrollView, withVelocity velocity: CGPoint) -> CGPoint {
        
        guard let flowLayout = myPagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        // Offset 변화, slide 제스처 비교 후 이동 방향 결정
        if previousOffset > myPagesCollectionView.contentOffset.x && velocity.x < 0 {
            currentPage = currentPage - 1
        } else if previousOffset < myPagesCollectionView.contentOffset.x && velocity.x > 0 {
            currentPage = currentPage + 1
        }
        
        let additional = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing)
        
        let updatedOffset = (flowLayout.itemSize.width + flowLayout.minimumLineSpacing) * CGFloat(currentPage) - additional
        
        previousOffset = updatedOffset
        
        return CGPoint(x: updatedOffset, y: 0)
    }
}

