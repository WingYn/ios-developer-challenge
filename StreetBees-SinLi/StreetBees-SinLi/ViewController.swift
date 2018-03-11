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
    
    func authDigest() -> [String: String] {
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
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        let comicCollectionViewCellReuseIdentifier = "ComicCollectionViewCellReuseIdentifier"
        
        collectionView.register(UINib(nibName: "ComicCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: comicCollectionViewCellReuseIdentifier)

        let tvAnimatedDataSource = RxCollectionViewSectionedAnimatedDataSource<ComicSection>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top, reloadAnimation: .fade, deleteAnimation: .left),
            configureCell: { (tvSectionedDataSource, collectionView, indexPath, comicViewModel) -> UICollectionViewCell in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: comicCollectionViewCellReuseIdentifier, for: indexPath) as! ComicCollectionViewCell
                
//                cell.thumbnailSize = CGSize(width: self.cellWidth, height: self.cellHeight)
                cell.comicViewModel = comicViewModel
                cell.comicThumbnailImageView.backgroundColor = .gray
                
                return cell
        }, configureSupplementaryView: { (sectionedDataSource, collectionView, sectionTitle, indexPath) -> UICollectionReusableView in
            return UICollectionReusableView()
        })
        
        comicSections.asObservable().bind(to: collectionView.rx.items(dataSource: tvAnimatedDataSource)).disposed(by: disposeBag)

//        guard let url = URL(string: apiEndPoint) else { return }
//        let urlRequest = URLRequest(url: url)
//        let session = URLSession.shared
//
//        let task = session.dataTask(with: urlRequest) { (data, response, error) in
//            guard error == nil else { return }
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
//            guard let data = data else { return }
//            guard let allData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else { return }
//            guard let comicsData = allData?["data"] as? [String: AnyObject] else { return }
//            guard let comicsResults = comicsData["results"] as? [[String: AnyObject]] else { return }
//            for comic in comicsResults {
//                guard let thumbnail = comic["thumbnail"] as? [String: AnyObject] else { return }
//                guard let path = thumbnail["path"] as? String else { return }
//                print(path)
//
//                guard let thumbnailPath = URL(string: path) else { return }
//                let thumbnailUrlRequest = URLRequest(url: thumbnailPath)
//
//                let thumbnailTask = URLSession.shared.dataTask(with: thumbnailUrlRequest) { (data, response, error) in
//                    print(data)
//                    print(response)
//                }
//
//                thumbnailTask.resume()
//            }
//            print(comicsResults)
//            for result in results {
//                print(result)
//                guard let keyString = key as? String else { return }
//                guard let rate = remoteRates[key] as? Float else { return }
//
//                currentRates[keyString] = rate
//            }
//        }
//        task.resume()

        let parameters: Parameters = authDigest()
        
        Alamofire.request("http://gateway.marvel.com/v1/public/comics", method: .get, parameters: parameters).responseJSON { (response) in
            if let alldata = response.result.value as? [String: Any] {
                guard let comicsData = alldata["data"] as? [String: AnyObject] else { return }
                guard let comicsResults = comicsData["results"] as? [[String: AnyObject]] else { return }
                for comicJSON in comicsResults {
                    let comicViewModel = ComicViewModel()
                    if let title = comicJSON["title"] as? String {
                        comicViewModel.title.value = title
                    }
                    guard let thumbnail = comicJSON["thumbnail"] as? [String: AnyObject] else { return }
                    if let thumbnailPath = thumbnail["path"] as? String {
                        comicViewModel.thumbnailPath = thumbnailPath
                    }
                    
//                    if let images = comicJSON["images"] as? NSArray {
//                        print(images)
//                    }
                    
                    self.comicViewModels.append(comicViewModel)
//                    Alamofire.request(path, method: .get, parameters: parameters).responseData(completionHandler: { (response) in
//                        print(response.data)
//                    })
                }
                self.comicSections.value = [ComicSection(model: "", items: self.comicViewModels)]
            }
        }
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
        let cellWidth = (view.bounds.size.width / 4)
        let cellHeight = cellWidth * 1.5
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

struct Comic {
    var title = ""
    var thumbnailPath = ""
}

typealias ComicSection = AnimatableSectionModel<String, ComicViewModel>


