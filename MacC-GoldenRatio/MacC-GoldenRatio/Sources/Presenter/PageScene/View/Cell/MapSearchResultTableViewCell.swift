//
//  MapSearchResultTableViewCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/22.
//

import SnapKit
import UIKit
import MapKit

class MapSearchResultTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .body
        label.textColor = .black
        
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadline2
        label.textColor = .gray500

        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
        self.subTitleLabel.text = nil
    }
    
    private func layout() {
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Layout.mapSearchTableViewCellVerticalPadding)
            $0.horizontalEdges.equalToSuperview().inset(Layout.mapSearchTableViewCellHorizontalPadding)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.bottom.equalToSuperview().inset(Layout.mapSearchTableViewCellVerticalPadding)
            $0.horizontalEdges.equalToSuperview().inset(Layout.mapSearchTableViewCellHorizontalPadding)
        }
    }
    
    func setUI(mapSearchResult: MKLocalSearchCompletion){
        // titleAttribute
        let titleString = mapSearchResult.title
        let attributedTitleString = NSMutableAttributedString(string: titleString)
        attributedTitleString.addAttribute(.foregroundColor, value: UIColor.gray, range: (titleString as NSString).range(of: titleString))
        attributedTitleString.addAttribute(.font, value: UIFont.body, range: (titleString as NSString).range(of: titleString))
        // subTitleAttribute
        let subTitleString = mapSearchResult.subtitle
        let attribtuedSubTitleString = NSMutableAttributedString(string: subTitleString)
        attribtuedSubTitleString.addAttribute(.foregroundColor, value: UIColor.gray, range: (subTitleString as NSString).range(of: subTitleString))
        attribtuedSubTitleString.addAttribute(.font, value: UIFont.subheadline2, range: (subTitleString as NSString).range(of: subTitleString))
        
        let titleRange = mapSearchResult.titleHighlightRanges
        titleRange.forEach{
            attributedTitleString.addAttribute(.foregroundColor, value: UIColor.black, range: $0.rangeValue)
            attributedTitleString.addAttribute(.font, value: UIFont.body, range: $0.rangeValue)
        }
        
        let subTitleRange = mapSearchResult.subtitleHighlightRanges
        subTitleRange.forEach{
            attribtuedSubTitleString.addAttribute(.foregroundColor, value: UIColor.black, range: $0.rangeValue)
            attribtuedSubTitleString.addAttribute(.font, value: UIFont.subheadline2, range: $0.rangeValue)
        }
        
        self.titleLabel.attributedText = attributedTitleString
        self.subTitleLabel.attributedText = attribtuedSubTitleString
    }
}
