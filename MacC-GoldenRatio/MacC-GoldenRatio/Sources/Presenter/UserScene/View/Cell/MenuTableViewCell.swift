//
//  MenuTableViewCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/16.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = .labelTtitleFont2
        label.textColor = .black
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .labelSubTitleFont2
        label.textColor = .buttonColor

        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(menuLabel)
        contentView.addSubview(subTitleLabel)

        menuLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }

    }
    
    func setUI(title: String, subTitle: String?){
        self.menuLabel.text = title
        guard let subTitle = subTitle else { return }
        self.subTitleLabel.text = subTitle
    }
}
