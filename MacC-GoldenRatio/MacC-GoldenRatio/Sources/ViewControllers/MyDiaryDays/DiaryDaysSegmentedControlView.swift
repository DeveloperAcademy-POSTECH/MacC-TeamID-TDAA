//
//  DiaryDaysSegmentedControlView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/17.
//

import UIKit

class DiaryDaysSegmentedControlView: UISegmentedControl {
    
    let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)

    let selectedAttribute = [NSAttributedString.Key.foregroundColor: UIColor.sandbrownColor]
    let normalAttribute = [NSAttributedString.Key.foregroundColor: UIColor.stickerBackgroundColor]
    
    override init(items: [Any]?) {
        let dayButton = UIImage(systemName: "doc.text.image", withConfiguration: configuration) ?? UIImage()
        let albumButton = UIImage(systemName: "photo", withConfiguration: configuration) ?? UIImage()
        let mapButton = UIImage(systemName: "mappin.and.ellipse", withConfiguration: configuration) ?? UIImage()
        
        super.init(items: [dayButton, albumButton, mapButton])
        
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.setTitleTextAttributes(selectedAttribute, for:.selected)
        self.setTitleTextAttributes(normalAttribute, for: .normal)
        self.backgroundColor = .clear
        self.selectedSegmentIndex = 0
    }
}
