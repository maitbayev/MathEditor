import Testing
import iosMath

@testable import MathEditorSwift

@MainActor
@Suite(.serialized)
struct MTEditableMathLabelSwiftTests {

  @Test("insertMathList inserts the provided math list into an empty label")
  func insertMathListIntoEmptyLabel() {
    let label = MTEditableMathLabelSwift()
    let insertedList = MTMathListBuilder.build(from: "1+x+\\frac{1}{2}")!
    label.insertMathList(insertedList, at: .zero)
    expectLatex("1+x+\\frac{1}{2}", from: label.mathList)
  }

  @Test("insertText when insertionIndex is temporarily nil")
  func insertTextWhenInsertionIndexIsNil() throws {
    for (input, expected) in [
      ("x", "x"),
      ("()", "()"),
      ("||", "||"),
      ("^", "□^{□}"),
      ("/", "\\atop{1}{□}"),
      ("_", "□_{□}"),
      (MTSymbolSquareRoot, "\\sqrt{□}"),
      (MTSymbolFractionSlash, "\\atop{□}{□}"),
      (MTSymbolCubeRoot, "\\sqrt[□]{□}"),
    ] {
      let label = makeLabelWithNilInsertionIndex()
      label.insertText(input)
      expectStringValue(of: label.mathList, to: expected)
    }
  }

  @Test("insertText when insertionIndex is temporarily nil and label is not empty")
  func appendTextWhenInsertionIndexIsNil() throws {
    for (input, expected) in [
      ("x", "1+x"),
      ("()", "1+()"),
      ("||", "1+||"),
      ("^", "1+^{□}"),
      ("/", "1+\\atop{1}{□}"),
      ("_", "1+_{□}"),
      (MTSymbolSquareRoot, "1+\\sqrt{□}"),
      (MTSymbolFractionSlash, "1+\\atop{□}{□}"),
      (MTSymbolCubeRoot, "1+\\sqrt[□]{□}"),
    ] {
      let mathList = MTMathListBuilder.build(from: "1+")!
      let label = makeLabelWithNilInsertionIndex(mathList: mathList)
      label.insertText(input)
      expectStringValue(of: label.mathList, to: expected)
    }
  }

}

private func makeLabelWithNilInsertionIndex(mathList: MTMathList? = nil) -> MTEditableMathLabelSwift
{
  let label = MTEditableMathLabelSwift(frame: .zero)
  if let mathList {
    label.mathList = mathList
  }
  let tapSelector = NSSelectorFromString("tap:")
  #expect(label.responds(to: tapSelector))
  _ = label.perform(tapSelector, with: nil)
  return label
}
