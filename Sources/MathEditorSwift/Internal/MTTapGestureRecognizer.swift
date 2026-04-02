import Foundation

#if canImport(UIKit)
  import UIKit
  typealias MTTapGestureRecognizer = UITapGestureRecognizer
#elseif canImport(AppKit)
  import AppKit
  typealias MTTapGestureRecognizer = NSClickGestureRecognizer
#endif
