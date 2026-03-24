import Foundation
import iosMath

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

private let greekLowerStart: UInt32 = 0x03B1
private let greekLowerEnd: UInt32 = 0x03C9
private let greekCapitalStart: UInt32 = 0x0391
private let greekCapitalEnd: UInt32 = 0x03A9

public protocol MTEditableMathLabelSwiftDelegate: AnyObject {
  func returnPressed(_ label: MTEditableMathLabelSwift)
  func textModified(_ label: MTEditableMathLabelSwift)
  func didBeginEditing(_ label: MTEditableMathLabelSwift)
  func didEndEditing(_ label: MTEditableMathLabelSwift)
}

public extension MTEditableMathLabelSwiftDelegate {
  func returnPressed(_ label: MTEditableMathLabelSwift) {}
  func textModified(_ label: MTEditableMathLabelSwift) {}
  func didBeginEditing(_ label: MTEditableMathLabelSwift) {}
  func didEndEditing(_ label: MTEditableMathLabelSwift) {}
}

public protocol MTMathKeyboardTraitsSwift: AnyObject {
  var equalsAllowed: Bool { get set }
  var fractionsAllowed: Bool { get set }
  var variablesAllowed: Bool { get set }
  var numbersAllowed: Bool { get set }
  var operatorsAllowed: Bool { get set }
  var exponentHighlighted: Bool { get set }
  var squareRootHighlighted: Bool { get set }
  var radicalHighlighted: Bool { get set }
}

public protocol MTKeyInputSwift: AnyObject {
  func insertText(_ text: String)
  func deleteBackward()
  var hasText: Bool { get }
}

public protocol MTMathKeyboardSwift: MTMathKeyboardTraitsSwift {
  func startedEditing(_ label: MTView & MTKeyInputSwift)
  func finishedEditing(_ label: MTView & MTKeyInputSwift)
}

@objc(MTEditableMathLabelSwift)
public final class MTEditableMathLabelSwift: MTView, MTKeyInputSwift {
  @objc public var mathList: MTMathList = MTMathList() {
    didSet {
      label.mathList = mathList
      insertionIndex = MTMathListIndex.level0Index(UInt(mathList.atoms.count))
      insertionPointChanged()
    }
  }

  @objc public var highlightColor: MTColor = .systemRed

  @objc public var textColor: MTColor? {
    get { label.textColor }
    set { label.textColor = newValue ?? label.textColor }
  }

  @objc public var caretColor: MTColor? {
    get { caretView.caretColor }
    set { caretView.caretColor = newValue }
  }

  @objc public private(set) var cancelImage: MTCancelView?
  @objc public private(set) var caretView: MTCaretViewSwift!
  public weak var delegate: MTEditableMathLabelSwiftDelegate?
  public weak var keyboard: (MTView & MTMathKeyboardSwift)?

  @objc public var fontSize: CGFloat {
    get { label.fontSize }
    set {
      label.fontSize = newValue
      caretView.setFontSize(newValue)
      insertionPointChanged()
    }
  }

  @objc public var contentInsets: MTEdgeInsets {
    get { label.contentInsets }
    set { label.contentInsets = newValue }
  }

  let label = MTMathUILabel(frame: .zero)
  private var tapGestureRecognizer: MTTapGestureRecognizer?
  private var insertionIndex: MTMathListIndex?
  private var flipTransform = CGAffineTransform.identity

  public override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override var backgroundColor: MTColor? {
    didSet {
      label.backgroundColor = backgroundColor
    }
  }

  @objc public func clear() {
    mathList = MTMathList()
    caretView.showHandle(false)
  }

  @objc(highlightCharacterAtIndex:)
  public func highlightCharacter(at index: MTMathListIndex) {
    layoutLabelIfNeeded()
    guard let displayList = label.displayList else { return }
    displayList.highlightCharacter(at: index, color: highlightColor)
    setNeedsDisplayCompat()
  }

  @objc public func clearHighlights() {
    setNeedsLayout()
  }

  @objc(moveCaretToPoint:)
  public func moveCaret(to point: CGPoint) {
    insertionIndex = closestIndex(to: point)
    insertionPointChanged()
  }

  @objc public func startEditing() {
    guard !isFirstResponder else { return }
    #if canImport(AppKit)
      window?.makeFirstResponder(self)
    #else
      becomeFirstResponder()
    #endif
  }

