//
//  MyDiaryPagesViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/08.
//

import FirebaseFirestore
import SnapKit
import UIKit

class MyDiaryPagesViewController: UIViewController {
    
    // private let device = UIScreen.getDevice()
    private let itemSpacing: CGFloat = 20 // TODO: UIScreen+ 추가 예정
    let dummyPageCount = Int.random(in: 3...5)
    private var previousOffset: CGFloat = 0
    private var currentPage: Int = 1 {
        didSet {
            if currentPage == 0 {
                currentPage = 1
            } else if currentPage > dummyPageCount {
                currentPage = dummyPageCount
            }
            self.dayLabel.text = "\(currentPage)일차"
        }
    }
    
    // TODO: client 분리 예정
    //    var db = Firestore.firestore()
    //    var diaryResult: [Diary] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🌊포항항"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.text = "1일차"
        label.font = UIFont.systemFont(ofSize: 20)
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
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MyDiaryPagesViewCollectionViewCell.self, forCellWithReuseIdentifier: "MyDiaryPagesViewCollectionViewCell")
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = false
        
        return collectionView
        
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationBarSetup()
        collectionViewSetup()
        componentsSetup()
        // databaseSetup() // FIXME: 데이터베이스 fetch 구현 후 삭제 예정
        
        
    }
    
    // MARK: - Feature methods
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func menuButtonTapped() {
        print("menu Button Tapped!")
    }
    
    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = "복사된 텍스트 입니다."
        
        let ac = UIAlertController(title: "초대코드 복사 완료!", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func modifyButtonTapped() {
        let vc = DiaryConfigViewController(mode: .modify)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func outButtonTapped() {
        
    }
    
    @objc private func previousButtonTapped(_ sender: UIButton) {
        if self.currentPage != 1 {
            currentPage -= 1
            updatePageOffset()
        }
    }
    
    @objc private func nextButtonTapped() {
        if self.currentPage != self.dummyPageCount {
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
    private func navigationBarSetup() {
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: nil)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.leftBarButtonItem?.tintColor = .darkText
        navigationItem.rightBarButtonItem?.tintColor = .darkText
        
        
        let copyAction = UIAction(title: "초대코드 복사", image: nil) { _ in
            self.copyButtonTapped()
        }
        let modifyAction = UIAction(title: "다이어리 수정", image: nil) { _ in
            print("메뉴 다이어리 수정 버튼")
            self.modifyButtonTapped()
        }
        let outAction = UIAction(title: "다이어리 나가기", image: nil) { _ in
            print("메뉴 다이어리 나가기 버튼")
        }
        
        menuButton.menu = UIMenu(title: "", options: .displayInline, children: [copyAction, modifyAction, outAction])
        
    }
    
    private func collectionViewSetup() {
        
        view.addSubview(myPagesCollectionView)
        myPagesCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(50)
            $0.centerY.equalToSuperview().offset(55)
            $0.height.equalToSuperview().dividedBy(1.6)
        }
    }
    
    private func componentsSetup() {
        [titleLabel, dayLabel, previousButton, nextButton].forEach {
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
        
        previousButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalTo(myPagesCollectionView)
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(myPagesCollectionView)
        }
    }
    
    // FIXME: 데이터베이스 fetch 구현 후 삭제 예정
    //    private func databaseSetup() {
    //        db.collection("Diary").addSnapshotListener { snapshot, error in
    //            guard let documents = snapshot?.documents else {
    //                print("ERROR Firestore fetching document \(String(describing: error))")
    //                return
    //            }
    //
    //            self.diaryResult = documents.compactMap { doc -> Diary? in
    //                do {
    //                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
    //                    let diary = try JSONDecoder().decode(Diary.self, from: jsonData)
    //                    return diary
    //
    //                } catch let error {
    //                    print("ERROR JSON Parsing \(error)")
    //                    return nil
    //                }
    //            }
    //        }
    //
    //        print(diaryResult)
    //    }
}

// MARK: - Extensions
extension MyDiaryPagesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyPageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyDiaryPagesViewCollectionViewCell", for: indexPath)
        
        cell.backgroundColor = .systemGray
        return cell
    }
    
}

extension MyDiaryPagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
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

