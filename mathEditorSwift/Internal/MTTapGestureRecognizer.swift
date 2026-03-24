import Foundation

#if canImport(UIKit)
  import UIKit
  public typealias MTTapGestureRecognizer = UITapGestureRecognizer
#elseif canImport(AppKit)
  import AppKit
  public typealias MTTapGestureRecognizer = NSClickGestureRecognizer
#endif
