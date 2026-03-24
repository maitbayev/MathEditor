import Foundation

#if canImport(UIKit)
import UIKit

public typealias MTColor = UIColor
public typealias MTBezierPath = UIBezierPath
public typealias MTImage = UIImage
public typealias MTImageView = UIImageView
#elseif canImport(AppKit)
import AppKit

public typealias MTColor = NSColor
public typealias MTBezierPath = NSBezierPath
public typealias MTImage = NSImage
public typealias MTImageView = NSImageView
#endif
