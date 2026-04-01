// Switch the implementation under test by toggling these imports.
import MathEditorSwift
import Testing
import iosMath

@MainActor
@Suite(.serialized)
struct MTMathListEditingTests {
  @Test("insert at top level adds an atom at the requested index")
  func insertTopLevelAtom() {
    let mathList = list("1+3")

    mathList.insert(atom("2"), atListIndex: .level0Index(2))

    expectLatex("1+23", from: mathList)
  }

  @Test("insert at nucleus transfers scripts onto the inserted atom")
  func insertAtNucleusTransfersScripts() {
    let mathList = list("x^2")
    mathList.insert(
      atom("y"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeNucleus
      )
    )

    expectLatex("xy^{2}", from: mathList)
  }

  @Test("insert recurses into a fraction numerator")
  func insertIntoFractionNumerator() {
    let mathList = list("\\frac{3}{2}")
    mathList.insert(
      atom("x"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeNumerator
      )
    )

    expectLatex("\\frac{3x}{2}", from: mathList)
  }

  @Test("insert recurses into a radical degree")
  func insertIntoRadicalDegree() {
    let mathList = list("\\sqrt[3]{x}")
    mathList.insert(
      atom("n"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeDegree
      )
    )

    expectLatex("\\sqrt[3n]{x}", from: mathList)
  }

  @Test("insert also recurses into radicands, denominators, subscripts, and superscripts")
  func insertIntoOtherNestedLists() {
    let radicand = list("\\sqrt{x}")
    radicand.insert(
      atom("y"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeRadicand
      )
    )
    expectLatex("\\sqrt{xy}", from: radicand)

    let denominator = list("\\frac{3}{2}")
    denominator.insert(
      atom("x"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeDenominator
      )
    )
    expectLatex("\\frac{3}{2x}", from: denominator)

    let subscriptList = list("x_1")
    subscriptList.insert(
      atom("0"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeSubscript
      )
    )
    expectLatex("x_{10}", from: subscriptList)

    let superscript = list("x^2")
    superscript.insert(
      atom("3"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeSuperscript
      )
    )
    expectLatex("x^{23}", from: superscript)
  }

