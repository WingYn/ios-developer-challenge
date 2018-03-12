//
//  ViewController.swift
//  StreetBees-SinLi
//
//  Created by Sin Li - Work on 08/03/2018.
//  Copyright © 2018 Sin Li. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxDataSources

class ViewController: UIViewController {

    var comicViewModels = [ComicViewModel]()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var comicSections = Variable<[ComicSection]>([])
    let disposeBag = DisposeBag()
    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    func authDigest() -> Parameters {
        let date = "\(Date().timeIntervalSince1970)"
        let apiKey = "b2605892376329794f3ec39209433962"
        let privateKey = "6eedd31525a0eacc53959f9805aa096c9f0e6137"
        
        let hash = MD5(string: "\(date)\(privateKey)\(apiKey)")
        
        let md5Hex =  hash.map { String(format: "%02hhx", $0) }.joined()
        
        return ["ts": date, "apikey": apiKey, "hash": md5Hex]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        let margin: CGFloat = 4
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: margin).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).isActive = true
        
        let comicCollectionViewCellReuseIdentifier = "ComicCollectionViewCellReuseIdentifier"
        
        collectionView.register(UINib(nibName: "ComicCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: comicCollectionViewCellReuseIdentifier)

        let tvAnimatedDataSource = RxCollectionViewSectionedAnimatedDataSource<ComicSection>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left),
            configureCell: { (tvSectionedDataSource, collectionView, indexPath, comicViewModel) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: comicCollectionViewCellReuseIdentifier, for: indexPath) as! ComicCollectionViewCell
                
                cell.comicViewModel = comicViewModel
                cell.comicThumbnailImageView.backgroundColor = .gray
                
                return cell
        }, configureSupplementaryView: { (_, _, _, _) -> UICollectionReusableView in
            return UICollectionReusableView()
        })
        
        comicSections.asObservable().bind(to: collectionView.rx.items(dataSource: tvAnimatedDataSource)).disposed(by: disposeBag)
        
        Alamofire.request("http://gateway.marvel.com/v1/public/comics", method: .get, parameters: authDigest()).responseJSON { (response) in
            if let alldata = response.result.value as? [String: Any] {
                guard let comicsData = alldata["data"] as? [String: AnyObject] else { return }
                guard let comicsResults = comicsData["results"] as? [[String: AnyObject]] else { return }
                for comicJSON in comicsResults {
                    let comicViewModel = ComicViewModel()
                    if let title = comicJSON["title"] as? String {
                        comicViewModel.title.value = title
                    }
                    if let thumbnail = comicJSON["thumbnail"] as? [String: AnyObject], let thumbnailPath = thumbnail["path"] as? String {
                        comicViewModel.thumbnailPath = thumbnailPath
                    }
                    
                    if let description = comicJSON["description"] as? String {
                        comicViewModel.description = description
                    }
                    
                    self.comicViewModels.append(comicViewModel)
                }
                self.comicSections.value = [ComicSection(model: "", items: self.comicViewModels)]
            }
        }
        
        collectionView.rx.modelSelected(ComicViewModel.self).subscribe(onNext: { (comicViewModel) in
            let detailViewController = DetailViewController()
            detailViewController.comicViewModel = comicViewModel
            self.present(detailViewController, animated: true, completion: .none)
        }).disposed(by: disposeBag)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = ((view.bounds.size.width - 20) / 4)
        let cellHeight = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHeight)
    }
}



