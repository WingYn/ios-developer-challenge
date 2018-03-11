//
//  FaveViewModel.swift
//  Faves
//
//  Created by Sin Li - Work on 01/09/2017.
//  Copyright © 2017 Sin Li - Work. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import Alamofire

class ComicViewModel {    
    let disposeBag = DisposeBag()
    var title = Variable("")
    var thumbnailImage = Variable<UIImage?>(nil)
    var thumbnailPath = "" {
        didSet {
            Alamofire.request("\(thumbnailPath).jpg").responseData { (response) in
                if let imageData = response.data {
                    self.thumbnailImage.value = UIImage(data: imageData)
                }
                
                print(response.response?.statusCode)
            }
        }
    }

    init() {
        
    }
}

extension ComicViewModel: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return title.value
    }
}

func ==(lhs: ComicViewModel, rhs: ComicViewModel) -> Bool {
    return lhs.title.value == rhs.title.value
}

