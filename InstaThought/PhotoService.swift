//
//  PhotoService.swift
//  InstaThought
//
//  Created by Joe Crozier on 9/4/24.
//

import Foundation
import Photos
import UIKit

enum PhotoSaveResult {
  case saved
  /// The user has turned off (or never granted) "Add Photos" access.
  case accessDenied
  case failed
}

class PhotoService {
  /// Saves the images to the photo library, asking for add-only access first if needed.
  /// Only reports `.saved` once the library has actually accepted the images.
  static func saveImages(images: [UIImage]) async -> PhotoSaveResult {
    var status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    if status == .notDetermined {
      status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
    }
    guard status == .authorized || status == .limited else {
      return .accessDenied
    }

    do {
      try await PHPhotoLibrary.shared().performChanges {
        for image in images {
          PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
      }
      return .saved
    } catch {
      return .failed
    }
  }
}
