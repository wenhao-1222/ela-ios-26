//
//  HeroNetworkImageProvider.swift
//  lns
//
//  Created by Elavatine on 2025/2/13.
//


import UIKit
//import JFHeroBrowser
import Kingfisher

extension HeroNetworkImageProvider: NetworkImageProvider {
    func downloadImage(with imgUrl: String, complete: Complete<UIImage>?) {
        KingfisherManager.shared.retrieveImage(with: URL(string: imgUrl)!, options: nil) { receiveSize, totalSize in
            guard totalSize > 0 else { return }
            let progress:CGFloat = CGFloat(CGFloat(receiveSize) / CGFloat(totalSize))
            complete?(.progress(progress))
        } downloadTaskUpdated: { task in

        } completionHandler: { result in
            switch result {
            case .success(let loadingImageResult):
                complete?(.success(loadingImageResult.image))
                break
            case .failure(let error):
                complete?(.failed(error))
                break
            }
        }
    }
}

class HeroNetworkImageProvider: NSObject {
    @objc static let shared = HeroNetworkImageProvider()
}
