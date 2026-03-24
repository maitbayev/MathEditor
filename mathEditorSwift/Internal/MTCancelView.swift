import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@objc(MTCancelView)
public final class MTCancelView: MTView {
  private let imageView: MTImageView

  @objc(initWithTarget:action:)
  public init(target: AnyObject, action: Selector) {
    #if canImport(UIKit)
    let image = MTImage(systemName: "xmark.circle")?.withRenderingMode(.alwaysTemplate)
    imageView = MTImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .secondaryLabel
    #else
    imageView = MTImageView(frame: .zero)
    imageView.image = MTImage(systemSymbolName: "xmark.circle", accessibilityDescription: nil)
    imageView.imageScaling = .scaleProportionallyUpOrDown
    imageView.contentTintColor = .secondaryLabelColor
    #endif

    super.init(frame: .zero)

    addSubview(imageView)
    imageView.pinToSuperview()

    #if canImport(UIKit)
    let tap = UITapGestureRecognizer(target: target, action: action)
    addGestureRecognizer(tap)
    #else
    let tap = NSClickGestureRecognizer(target: target, action: action)
    addGestureRecognizer(tap)
    #endif

    isHidden = true
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
