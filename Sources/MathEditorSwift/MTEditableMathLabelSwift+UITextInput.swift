import Foundation

#if canImport(UIKit)
  import ObjectiveC
  import UIKit

  // These are blank just to get a UITextInput implementation, to fix the dictation button bug.
  // Proposed fix from: http://stackoverflow.com/questions/20980898/work-around-for-dictation-custom-text-view-bug

  extension MTEditableMathLabelSwift: UITextInput {
    public var selectedTextRange: UITextRange? {
      get {
        textInputHandler.selectedTextRange
      }
      set {
        textInputHandler.selectedTextRange = newValue
      }
    }

    public var inputDelegate: UITextInputDelegate? {
      get {
        textInputHandler.inputDelegate
      }
      set {
        textInputHandler.inputDelegate = newValue
      }
    }

    public var markedTextRange: UITextRange? {
      textInputHandler.markedTextRange
    }

    public var markedTextStyle: [NSAttributedString.Key: Any]? {
      get {
        textInputHandler.markedTextStyle
      }
      set {
        textInputHandler.markedTextStyle = newValue
      }
    }

    public var beginningOfDocument: UITextPosition {
      textInputHandler.beginningOfDocument
    }

    public var endOfDocument: UITextPosition {
      textInputHandler.endOfDocument
    }

    public var tokenizer: UITextInputTokenizer {
      textInputHandler.tokenizer
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

    public var insertDictationResultPlaceholder: Any { 0 }

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
