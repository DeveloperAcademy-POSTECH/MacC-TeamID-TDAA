//
//  DiaryDaysSegmentedControlView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/17.
//

import UIKit

class DiaryDaysSegmentedControlView: UISegmentedControl {
    
    private lazy var underlineView: UIView = {
      let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
      let height = 5.0
      let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
      let yPosition = self.bounds.size.height - 5.0
      let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
      let view = UIView(frame: frame)
      view.backgroundColor = UIColor.sandbrownColor
      self.addSubview(view)
      return view
    }()
    
    override init(items: [Any]?) {
        
        super.init(items: ["", "", ""])
        removeBackgroundAndDivider()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        
        UIView.animate(withDuration: 0.15, animations: {
                self.underlineView.frame.origin.x = underlineFinalXPosition
            })
    }
    
    private func attribute() {
        self.backgroundColor = .clear
        self.layer.maskedCorners = .init()
        self.selectedSegmentIndex = 0
    }
    
    private func removeBackgroundAndDivider() {
        let image = UIImage().withRenderingMode(.alwaysOriginal)
        
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)

        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
    }
}
