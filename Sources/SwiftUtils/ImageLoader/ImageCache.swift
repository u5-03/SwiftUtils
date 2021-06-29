//
//  ImageCache.swift
//
//  Created by 杉山優悟 on 2020/09/29.
//

import UIKit

final class ImageCache: NSCache<NSString, UIImage> {
    static let shared = ImageCache()
    private override init() {}
}