  @Test("insert is a no-op for inner indices and missing subindices")
  func insertNoOpsForInnerAndMissingSubindices() {
    let inner = list("12")
    inner.insert(
      atom("9"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(0),
        type: .subIndexTypeInner
      )
    )
    expectLatex("12", from: inner)

    let nucleusWithoutSubindex = list("x^2")
    nucleusWithoutSubindex.insert(
      atom("y"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: nil,
        type: .subIndexTypeNucleus
      )
    )
    expectLatex("x^{2}", from: nucleusWithoutSubindex)

    let denominatorWithoutSubindex = list("\\frac{1}{2}")
    denominatorWithoutSubindex.insert(
      atom("3"),
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: nil,
        type: .subIndexTypeDenominator
      )
    )
    expectLatex("\\frac{1}{2}", from: denominatorWithoutSubindex)
  }

  @Test("remove at nucleus fuses scripts into the previous atom when possible")
  func removeAtNucleusFusesIntoPreviousAtom() {
    let mathList = list("xy^2")
    mathList.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 1,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeNucleus
      )
    )

    expectLatex("x^{2}", from: mathList)
  }

  @Test("remove at nucleus empties the current atom when it cannot fuse")
  func removeAtNucleusEmptiesCurrentAtomWhenFusionIsNotPossible() throws {
    let mathList = list("x^2")
    mathList.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeNucleus
      )
    )

    let currentAtom = try #require(mathList.atom(atListIndex: .level0Index(0)))
    #expect(currentAtom.nucleus.isEmpty)
    #expect(currentAtom.superScript != nil)
    expectLatex("{}^{2}", from: mathList)
  }

  @Test(
    "remove atom also recurses through top level, fractions, radicals, subscripts, and superscripts"
  )
  func removeAtomFromOtherNestedLists() {
    let topLevel = list("123")
    topLevel.removeAtom(atListIndex: .level0Index(1))
    expectLatex("13", from: topLevel)

    let numerator = list("\\frac{34}{2}")
    numerator.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeNumerator
      )
    )
    expectLatex("\\frac{3}{2}", from: numerator)

    let degree = list("\\sqrt[34]{x}")
    degree.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeDegree
      )
    )
    expectLatex("\\sqrt[3]{x}", from: degree)

    let radicand = list("\\sqrt{xy}")
    radicand.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeRadicand
      )
    )
    expectLatex("\\sqrt{x}", from: radicand)

    let subscriptList = list("x_{12}")
    subscriptList.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeSubscript
      )
    )
    expectLatex("x_{1}", from: subscriptList)

    let superscript = list("x^{23}")
    superscript.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(1),
        type: .subIndexTypeSuperscript
      )
    )
    expectLatex("x^{2}", from: superscript)
  }

  @Test("remove atom is a no-op for inner indices and missing subindices")
  func removeAtomNoOpsForInnerAndMissingSubindices() {
    let inner = list("12")
    inner.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: .level0Index(0),
        type: .subIndexTypeInner
      )
    )
    expectLatex("12", from: inner)

    let numeratorWithoutSubindex = list("\\frac{12}{3}")
    numeratorWithoutSubindex.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: nil,
        type: .subIndexTypeNumerator
      )
    )
    expectLatex("\\frac{12}{3}", from: numeratorWithoutSubindex)

    let superscriptWithoutSubindex = list("x^2")
    superscriptWithoutSubindex.removeAtom(
      atListIndex: MTMathListIndex(
        atLocation: 0,
        withSubIndex: nil,
        type: .subIndexTypeSuperscript
      )
    )
    expectLatex("x^{2}", from: superscriptWithoutSubindex)
  }

  @Test("remove atoms recurses into a denominator range")
  func removeAtomsFromDenominatorRange() {
    let mathList = list("\\frac{12}{345}")
    mathList.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeDenominator
        ),
        length: 2
      )
    )

    expectLatex("\\frac{12}{3}", from: mathList)
  }

  @Test("remove atoms also supports top level, numerators, radicals, subscripts, and superscripts")
  func removeAtomsFromOtherRanges() {
    let topLevel = list("1234")
    topLevel.removeAtoms(inListIndexRange: .make(.level0Index(1), length: 2))
    expectLatex("14", from: topLevel)

    let numerator = list("\\frac{123}{45}")
    numerator.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeNumerator
        ),
        length: 2
      )
    )
    expectLatex("\\frac{1}{45}", from: numerator)

    let degree = list("\\sqrt[123]{x}")
    degree.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeDegree
        ),
        length: 2
      )
    )
    expectLatex("\\sqrt[1]{x}", from: degree)

    let radicand = list("\\sqrt{xyz}")
    radicand.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeRadicand
        ),
        length: 2
      )
    )
    expectLatex("\\sqrt{x}", from: radicand)

    let subscriptList = list("x_{123}")
    subscriptList.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeSubscript
        ),
        length: 2
      )
    )
    expectLatex("x_{1}", from: subscriptList)

    let superscript = list("x^{123}")
    superscript.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(1),
          type: .subIndexTypeSuperscript
        ),
        length: 2
      )
    )
    expectLatex("x^{1}", from: superscript)
  }

  @Test("remove atoms is a no-op for inner indices")
  func removeAtomsNoOpForInnerIndex() {
    let inner = list("123")
    inner.removeAtoms(
      inListIndexRange: .make(
        MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeInner
        ),
        length: 1
      )
    )
    expectLatex("123", from: inner)
  }

  @Test("atom at list index resolves nested atoms")
  func atomAtListIndexResolvesNestedAtoms() throws {
    let mathList = list("\\sqrt[3]{x_2}+y")

    let degree = try #require(
      mathList.atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeDegree
        ))
    )
    #expect(degree.nucleus == "3")

    let subscriptAtom = try #require(
      mathList.atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: MTMathListIndex(
            atLocation: 0,
            withSubIndex: .level0Index(0),
            type: .subIndexTypeSubscript
          ),
          type: .subIndexTypeRadicand
        ))
    )
    #expect(subscriptAtom.nucleus == "2")

    let superscriptAtom = try #require(
      mathList.atom(
        atListIndex: MTMathListIndex(
          atLocation: 2,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeNucleus
        ))
    )
    #expect(superscriptAtom.nucleus == "y")

    #expect(mathList.atom(atListIndex: .level0Index(99)) == nil)
    #expect(mathList.atom(atListIndex: nil) == nil)
  }

  @Test(
    "atom at list index also resolves fraction and superscript atoms and returns nil for the wrong container type"
  )
  func atomAtListIndexCoversRemainingContainerTypes() throws {
    let mathList = list("\\frac{1}{x^2}")

    let numerator = try #require(
      mathList.atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeNumerator
        ))
    )
    #expect(numerator.nucleus == "1")

    let superscript = try #require(
      mathList.atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: MTMathListIndex(
            atLocation: 0,
            withSubIndex: .level0Index(0),
            type: .subIndexTypeSuperscript
          ),
          type: .subIndexTypeDenominator
        ))
    )
    #expect(superscript.nucleus == "2")

    #expect(
      list("x").atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeNumerator
        )) == nil
    )
    #expect(
      list("x").atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeDegree
        )) == nil
    )
  }

  @Test("atom at list index returns nil for inner indices and missing subindices")
  func atomAtListIndexReturnsNilForInnerAndMissingSubindices() {
    #expect(
      list("x").atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: .level0Index(0),
          type: .subIndexTypeInner
        )) == nil
    )

    #expect(
      list("x^2").atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: nil,
          type: .subIndexTypeSuperscript
        )) == nil
    )

    #expect(
      list("\\frac{1}{2}").atom(
        atListIndex: MTMathListIndex(
          atLocation: 0,
          withSubIndex: nil,
          type: .subIndexTypeNumerator
        )) == nil
    )
  }

  @Test
  @MainActor
  func insertOutOfBoundsFail() async throws {
    await #expect(processExitsWith: .failure) {
      let mathList = list("12")
      let _ = mathList.insert(atom("3"), atListIndex: .level0Index(3))
      return
    }
  }
}

private func list(_ latex: String) -> MTMathList {
  MTMathListBuilder.build(from: latex)!
}

private func atom(_ latex: String) -> MTMathAtom {
  list(latex).atoms[0]
}
