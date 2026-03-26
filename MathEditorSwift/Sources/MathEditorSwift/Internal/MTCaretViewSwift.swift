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

// The settings below make sense for the given font size. They are scaled appropriately when the fontsize changes.
private func caretHeight() -> CGFloat {
  caretAscent + caretDescent
}

private final class CaretHandle: MTView {
  weak var label: MTEditableMathLabelSwift?

  var color: MTColor? {
    didSet {
      baseColor = color?.withAlphaComponent(0.7)
      setNeedsDisplay()
    }
  }

  private var path = MTBezierPath()
  private var baseColor: MTColor?

  override init(frame: CGRect) {
    super.init(frame: frame)
    path = createHandlePath()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func createHandlePath() -> MTBezierPath {
    let path = MTBezierPath()
    let size = bounds.size
    path.move(to: CGPoint(x: size.width / 2, y: 0))
    path.addLine(to: CGPoint(x: size.width, y: size.height / 4))
    path.addLine(to: CGPoint(x: size.width, y: size.height))
    path.addLine(to: CGPoint(x: 0, y: size.height))
    path.addLine(to: CGPoint(x: 0, y: size.height / 4))
    path.close()
    return path
  }

  private func interactionBegan() {
    baseColor = baseColor?.withAlphaComponent(1.0)
    setNeedsDisplay()
  }

  private func interactionEnded() {
    baseColor = baseColor?.withAlphaComponent(0.6)
    setNeedsDisplay()
  }

  private func handleDrag(localPoint: CGPoint) {
    let caretPoint = CGPoint(x: localPoint.x, y: localPoint.y - frame.origin.y)
    guard let label else { return }
    let labelPoint = convert(caretPoint, to: label)
    // puts the point at the top to the top of the current caret
    label.moveCaret(to: labelPoint)
  }

  private func hitArea() -> CGRect {
    // Create a hit area around the center.
    let size = bounds.size
    return CGRect(
      x: (size.width - caretHandleHitAreaSize) / 2,
      y: (size.height - caretHandleHitAreaSize) / 2,
      width: caretHandleHitAreaSize,
      height: caretHandleHitAreaSize
    )
  }

  #if canImport(UIKit)
    public override func draw(_ rect: CGRect) {
      baseColor?.setFill()
      path.fill()
    }

    public override func layoutSubviews() {
      super.layoutSubviews()
      path = createHandlePath()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      interactionBegan()
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      interactionEnded()
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      // From apple documentation
      guard let touch = touches.first else { return }
      handleDrag(localPoint: touch.location(in: self))
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      interactionEnded()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
      hitArea().contains(point)
    }
  #else
    public override var isFlipped: Bool { true }

    public override func draw(_ dirtyRect: NSRect) {
      baseColor?.setFill()
      path.fill()
    }

    public override func layout() {
      super.layout()
      path = createHandlePath()
    }

    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
      true
    }

    public override func mouseDown(with event: NSEvent) {
      interactionBegan()
    }

    public override func mouseDragged(with event: NSEvent) {
      handleDrag(localPoint: convert(event.locationInWindow, from: nil))
    }

    public override func mouseUp(with event: NSEvent) {
      interactionEnded()
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
      guard !isHidden else { return nil }
      let localPoint = convert(point, from: superview)
      return hitArea().contains(localPoint) ? self : nil
    }
  #endif
}

public final class MTCaretViewSwift: MTView {
  public var caretColor: MTColor? {
    didSet {
      handle.color = caretColor
      blinker.backgroundColor = caretColor
    }
  }

  private var blinkTimer: Timer?
  private let blinker = MTView(frame: .zero)
  private let handle: CaretHandle
  private var scale: CGFloat

  init(editor: MTEditableMathLabelSwift) {
    scale = editor.fontSize / caretFontSize
    handle = CaretHandle(
      frame: CGRect(
        x: 0,
        y: 0,
        width: caretHandleWidth * scale,
        height: caretHandleHeight * scale
      ))
    super.init(frame: .zero)

    blinker.backgroundColor = caretColor
    addSubview(blinker)

    handle.backgroundColor = .clear
    handle.isHidden = true
    handle.label = editor
    addSubview(handle)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setPosition(_ position: CGPoint) {
    // position is in the parent's coordinate system and it is the bottom left corner of the view.
    frame = CGRect(x: position.x, y: position.y - caretAscent * scale, width: 0, height: 0)
  }

  func setFontSize(_ fontSize: CGFloat) {
    scale = fontSize / caretFontSize
    setNeedsLayout()
  }

  func showHandle(_ show: Bool) {
    handle.isHidden = !show
  }

  // Helper method to set an initial blink delay
  func delayBlink() {
    isHidden = false
    blinker.isHidden = false
    blinkTimer?.fireDate = Date(timeIntervalSinceNow: initialBlinkDelay)
  }

  // Helper method to toggle hidden state of caret view.
  private func blink() {
    blinker.isHidden.toggle()
  }

  private func doLayout() {
    blinker.frame = CGRect(x: 0, y: 0, width: caretWidth * scale, height: caretHeight() * scale)
    handle.frame = CGRect(
      x: -((caretHandleWidth - caretWidth) * scale / 2),
      y: (caretHeight() + caretHandleDescent) * scale,
      width: caretHandleWidth * scale,
      height: caretHandleHeight * scale
    )
  }

  private func startBlinkingIfNeeded() {
    guard superview != nil else {
      blinkTimer?.invalidate()
      blinkTimer = nil
      return
    }
    if blinkTimer == nil {
      blinkTimer = Timer.scheduledTimer(withTimeInterval: blinkRate, repeats: true) {
        [weak self] _ in
        self?.blink()
      }
    }
    delayBlink()
  }

  deinit {
    blinkTimer?.invalidate()
  }

  #if canImport(UIKit)
    public override func didMoveToSuperview() {
      super.didMoveToSuperview()
      // UIView didMoveToSuperview override to set up blink timers after caret view created in superview.
      isHidden = false
      startBlinkingIfNeeded()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
      if !handle.isHidden {
        return handle.point(inside: convert(point, to: handle), with: event)
      }
      return super.point(inside: point, with: event)
    }

    public override func layoutSubviews() {
      super.layoutSubviews()
      doLayout()
    }
  #else
    public override var isFlipped: Bool { true }

    public override func viewDidMoveToSuperview() {
      super.viewDidMoveToSuperview()
      isHidden = false
      startBlinkingIfNeeded()
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
