//
//  ThumbnailConfigViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/24.
//

import RxSwift
import RxCocoa

struct ThumbnailConfigViewModel {
    let previewViewModel = ThumbnailPreviewViewModel()
    let dayAlbumView = AlbumCollectionViewModel()
    
    init(diary: Diary?) {
        
    }
}
