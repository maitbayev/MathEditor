import Testing
import iosMath

@testable import MathEditorSwift

@MainActor
@Suite(.serialized)
struct MTEditableMathLabelSwiftTests {
  private func makeLabelWithNilInsertionIndex() -> MTEditableMathLabelSwift {
    let label = MTEditableMathLabelSwift(frame: .zero)
    let tapSelector = NSSelectorFromString("tap:")

    #expect(label.responds(to: tapSelector))
    _ = label.perform(tapSelector, with: nil)
    return label
  }

  @Test("insertMathList inserts the provided math list into an empty label")
  func insertMathListIntoEmptyLabel() {
    let label = MTEditableMathLabelSwift(frame: .zero)
    let insertedList = MTMathListBuilder.build(from: "1+x")!

    label.insertMathList(insertedList, at: .zero)

    #expect(label.mathList.atoms.map(\.nucleus) == insertedList.atoms.map(\.nucleus))
  }

  #if canImport(AppKit)
    @Test("highlightCharacter invalidates the embedded math label for redraw")
    func highlightCharacterInvalidatesEmbeddedLabel() {
      let label = MTEditableMathLabelSwift(frame: .zero)
      label.mathList = MTMathListBuilder.build(from: "x")!
      label.label.layoutIfNeeded()
      label.needsDisplay = false
      label.label.needsDisplay = false

      label.highlightCharacter(at: .level0Index(0))

      #expect(label.label.needsDisplay)
    }

    @Test("clearHighlights invalidates the embedded math label for relayout")
    func clearHighlightsInvalidatesEmbeddedLabel() {
      let label = MTEditableMathLabelSwift(frame: .zero)
      label.mathList = MTMathListBuilder.build(from: "x")!
      label.label.layoutIfNeeded()
      label.needsDisplay = false
      label.label.needsDisplay = false

      label.clearHighlights()

      #expect(label.label.needsDisplay)
    }
  #endif

  @Test("insertText inserts normal typed input even when insertionIndex is temporarily nil")
  func insertTextWhenInsertionIndexIsNil() throws {
    let label = makeLabelWithNilInsertionIndex()
    label.insertText("x")

    #expect(label.mathList.atoms.count == 1)
    #expect(label.mathList.atoms.first?.nucleus == "x")
  }

  @Test("insertText inserts paired shortcuts even when insertionIndex is temporarily nil")
  func insertPairedShortcutsWhenInsertionIndexIsNil() throws {
    struct Case {
      let input: String
      let open: String
      let close: String
    }

    let cases: [Case] = [
      .init(input: "()", open: "(", close: ")"),
      .init(input: "||", open: "|", close: "|"),
    ]

    for testCase in cases {
      let label = makeLabelWithNilInsertionIndex()
      label.insertText(testCase.input)

      #expect(label.mathList.atoms.count == 2)
      #expect(label.mathList.atoms.first?.nucleus == testCase.open)
      #expect(label.mathList.atoms.last?.nucleus == testCase.close)
    }
  }

  @Test("insertText inserts special operations even when insertionIndex is temporarily nil")
  func insertSpecialOperationsWhenInsertionIndexIsNil() throws {
    struct Case {
      let input: String
      let expectedAtomCount: Int
      let assertResult: (MTEditableMathLabelSwift) -> Void
    }

    let cases: [Case] = [
      .init(input: "^", expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.superScript?.atoms.count == 1)
      },
      .init(input: "/", expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.type == .fraction)
      },
      .init(input: MTSymbolSquareRoot, expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.type == .radical)
      },
      .init(input: "()", expectedAtomCount: 2) { label in
        #expect(label.mathList.atoms.first?.nucleus == "(")
        #expect(label.mathList.atoms.last?.nucleus == ")")
      },
    ]

    for testCase in cases {
      let label = makeLabelWithNilInsertionIndex()
      label.insertText(testCase.input)

      #expect(label.mathList.atoms.count == testCase.expectedAtomCount)
      testCase.assertResult(label)
    }
  }

  @Test("first key after tap-to-edit preserves operator inserts before responder setup restores insertionIndex")
  func firstKeyAfterTapToEditInsertsOperators() throws {
    struct Case {
      let input: String
      let expectedAtomCount: Int
      let assertResult: (MTEditableMathLabelSwift) -> Void
    }

    let cases: [Case] = [
      .init(input: "^", expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.superScript?.atoms.count == 1)
      },
      .init(input: "_", expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.subScript?.atoms.count == 1)
      },
      .init(input: "/", expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.type == .fraction)
      },
      .init(input: MTSymbolSquareRoot, expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.type == .radical)
      },
      .init(input: MTSymbolCubeRoot, expectedAtomCount: 1) { label in
        #expect(label.mathList.atoms.first?.type == .radical)
      },
      .init(input: "()", expectedAtomCount: 2) { label in
        #expect(label.mathList.atoms.first?.nucleus == "(")
        #expect(label.mathList.atoms.last?.nucleus == ")")
      },
      .init(input: "||", expectedAtomCount: 2) { label in
        #expect(label.mathList.atoms.first?.nucleus == "|")
        #expect(label.mathList.atoms.last?.nucleus == "|")
      },
    ]

    for testCase in cases {
      let label = makeLabelWithNilInsertionIndex()
      label.insertText(testCase.input)

      #expect(label.mathList.atoms.count == testCase.expectedAtomCount)
      testCase.assertResult(label)
    }
  }
}
