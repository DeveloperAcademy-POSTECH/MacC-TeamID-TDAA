//
//  SeguementedControlView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/10.
//
import SnapKit
import UIKit

protocol SegmentedControlViewDelegate: AnyObject {
	func segmentedControl(didChange index: Int)
}

class SegmentedControlView: UIView, SegmentedControlViewDelegate {
	
	private var vStacks: [UIStackView] = []
	private var lineViews: [UIView] = []
	private var titleLabels: [UILabel] = []
	private var selectedIndex: Int = 0
	private var config: SegmentedControlConfiguration!
	
	weak var delegate: SegmentedControlViewDelegate?
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.contentSize = CGSize(width: .zero, height: 30)
		scrollView.showsVerticalScrollIndicator = false
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	private lazy var hStack: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.distribution = .fill
		return stackView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configure()
		NotificationCenter.default.addObserver(self, selector: #selector(mapListSwipeLeft), name: .mapListSwipeLeft, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(mapListSwipeRight), name: .mapListSwipeRight, object: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}
	
	func configure(_ config: SegmentedControlConfiguration) {
		self.config = config
		selectedIndex = config.day
		
		addSubview(scrollView)
		scrollView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		scrollView.addSubview(hStack)
		hStack.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		layoutElements(config, hStack)
		lineViews[selectedIndex].backgroundColor = config.selectedLineColor
		titleLabels[selectedIndex].textColor = config.selectedLabelColor
	}
	
	func segmentedControl(didChange index: Int) {
		print("didChange index: \(index)")
	}
	
	private func layoutElements(_ config: SegmentedControlConfiguration, _ stackView: UIStackView) {
		config.titles.forEach { title in
			let vStack = createVStack()
			vStack.snp.makeConstraints {
				$0.width.equalTo(UIScreen.main.bounds.size.width/3)
			}
			stackView.addArrangedSubview(vStack)
			
			let label = createLabel(title, config.font, config.unselectedLabelColor)
			
			let lineView = createLineView()
			lineView.snp.makeConstraints {
				$0.height.equalTo(2)
			}
			
			vStack.addArrangedSubview(label)
			vStack.addArrangedSubview(lineView)
			
			lineViews.append(lineView)
			titleLabels.append(label)
			vStacks.append(vStack)
		}
	}

	private func createVStack() -> UIStackView {
		let stackView = UIStackView()
		stackView.spacing = 8
		stackView.axis = .vertical
		stackView.isUserInteractionEnabled = true
		let tap = UITapGestureRecognizer(target: self, action: #selector(selectionHandler))
		tap.cancelsTouchesInView = false
		stackView.addGestureRecognizer(tap)
		return stackView
	}
	
	private func createLabel(_ title: String, _ font: UIFont, _ unselectedColor: UIColor) -> UILabel {
		let label = UILabel()
		label.text = title
		label.font = font
		label.isUserInteractionEnabled = false
		label.textAlignment = .center
		label.textColor = unselectedColor
		label.adjustsFontSizeToFitWidth = true
		return label
	}
	
	private func createLineView() -> UIView {
		let view = UIView()
		view.isUserInteractionEnabled = false
		view.backgroundColor = .placeholderText
		return view
	}
	
	@objc private func selectionHandler(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIStackView else {
			return
		}
		
		if let index = vStacks.firstIndex(of: view) {
			lineViews[selectedIndex].backgroundColor = config.unselectedLabelColor
			titleLabels[selectedIndex].textColor = config.unselectedLabelColor
			lineViews[index].backgroundColor = config.selectedLineColor
			titleLabels[index].textColor = config.selectedLabelColor
			selectedIndex = index
			delegate?.segmentedControl(didChange: selectedIndex)
		}
	}
	
	@objc private func mapListSwipeLeft() {
		if titleLabels.count > selectedIndex+1 {
			lineViews[selectedIndex].backgroundColor = config.unselectedLabelColor
			titleLabels[selectedIndex].textColor = config.unselectedLabelColor
			lineViews[selectedIndex+1].backgroundColor = config.selectedLineColor
			titleLabels[selectedIndex+1].textColor = config.selectedLabelColor
			selectedIndex = selectedIndex+1
			delegate?.segmentedControl(didChange: selectedIndex)
			if titleLabels.count-1 > selectedIndex+1 {
				self.scrollView.setContentOffset(CGPoint(x: Int(UIScreen.main.bounds.size.width)/3*selectedIndex, y: 0), animated: true)
			}
		}
	}
	
	@objc private func mapListSwipeRight() {
		if 0 <= selectedIndex-1 {
			lineViews[selectedIndex].backgroundColor = config.unselectedLabelColor
			titleLabels[selectedIndex].textColor = config.unselectedLabelColor
			lineViews[selectedIndex-1].backgroundColor = config.selectedLineColor
			titleLabels[selectedIndex-1].textColor = config.selectedLabelColor
			selectedIndex = selectedIndex-1
			delegate?.segmentedControl(didChange: selectedIndex)
			if titleLabels.count-1 > selectedIndex+1 {
				self.scrollView.setContentOffset(CGPoint(x: Int(UIScreen.main.bounds.size.width)/3*selectedIndex, y: 0), animated: true)
			}
		}
	}
}

struct SegmentedControlConfiguration {
	
	let titles: [String]
	let font: UIFont
	let spacing: CGFloat
	let selectedLabelColor: UIColor
	let unselectedLabelColor: UIColor
	let selectedLineColor: UIColor
	let day: Int
}