  @objc(enableTap:)
  public func enableTap(_ enabled: Bool) {
    tapGestureRecognizer?.isEnabled = enabled
  }

  @objc(insertMathList:atPoint:)
  public func insertMathList(_ list: MTMathList, at point: CGPoint) {
    guard let detailedIndex = closestIndex(to: point) else { return }
    var index = MTMathListIndex.level0Index(detailedIndex.atomIndex)
    for atom in list.atoms {
      mathList.insert(atom, atListIndex: index)
      index = index.next()
    }
    label.mathList = mathList
    insertionIndex = index
    insertionPointChanged()
  }

  @objc public func mathDisplaySize() -> CGSize {
    label.sizeThatFits(label.bounds.size)
  }

  @objc public func doLayout() {
    cancelImage?.frame = CGRect(
      x: frame.size.width - 55, y: (frame.size.height - 45) / 2, width: 45, height: 45)
    let transform = CGAffineTransform(translationX: 0, y: bounds.size.height)
    flipTransform = CGAffineTransform(scaleX: 1, y: -1).concatenating(transform)
    layoutLabelIfNeeded()
    insertionPointChanged()
  }

  @objc public func doBecomeFirstResponder() {
    if insertionIndex == nil {
      insertionIndex = MTMathListIndex.level0Index(UInt(mathList.atoms.count))
    }
    keyboard?.startedEditing(self)
    insertionPointChanged()
    delegate?.didBeginEditing(self)
  }

  @objc public func doResignFirstResponder() {
    keyboard?.finishedEditing(self)
    insertionPointChanged()
    delegate?.didEndEditing(self)
  }

  @objc(insertText:)
  public func insertText(_ string: String) {
    if string == "\n" {
      delegate?.returnPressed(self)
      return
    }

    guard !string.isEmpty else { return }
    let scalar = string.unicodeScalars.first!
    var insertedAtom: MTMathAtom?

    if string.count > 1 {
      insertedAtom = MTMathAtomFactory.atom(forLatexSymbolName: string)
    } else {
      insertedAtom = atom(forCharacter: scalar)
    }

    if insertionIndex?.subIndexType == .subIndexTypeDenominator, insertedAtom?.type == .relation {
      insertionIndex = insertionIndex?.levelDown()?.next()
    }

    switch string {
    case String(Character("^")):
      handleExponentButton()
    case MTSymbolSquareRoot:
      handleRadical(withDegreeButtonPressed: false)
    case MTSymbolCubeRoot:
      handleRadical(withDegreeButtonPressed: true)
    case String(Character("_")):
      handleSubscriptButton()
    case String(Character("/")):
      handleSlashButton()
    case "()":
      removePlaceholderIfPresent()
      insertParens()
    case "||":
      removePlaceholderIfPresent()
      insertAbsValue()
    default:
      if let insertedAtom, let insertionIndex {
        if !updatePlaceholderIfPresent(insertedAtom) {
          mathList.insert(insertedAtom, atListIndex: insertionIndex)
        }
        if insertedAtom.type == .fraction {
          self.insertionIndex = insertionIndex.levelUp(
            withSubIndex: MTMathListIndex.level0Index(0), type: .subIndexTypeNumerator)
        } else {
          self.insertionIndex = insertionIndex.next()
        }
      }
    }

    label.mathList = mathList
    insertionPointChanged()

    if isTrigFunction(string) {
      insertParens()
    }

    delegate?.textModified(self)
  }

  @objc public func deleteBackward() {
    guard hasText, var previousIndex = insertionIndex?.previous() else { return }

    mathList.removeAtom(atListIndex: previousIndex)
    if previousIndex.finalSubIndexType() == MTMathListSubIndexType.subIndexTypeNucleus,
      let downIndex = previousIndex.levelDown()
    {
      if let previous = downIndex.previous() {
        previousIndex = previous.levelUp(
          withSubIndex: MTMathListIndex.level0Index(1),
          type: MTMathListSubIndexType.subIndexTypeNucleus)
      } else {
        previousIndex = downIndex
      }
    }
    insertionIndex = previousIndex

    if insertionIndex?.isAtBeginningOfLine() == true,
      insertionIndex?.subIndexType != .subIndexTypeNone
    {
      if mathList.atom(atListIndex: insertionIndex) == nil, let insertionIndex {
        let atom = MTMathAtomFactory.placeholder()
        atom.nucleus = MTSymbolBlackSquare
        mathList.insert(atom, atListIndex: insertionIndex)
      }
    }

    label.mathList = mathList
    insertionPointChanged()
    delegate?.textModified(self)
  }

