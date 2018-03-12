//
//  ComicCollectionViewCell.swift
//  StreetBees-SinLi
//
//  Created by Sin Li - Work on 11/03/2018.
//  Copyright © 2018 Sin Li. All rights reserved.
//

import UIKit
import RxSwift

class ComicCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var comicThumbnailImageView: UIImageView!
    var disposeBag = DisposeBag()
    var comicViewModel: ComicViewModel? {
        didSet {
            guard let comicViewModel = comicViewModel else { return }
            comicViewModel.thumbnailImage.asDriver().drive(onNext: { (image) in
                self.comicThumbnailImageView.image = image
            }).disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        comicThumbnailImageView.image = nil
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        comicViewModel = nil
        disposeBag = DisposeBag()
    }

}
