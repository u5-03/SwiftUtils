//
//  ImageLoader.swift
//
//  Created by 杉山優悟 on 2020/09/27.
//

import UIKit
import SwiftUI
import Combine
import SwiftExtensions

final public class ImageLoader: ObservableObject {
    @Published public var image: Image?

    public init() {}

    public func load(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            ImageCache.shared.setObject(image, forKey: url.absoluteString.ns)
            DispatchQueue.main.async {
                self.image = Image(uiImage: image)
            }
        }.resume()
    }

    public static func load(url: URL, result: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = ImageCache.shared.object(forKey: url.absoluteString.ns) {
            result(.success(image))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                result(.failure(error))
            } else if let data = data, let image = UIImage(data: data)  {
                ImageCache.shared.setObject(image, forKey: url.absoluteString.ns)
                DispatchQueue.main.async {
                    result(.success(image))
                }
            }
        }.resume()
    }

    public static func load(url: URL, defaultImage: UIImage? = nil) -> AnyPublisher<UIImage?, Never> {
        if let image = ImageCache.shared.object(forKey: url.absoluteString.ns) {
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap({ UIImage(data: $0) })
            .handleEvents(receiveOutput: { image in
                guard let image = image else { return }
                ImageCache.shared.setObject(image, forKey: url.absoluteString.ns)
            })
            .catch({ _ -> Just<UIImage?> in
                Just(defaultImage)
            })
            .eraseToAnyPublisher()
    }
}