  @objc public var hasText: Bool {
    !mathList.atoms.isEmpty
  }

  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    layoutLabelIfNeeded()
    guard let displayList = label.displayList else { return nil }
    return displayList.closestIndex(to: convert(point, to: label))
  }

  @objc(caretRectForIndex:)
  public func caretRect(for index: MTMathListIndex) -> CGPoint {
    layoutLabelIfNeeded()
    guard let displayList = label.displayList else { return .zero }
    return displayList.caretPosition(for: index)
  }
}

extension MTEditableMathLabelSwift {
  fileprivate func initialize() {
    let tap = MTTapGestureRecognizer(target: self, action: #selector(tap(_:)))
    addGestureRecognizer(tap)
    tapGestureRecognizer = tap

    addSubview(label)
    label.pinToSuperview()
    label.fontSize = 30
    label.backgroundColor = backgroundColor
    #if canImport(UIKit)
      label.isUserInteractionEnabled = false
    #endif
    label.textAlignment = .center

    createCancelImage()

    let transform = CGAffineTransform(translationX: 0, y: bounds.size.height)
    flipTransform = CGAffineTransform(scaleX: 1, y: -1).concatenating(transform)

    caretView = MTCaretViewSwift(editor: self)
    caretView.caretColor = MTColor(white: 0.1, alpha: 1.0)

    highlightColor = MTColor.systemRed
    bringSubviewToFront(cancelImage!)
    mathList = MTMathList()
  }

  fileprivate func createCancelImage() {
    guard cancelImage == nil else { return }
    let cancelImage = MTCancelView(target: self, action: #selector(clear))
    cancelImage.frame = CGRect(
      x: frame.size.width - 55, y: (frame.size.height - 45) / 2, width: 45, height: 45)
    addSubview(cancelImage)
    self.cancelImage = cancelImage
  }

  @objc fileprivate func tap(_ tap: MTTapGestureRecognizer) {
    handleTap(at: tap.location(in: self))
  }

  fileprivate func handleTap(at point: CGPoint) {
    if !isFirstResponder {
      insertionIndex = nil
      caretView.showHandle(false)
      startEditing()
      return
    }

    insertionIndex =
      closestIndex(to: point) ?? MTMathListIndex.level0Index(UInt(mathList.atoms.count))
    caretView.showHandle(true)
    insertionPointChanged()
  }

  fileprivate static func clearPlaceholders(in mathList: MTMathList?) {
    guard let mathList else { return }
    for atom in mathList.atoms {
      if atom.type == .placeholder {
        atom.nucleus = MTSymbolWhiteSquare
      }
      if atom.superScript != nil {
        clearPlaceholders(in: atom.superScript)
      }
      if atom.subScript != nil {
        clearPlaceholders(in: atom.subScript)
      }
      if atom.type == .radical, let radical = atom as? MTRadical {
        clearPlaceholders(in: radical.degree)
        clearPlaceholders(in: radical.radicand)
      }
      if atom.type == .fraction, let fraction = atom as? MTFraction {
        clearPlaceholders(in: fraction.numerator)
        clearPlaceholders(in: fraction.denominator)
      }
    }
  }

  fileprivate func insertionPointChanged() {
    guard isFirstResponder else {
      caretView.removeFromSuperview()
      cancelImage?.isHidden = true
      return
    }

    Self.clearPlaceholders(in: mathList)

    if let index = insertionIndex, let atom = mathList.atom(atListIndex: index),
      atom.type == .placeholder
    {
      atom.nucleus = MTSymbolBlackSquare
      if index.finalSubIndexType() == .subIndexTypeNucleus {
        insertionIndex = index.levelDown()
      }
    } else if let previousIndex = insertionIndex?.previous(),
      let atom = mathList.atom(atListIndex: previousIndex),
      atom.type == .placeholder,
      atom.superScript == nil,
      atom.subScript == nil
    {
      insertionIndex = previousIndex
      atom.nucleus = MTSymbolBlackSquare
    }

    setKeyboardMode()

    guard let insertionIndex else { return }
    let caretPosition = caretRect(for: insertionIndex)
    guard caretPosition != CGPoint(x: -1, y: -1) else { return }

    caretView.setPosition(caretPosition.applying(flipTransform))
    if caretView.superview == nil {
      addSubview(caretView)
      setNeedsDisplayCompat()
    }

    cancelImage?.isHidden = false
    caretView.delayBlink()
    setLabelNeedsLayoutCompat()
  }

  fileprivate func setKeyboardMode() {
    setKeyboardValue(false, forKey: "exponentHighlighted")
    setKeyboardValue(false, forKey: "radicalHighlighted")
    setKeyboardValue(false, forKey: "squareRootHighlighted")

    if insertionIndex?.hasSubIndex(of: .subIndexTypeSuperscript) == true {
      setKeyboardValue(true, forKey: "exponentHighlighted")
      setKeyboardValue(false, forKey: "equalsAllowed")
    }
    if insertionIndex?.subIndexType == .subIndexTypeNumerator {
      setKeyboardValue(false, forKey: "equalsAllowed")
    }
    if insertionIndex?.subIndexType == .subIndexTypeDegree {
      setKeyboardValue(true, forKey: "radicalHighlighted")
    } else if insertionIndex?.subIndexType == .subIndexTypeRadicand {
      setKeyboardValue(true, forKey: "squareRootHighlighted")
    }
  }

  fileprivate func atom(forCharacter scalar: UnicodeScalar) -> MTMathAtom? {
    let string = String(scalar)
    if let atom = MTMathAtomFactory.atom(forCharacter: UInt16(scalar.value)) {
      return atom
    }
    switch string {
    case MTSymbolMultiplication:
      return MTMathAtomFactory.times()
    case MTSymbolSquareRoot:
      return MTMathAtomFactory.placeholderSquareRoot()
    case MTSymbolInfinity, MTSymbolDegree, MTSymbolAngle:
      return MTMathAtom(type: .ordinary, value: string)
    case MTSymbolDivision:
      return MTMathAtomFactory.divide()
    case MTSymbolFractionSlash:
      return MTMathAtomFactory.placeholderFraction()
    case "{":
      return MTMathAtom(type: .open, value: string)
    case "}":
      return MTMathAtom(type: .close, value: string)
    case MTSymbolGreaterEqual, MTSymbolLessEqual:
      return MTMathAtom(type: .relation, value: string)
    case "*":
      return MTMathAtomFactory.times()
    case "/":
      return MTMathAtomFactory.divide()
    default:
      break
    }

    let value = scalar.value
    if (greekLowerStart...greekLowerEnd).contains(value)
      || (greekCapitalStart...greekCapitalEnd).contains(value)
    {
      return MTMathAtom(type: .variable, value: string)
    }
    if value < 0x21 || value > 0x7E || string == "'" || string == "~" {
      return nil
    }
    return MTMathAtom(type: .ordinary, value: string)
  }

  fileprivate func handleExponentButton() {
    handleScriptButton(.subIndexTypeSuperscript)
  }

  fileprivate func handleSubscriptButton() {
    handleScriptButton(.subIndexTypeSubscript)
  }

  fileprivate func handleScriptButton(_ type: MTMathListSubIndexType) {
    guard let insertionIndex else { return }
    if insertionIndex.hasSubIndex(of: type) {
      self.insertionIndex = getIndexAfterSpecialStructure(insertionIndex, type: type)
      return
    }

    if !insertionIndex.isAtBeginningOfLine(),
      let atom = mathList.atom(atListIndex: insertionIndex.previous())
    {
      let hadScript = scriptList(for: atom, type: type) != nil
      let count = ensureScriptList(for: atom, type: type).atoms.count
      if !hadScript {
        self.insertionIndex = insertionIndex.previous()?.levelUp(
          withSubIndex: MTMathListIndex.level0Index(0), type: type)
      } else if insertionIndex.finalSubIndexType() == .subIndexTypeNucleus {
        self.insertionIndex = insertionIndex.levelDown()?.levelUp(
          withSubIndex: MTMathListIndex.level0Index(UInt(count)), type: type)
      } else {
        self.insertionIndex = insertionIndex.previous()?.levelUp(
          withSubIndex: MTMathListIndex.level0Index(UInt(count)), type: type)
      }
      return
    }

    let emptyAtom = MTMathAtomFactory.placeholder()
    setScriptList(makePlaceholderMathList(), on: emptyAtom, type: type)
    if !updatePlaceholderIfPresent(emptyAtom) {
      mathList.insert(emptyAtom, atListIndex: insertionIndex)
    }
    self.insertionIndex = insertionIndex.levelUp(
      withSubIndex: MTMathListIndex.level0Index(0), type: type)
  }

  fileprivate func getIndexAfterSpecialStructure(
    _ index: MTMathListIndex, type: MTMathListSubIndexType
  ) -> MTMathListIndex {
    var nextIndex = index
    while nextIndex.hasSubIndex(of: type) {
      nextIndex = nextIndex.levelDown() ?? nextIndex
    }
    return nextIndex.next()
  }

  fileprivate func handleSlashButton() {
    guard let insertionIndex else { return }
    let numerator = MTMathList()
    var current = insertionIndex
    while !current.isAtBeginningOfLine() {
      guard let atom = mathList.atom(atListIndex: current.previous()) else { break }
      if atom.type != .number && atom.type != .variable {
        break
      }
      numerator.insert(atom, atListIndex: MTMathListIndex.level0Index(0))
      current = current.previous()!
    }

    if current.atomIndex == insertionIndex.atomIndex {
      if let atom = atom(forCharacter: "1".unicodeScalars.first!) {
        numerator.addAtom(atom)
      }
      if !current.isAtBeginningOfLine(),
        let previousAtom = mathList.atom(atListIndex: current.previous()),
        previousAtom.type == .fraction
      {
        let times = MTMathAtomFactory.times()
        mathList.insert(times, atListIndex: current)
        current = current.next()
      }
    } else {
      mathList.removeAtoms(
        inListIndexRange: MTMathListRange.make(
          current, length: insertionIndex.atomIndex - current.atomIndex))
    }

    let fraction = MTFraction()
    fraction.denominator = MTMathList()
    fraction.denominator.addAtom(MTMathAtomFactory.placeholder())
    fraction.numerator = numerator
    mathList.insert(fraction, atListIndex: current)
    self.insertionIndex = current.levelUp(
      withSubIndex: MTMathListIndex.level0Index(0), type: .subIndexTypeDenominator)
  }

  fileprivate func getOutOfRadical(_ index: MTMathListIndex) -> MTMathListIndex {
    var index = index
    if index.hasSubIndex(of: .subIndexTypeDegree) {
      index = getIndexAfterSpecialStructure(index, type: .subIndexTypeDegree)
    }
    if index.hasSubIndex(of: .subIndexTypeRadicand) {
      index = getIndexAfterSpecialStructure(index, type: .subIndexTypeRadicand)
    }
    return index
  }

  fileprivate func handleRadical(withDegreeButtonPressed: Bool) {
    guard let current = insertionIndex else { return }

    if current.hasSubIndex(of: .subIndexTypeDegree)
      || current.hasSubIndex(of: .subIndexTypeRadicand),
      let radical = mathList.atoms[Int(current.atomIndex)] as? MTRadical
    {
      if withDegreeButtonPressed {
        if radical.degree == nil {
          radical.degree = MTMathList()
          radical.degree?.addAtom(MTMathAtomFactory.placeholder())
          insertionIndex = current.levelDown()?.levelUp(
            withSubIndex: MTMathListIndex.level0Index(0), type: .subIndexTypeDegree)
        } else if current.hasSubIndex(of: .subIndexTypeRadicand) {
          insertionIndex = current.levelDown()?.levelUp(
            withSubIndex: MTMathListIndex.level0Index(0), type: .subIndexTypeDegree)
        } else {
          insertionIndex = getOutOfRadical(current)
        }
      } else if current.hasSubIndex(of: .subIndexTypeDegree) {
        insertionIndex = current.levelDown()?.levelUp(
          withSubIndex: MTMathListIndex.level0Index(0), type: .subIndexTypeRadicand)
      } else {
        insertionIndex = getOutOfRadical(current)
      }
      return
    }

    let radical =
      withDegreeButtonPressed
      ? MTMathAtomFactory.placeholderRadical() : MTMathAtomFactory.placeholderSquareRoot()
    mathList.insert(radical, atListIndex: current)
    insertionIndex = current.levelUp(
      withSubIndex: MTMathListIndex.level0Index(0),
      type: withDegreeButtonPressed ? .subIndexTypeDegree : .subIndexTypeRadicand
    )
  }

  fileprivate func removePlaceholderIfPresent() {
    guard let insertionIndex, let current = mathList.atom(atListIndex: insertionIndex),
      current.type == .placeholder
    else { return }
    mathList.removeAtom(atListIndex: insertionIndex)
  }

  fileprivate func updatePlaceholderIfPresent(_ atom: MTMathAtom) -> Bool {
    guard let insertionIndex,
      let current = mathList.atom(atListIndex: insertionIndex),
      current.type == .placeholder
    else { return false }
    if let superScript = current.superScript {
      atom.superScript = superScript
    }
    if let subScript = current.subScript {
      atom.subScript = subScript
    }
    mathList.removeAtom(atListIndex: insertionIndex)
    mathList.insert(atom, atListIndex: insertionIndex)
    return true
  }

  fileprivate func isTrigFunction(_ string: String) -> Bool {
    ["sin", "cos", "tan", "sec", "csc", "cot"].contains(string)
  }

  fileprivate func insertParens() {
    insertPairedAtoms(open: "(", close: ")")
  }

  fileprivate func insertAbsValue() {
    insertPairedAtoms(open: "|", close: "|")
  }

  fileprivate func insertPairedAtoms(open: Character, close: Character) {
    guard let openAtom = atom(forCharacter: open.unicodeScalars.first!),
      let closeAtom = atom(forCharacter: close.unicodeScalars.first!),
      let insertionIndex
    else { return }
    mathList.insert(openAtom, atListIndex: insertionIndex)
    self.insertionIndex = insertionIndex.next()
    if let insertionIndex = self.insertionIndex {
      mathList.insert(closeAtom, atListIndex: insertionIndex)
    }
  }

  fileprivate func makePlaceholderMathList() -> MTMathList {
    let list = MTMathList()
    list.addAtom(MTMathAtomFactory.placeholder())
    return list
  }

  fileprivate func scriptList(for atom: MTMathAtom, type: MTMathListSubIndexType) -> MTMathList? {
    switch type {
    case .subIndexTypeSuperscript:
      atom.superScript
    case .subIndexTypeSubscript:
      atom.subScript
    default:
      nil
    }
  }

  fileprivate func setScriptList(
    _ list: MTMathList?, on atom: MTMathAtom, type: MTMathListSubIndexType
  ) {
    switch type {
    case .subIndexTypeSuperscript:
      atom.superScript = list
    case .subIndexTypeSubscript:
      atom.subScript = list
    default:
      break
    }
  }

  @discardableResult
  fileprivate func ensureScriptList(for atom: MTMathAtom, type: MTMathListSubIndexType)
    -> MTMathList
  {
    if let list = scriptList(for: atom, type: type) {
      return list
    }
    let list = makePlaceholderMathList()
    setScriptList(list, on: atom, type: type)
    return list
  }

  fileprivate func setKeyboardValue(_ value: Bool, forKey key: String) {
    switch key {
    case "equalsAllowed":
      keyboard?.equalsAllowed = value
    case "fractionsAllowed":
      keyboard?.fractionsAllowed = value
    case "variablesAllowed":
      keyboard?.variablesAllowed = value
    case "numbersAllowed":
      keyboard?.numbersAllowed = value
    case "operatorsAllowed":
      keyboard?.operatorsAllowed = value
    case "exponentHighlighted":
      keyboard?.exponentHighlighted = value
    case "squareRootHighlighted":
      keyboard?.squareRootHighlighted = value
    case "radicalHighlighted":
      keyboard?.radicalHighlighted = value
    default:
      break
    }
  }

  fileprivate func layoutLabelIfNeeded() {
    #if canImport(UIKit)
      label.layoutIfNeeded()
    #else
      label.layoutSubtreeIfNeeded()
    #endif
  }

  fileprivate func setNeedsDisplayCompat() {
    #if canImport(UIKit)
      setNeedsDisplay()
    #else
      needsDisplay = true
    #endif
  }

  fileprivate func setLabelNeedsLayoutCompat() {
    label.setNeedsLayout()
  }
}
