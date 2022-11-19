//
//  PageSection.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/19.
//

import RxDataSources

struct PageSection {
    var header: String
    var items: [Page]
}

extension PageSection: SectionModelType {
    
    typealias Item = Page

    init(original: PageSection, items: [Page]) {
        self = original
        self.items = items
    }
}
