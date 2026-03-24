import Foundation

#if canImport(UIKit)
  import ObjectiveC
  import UIKit

  private final class MTTextInputPosition: UITextPosition {}

  private final class MTTextInputRange: UITextRange {
    private let internalStart = MTTextInputPosition()
    private let internalEnd = MTTextInputPosition()

    override var start: UITextPosition { internalStart }
    override var end: UITextPosition { internalEnd }
    override var isEmpty: Bool { true }
  }

  private final class WeakTextInputDelegateBox {
    weak var value: UITextInputDelegate?

    init(_ value: UITextInputDelegate?) {
      self.value = value
    }
  }

  private enum MTTextInputAssociatedKeys {
    static var selectedTextRange = "mt_selectedTextRange"
    static var inputDelegate = "mt_inputDelegate"
    static var markedTextRange = "mt_markedTextRange"
    static var markedTextStyle = "mt_markedTextStyle"
    static var tokenizer = "mt_tokenizer"
    static var beginningOfDocument = "mt_beginningOfDocument"
    static var endOfDocument = "mt_endOfDocument"
  }

  extension MTEditableMathLabelSwift: UITextInput {
    public var selectedTextRange: UITextRange? {
      get {
        objc_getAssociatedObject(self, &MTTextInputAssociatedKeys.selectedTextRange) as? UITextRange
      }
      set {
        objc_setAssociatedObject(
          self,
          &MTTextInputAssociatedKeys.selectedTextRange,
          newValue,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }

    public var inputDelegate: UITextInputDelegate? {
      get {
        (
          objc_getAssociatedObject(self, &MTTextInputAssociatedKeys.inputDelegate)
            as? WeakTextInputDelegateBox
        )?.value
      }
      set {
        objc_setAssociatedObject(
          self,
          &MTTextInputAssociatedKeys.inputDelegate,
          WeakTextInputDelegateBox(newValue),
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }

    public var markedTextRange: UITextRange? {
      objc_getAssociatedObject(self, &MTTextInputAssociatedKeys.markedTextRange) as? UITextRange
    }

    public var markedTextStyle: [NSAttributedString.Key: Any]? {
      get {
        objc_getAssociatedObject(self, &MTTextInputAssociatedKeys.markedTextStyle)
          as? [NSAttributedString.Key: Any]
      }
      set {
        objc_setAssociatedObject(
          self,
          &MTTextInputAssociatedKeys.markedTextStyle,
          newValue,
          .OBJC_ASSOCIATION_COPY_NONATOMIC
        )
      }
    }

    public var beginningOfDocument: UITextPosition {
      if let position = objc_getAssociatedObject(
        self,
        &MTTextInputAssociatedKeys.beginningOfDocument
      ) as? UITextPosition {
        return position
      }
      let position = MTTextInputPosition()
      objc_setAssociatedObject(
        self,
        &MTTextInputAssociatedKeys.beginningOfDocument,
        position,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      return position
    }

    public var endOfDocument: UITextPosition {
      if let position = objc_getAssociatedObject(
        self,
        &MTTextInputAssociatedKeys.endOfDocument
      ) as? UITextPosition {
        return position
      }
      let position = MTTextInputPosition()
      objc_setAssociatedObject(
        self,
        &MTTextInputAssociatedKeys.endOfDocument,
        position,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      return position
    }

    public var tokenizer: UITextInputTokenizer {
      if let tokenizer = objc_getAssociatedObject(self, &MTTextInputAssociatedKeys.tokenizer)
        as? UITextInputTokenizer
      {
        return tokenizer
      }
      let tokenizer = UITextInputStringTokenizer(textInput: self)
      objc_setAssociatedObject(
        self,
        &MTTextInputAssociatedKeys.tokenizer,
        tokenizer,
        .OBJC_ASSOCIATION_RETAIN_NONATOMIC
      )
      return tokenizer
    }

    public func baseWritingDirection(
      for position: UITextPosition,
      in direction: UITextStorageDirection
    ) -> NSWritingDirection {
      .leftToRight
    }

    public func caretRect(for position: UITextPosition) -> CGRect {
      .zero
    }

    public func unmarkText() {}

    public func characterRange(at point: CGPoint) -> UITextRange? {
      nil
    }

    public func characterRange(
      byExtending position: UITextPosition,
      in direction: UITextLayoutDirection
    ) -> UITextRange? {
      nil
    }

    public func closestPosition(to point: CGPoint) -> UITextPosition? {
      nil
    }

    public func closestPosition(to point: CGPoint, within range: UITextRange) -> UITextPosition? {
      nil
    }

    public func compare(_ position: UITextPosition, to other: UITextPosition) -> ComparisonResult {
      .orderedSame
    }

    public func dictationRecognitionFailed() {}

    public func dictationRecordingDidEnd() {}

    public func firstRect(for range: UITextRange) -> CGRect {
      .zero
    }

    public func frame(
      forDictationResultPlaceholder placeholder: Any
    ) -> CGRect {
      .zero
    }

    public func insertDictationResult(_ dictationResult: [UIDictationPhrase]) {}

    public func insertDictationResultPlaceholder() -> Any {
      MTTextInputRange()
    }

    public func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
      0
    }

    public func position(
      from position: UITextPosition,
      in direction: UITextLayoutDirection,
      offset: Int
    ) -> UITextPosition? {
      nil
    }

    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
      nil
    }

    public func position(
      within range: UITextRange,
      farthestIn direction: UITextLayoutDirection
    ) -> UITextPosition? {
      nil
    }

    public func removeDictationResultPlaceholder(
      _ placeholder: Any,
      willInsertResult: Bool
    ) {}

    public func replace(_ range: UITextRange, withText text: String) {}

    public func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
      []
    }

    public func setBaseWritingDirection(
      _ writingDirection: NSWritingDirection,
      for range: UITextRange
    ) {}

    public func setMarkedText(_ markedText: String?, selectedRange: NSRange) {}

    public func text(in range: UITextRange) -> String? {
      nil
    }

    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition)
      -> UITextRange?
    {
      nil
    }

    public var autocapitalizationType: UITextAutocapitalizationType {
      .none
    }

    public var autocorrectionType: UITextAutocorrectionType {
      .no
    }

    public var returnKeyType: UIReturnKeyType {
      .default
    }

    public var spellCheckingType: UITextSpellCheckingType {
      .no
    }

    public var keyboardType: UIKeyboardType {
      .asciiCapable
    }
  }
#endif
