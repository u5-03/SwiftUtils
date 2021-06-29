//
//  ImageType.swift
//  
//
//  Created by Yugo Sugiyama on 2020/12/29.
//

import UIKit

public enum ImageType {
    case imageURL(URL: URL)
    case uiImage(uiImage: UIImage)

    public var URL: URL? {
        switch self {
        case .imageURL(let URL): return URL
        case .uiImage: return nil
        }
    }

    public var uiImage: UIImage? {
        switch self {
        case .imageURL: return nil
        case .uiImage(let uiImage): return uiImage
        }
    }
}

extension ImageType: Equatable {}

public extension UIImageView {
    func setImageType(imageType: ImageType, result: ((Result<Void, Error>) -> Void)? = nil) {
        switch imageType {
        case .uiImage(let uiImage):
            image = uiImage
        case .imageURL(let URL):
            ImageLoader.load(url: URL) { [weak self] completion in
                switch completion {
                case .success(let image):
                    self?.image = image
                    result?(.success(()))
                case .failure(let error):
                    result?(.failure(error))
                }
            }
        }
    }
}
