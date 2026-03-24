import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private let initialBlinkDelay: TimeInterval = 0.7
private let blinkRate: TimeInterval = 0.5
private let caretFontSize: CGFloat = 30
private let caretAscent: CGFloat = 25
private let caretWidth: CGFloat = 3
private let caretDescent: CGFloat = 7
private let caretHandleWidth: CGFloat = 15
private let caretHandleDescent: CGFloat = 8
private let caretHandleHeight: CGFloat = 20
private let caretHandleHitAreaSize: CGFloat = 44

private func caretHeight() -> CGFloat {
  caretAscent + caretDescent
}

private final class MTCaretHandle: MTView {
  weak var label: NSObject?
  var color: MTColor = .label {
    didSet {
      baseColor = color.withAlphaComponent(0.7)
      setNeedsDisplayCompat()
    }
  }

  private var path: MTBezierPath?
  private var baseColor: MTColor = .label.withAlphaComponent(0.7)

  override init(frame frameRect: CGRect) {
    super.init(frame: frameRect)
    rebuildPath()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func rebuildPath() {
    let size = bounds.size
    let p = MTBezierPath()
    p.move(to: CGPoint(x: size.width / 2, y: 0))
    p.addLine(to: CGPoint(x: size.width, y: size.height / 4))
    p.addLine(to: CGPoint(x: size.width, y: size.height))
    p.addLine(to: CGPoint(x: 0, y: size.height))
    p.addLine(to: CGPoint(x: 0, y: size.height / 4))
    p.close()
    path = p
  }

  private func setNeedsDisplayCompat() {
    #if canImport(UIKit)
    setNeedsDisplay()
    #else
    needsDisplay = true
    #endif
  }

  private func interactionBegan() {
    baseColor = color.withAlphaComponent(1.0)
    setNeedsDisplayCompat()
  }

  private func interactionEnded() {
    baseColor = color.withAlphaComponent(0.6)
    setNeedsDisplayCompat()
  }

  private func moveCaret(localPoint: CGPoint) {
    let caretPoint = CGPoint(x: localPoint.x, y: localPoint.y - frame.origin.y)
    let pointInLabel = convert(caretPoint, to: label as? MTView)

    let selector = NSSelectorFromString("moveCaretToPoint:")
    guard let label, label.responds(to: selector) else { return }

    typealias MoveCaretFn = @convention(c) (AnyObject, Selector, CGPoint) -> Void
    let imp = label.method(for: selector)
    let fn = unsafeBitCast(imp, to: MoveCaretFn.self)
    fn(label, selector, pointInLabel)
  }

  private func hitArea() -> CGRect {
    let size = bounds.size
    return CGRect(
      x: (size.width - caretHandleHitAreaSize) / 2,
      y: (size.height - caretHandleHitAreaSize) / 2,
      width: caretHandleHitAreaSize,
      height: caretHandleHitAreaSize
    )
  }

  #if canImport(UIKit)
  override func layoutSubviews() {
    super.layoutSubviews()
    rebuildPath()
  }

  override func draw(_ rect: CGRect) {
    baseColor.setFill()
    path?.fill()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    interactionBegan()
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    interactionEnded()
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    moveCaret(localPoint: touch.location(in: self))
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    interactionEnded()
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    hitArea().contains(point)
  }
  #else
  override var isFlipped: Bool { true }

  override func layout() {
    super.layout()
    rebuildPath()
  }

  override func draw(_ dirtyRect: NSRect) {
    baseColor.setFill()
    path?.fill()
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    true
  }

  override func mouseDown(with event: NSEvent) {
    interactionBegan()
  }

  override func mouseDragged(with event: NSEvent) {
    let point = convert(event.locationInWindow, from: nil)
    moveCaret(localPoint: point)
  }

  override func mouseUp(with event: NSEvent) {
    interactionEnded()
  }

  override func hitTest(_ point: NSPoint) -> NSView? {
    if isHidden { return nil }
    let local = convert(point, from: superview)
    return hitArea().contains(local) ? self : nil
  }
  #endif
}

@objc(MTCaretView)
public final class MTCaretView: MTView {
  @objc public var caretColor: MTColor = .label {
    didSet {
      handle.color = caretColor
      blinker.backgroundColor = caretColor
    }
  }

  private weak var label: NSObject?
  private var blinkTimer: Timer?
  private var scale: CGFloat = 1

  private let blinker = MTView(frame: .zero)
  private let handle: MTCaretHandle

  @objc(initWithEditor:)
  public init(editor: NSObject) {
    label = editor
    handle = MTCaretHandle(frame: .zero)
    super.init(frame: .zero)

    if let fontSize = editor.value(forKey: "fontSize") as? CGFloat {
      scale = fontSize / caretFontSize
    }

    blinker.backgroundColor = caretColor
    addSubview(blinker)

    handle.frame = CGRect(
      x: 0,
      y: 0,
      width: caretHandleWidth * scale,
      height: caretHandleHeight * scale
    )
    handle.backgroundColor = .clear
    handle.isHidden = true
    handle.label = editor
    addSubview(handle)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    blinkTimer?.invalidate()
  }

  @objc public func setPosition(_ position: CGPoint) {
    frame = CGRect(x: position.x, y: position.y - caretAscent * scale, width: 0, height: 0)
  }

  @objc public func setFontSize(_ fontSize: CGFloat) {
    scale = fontSize / caretFontSize
    #if canImport(UIKit)
    setNeedsLayout()
    #else
    needsLayout = true
    #endif
  }

  @objc public func showHandle(_ show: Bool) {
    handle.isHidden = !show
  }

  private func doLayout() {
    blinker.frame = CGRect(x: 0, y: 0, width: caretWidth * scale, height: caretHeight() * scale)
    handle.frame = CGRect(
      x: -(caretHandleWidth - caretWidth) * scale / 2,
      y: (caretHeight() + caretHandleDescent) * scale,
      width: caretHandleWidth * scale,
      height: caretHandleHeight * scale
    )
  }

  private func blink() {
    blinker.isHidden.toggle()
  }

  private func didMoveToParent() {
    isHidden = false

    if superview != nil {
      blinkTimer?.invalidate()
      blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkRate, repeats: true) { [weak self] _ in
        self?.blink()
      }
      delayBlink()
    } else {
      blinkTimer?.invalidate()
      blinkTimer = nil
    }
  }

  @objc public func delayBlink() {
    isHidden = false
    blinker.isHidden = false
    blinkTimer?.fireDate = Date().addingTimeInterval(initialBlinkDelay)
  }

  #if canImport(UIKit)
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if !handle.isHidden {
      return handle.point(inside: convert(point, to: handle), with: event)
    }
    return super.point(inside: point, with: event)
  }

  public override func didMoveToSuperview() {
    super.didMoveToSuperview()
    didMoveToParent()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    doLayout()
  }
  #else
  public override var isFlipped: Bool { true }

  public override func viewDidMoveToSuperview() {
    super.viewDidMoveToSuperview()
    didMoveToParent()
  }

  public override func layout() {
    super.layout()
    doLayout()
  }

  public override func hitTest(_ point: NSPoint) -> NSView? {
    hitTestOutsideBounds(point)
  }
  #endif
}
