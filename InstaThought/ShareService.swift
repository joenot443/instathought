//
//  ShareService.swift
//  InstaThought
//

import LinkPresentation
import UIKit

enum ShareService {
  /// Presents the system share sheet (Instagram, Messages, AirDrop, Save Image, …)
  /// for the rendered pages, on top of whatever is currently showing.
  @MainActor
  static func share(images: [UIImage]) {
    guard let first = images.first, let presenter = topViewController() else { return }
    // The first page carries the share sheet's header preview; the rest are shared as-is.
    let items: [Any] = [PageItemSource(image: first, pageCount: images.count)] + images.dropFirst().map { $0 as Any }
    let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
    presenter.present(activityViewController, animated: true)
  }

  @MainActor
  private static func topViewController() -> UIViewController? {
    let windows = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
    var top = (windows.first(where: \.isKeyWindow) ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

/// Shares a page image and gives the share sheet a real thumbnail and title
/// instead of the generic placeholder it shows for bare images.
private final class PageItemSource: NSObject, UIActivityItemSource {
  let image: UIImage
  let pageCount: Int

  init(image: UIImage, pageCount: Int) {
    self.image = image
    self.pageCount = pageCount
  }

  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    image
  }

  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    image
  }

  func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    let metadata = LPLinkMetadata()
    metadata.title = "InstaThought"
    metadata.originalURL = URL(fileURLWithPath: pageCount == 1 ? "1 page" : "\(pageCount) pages")
    let provider = NSItemProvider(object: image)
    metadata.imageProvider = provider
    metadata.iconProvider = provider
    return metadata
  }
}
