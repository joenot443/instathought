//
//  PhotoService.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import Foundation
import Photos
import UIKit

class PhotoService {
  static func saveImages(images: [UIImage]) {
    PHPhotoLibrary.shared().performChanges {
      for image in images {
        PHAssetChangeRequest.creationRequestForAsset(from: image)
      }
    }
  }
}
