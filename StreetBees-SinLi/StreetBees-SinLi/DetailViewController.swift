//
//  DetailViewController.swift
//  StreetBees-SinLi
//
//  Created by Sin Li - Work on 12/03/2018.
//  Copyright © 2018 Sin Li. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController {

    @IBOutlet weak var comicImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var comicViewModel: ComicViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let margin: CGFloat = 8

        [titleLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.numberOfLines = 0
            scrollView.addSubview($0)

            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
        }
        
        titleLabel.font = .systemFont(ofSize: 24)
        
        titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: margin).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true

        // Content height should dynamically change according to how much description text there is.
        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: 600)
        comicImageView.image = comicViewModel?.thumbnailImage.value
        titleLabel.text = comicViewModel?.title.value
        descriptionLabel.text = comicViewModel?.description

    }
    
    
    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: true, completion: .none)
    }
}
