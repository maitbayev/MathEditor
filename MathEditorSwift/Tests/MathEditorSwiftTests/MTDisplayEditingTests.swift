import CoreGraphics
import Testing
@testable import MathEditorSwift
import iosMath

struct MTDisplayEditingTests {
  private let font: MTFont = MTFontManager().latinModernFont(withSize: 20)

  private struct ClosestIndexCase {
    let point: CGPoint
    let expected: MTMathListIndex
  }

  private func assertClosestIndex(
    expression: String,
    cases: [ClosestIndexCase]
  ) {
    let mathList = MTMathListBuilder.build(fromString: expression)
    let displayList = MTTypesetter.createLine(forMathList: mathList, font: font, style: kMTLineStyleDisplay)

    for testCase in cases {
      let actual = displayList?.closestIndex(to: testCase.point)
      #expect(actual?.isEqual(testCase.expected) == true,
              "Index \(String(describing: actual)) does not match \(testCase.expected) for point \(testCase.point)")
    }
  }

  @Test("closest index for fraction")
  func closestPointFraction() {
    assertClosestIndex(expression: "\\frac{3}{2}", cases: fractionCases)
  }

  @Test("closest index for regular expression")
  func closestPointRegular() {
    assertClosestIndex(expression: "4+2", cases: regularCases)
  }

  @Test("closest index for regular plus fraction")
  func closestPointRegularPlusFraction() {
    assertClosestIndex(expression: "1+\\frac{3}{2}", cases: regularPlusFractionCases)
  }

  @Test("closest index for fraction plus regular")
  func closestPointFractionPlusRegular() {
    assertClosestIndex(expression: "\\frac{3}{2}+1", cases: fractionPlusRegularCases)
  }

  @Test("closest index for exponent")
  func closestPointExponent() {
    assertClosestIndex(expression: "2^3", cases: exponentCases)
  }
}

private let fractionCases: [MTDisplayEditingTests.ClosestIndexCase] = [
  .init(point: CGPoint(x: -10, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: -2.5, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: -2.5, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: -2.5, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: -2.5, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: -1, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: -1, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: -1, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: -1, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 3, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 3, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 3, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 3, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 7, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 7, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 7, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 7, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 11, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 11, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 11, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 11, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 12.5, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 12.5, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 12.5, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 12.5, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 20, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 20, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 20, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 20, y: -20), expected: .level0Index(1)),
]

private let regularCases: [MTDisplayEditingTests.ClosestIndexCase] = [
  .init(point: CGPoint(x: -10, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: 10, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 10, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 10, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 10, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 25, y: 0), expected: .level0Index(2)),
  .init(point: CGPoint(x: 25, y: 8), expected: .level0Index(2)),
  .init(point: CGPoint(x: 25, y: 40), expected: .level0Index(2)),
  .init(point: CGPoint(x: 25, y: -20), expected: .level0Index(2)),
  .init(point: CGPoint(x: 35, y: 0), expected: .level0Index(2)),
  .init(point: CGPoint(x: 35, y: 8), expected: .level0Index(2)),
  .init(point: CGPoint(x: 35, y: 40), expected: .level0Index(2)),
  .init(point: CGPoint(x: 35, y: -20), expected: .level0Index(2)),
  .init(point: CGPoint(x: 45, y: 0), expected: .level0Index(3)),
  .init(point: CGPoint(x: 45, y: 8), expected: .level0Index(3)),
  .init(point: CGPoint(x: 45, y: 40), expected: .level0Index(3)),
  .init(point: CGPoint(x: 45, y: -20), expected: .level0Index(3)),
  .init(point: CGPoint(x: 55, y: 0), expected: .level0Index(3)),
  .init(point: CGPoint(x: 55, y: 8), expected: .level0Index(3)),
  .init(point: CGPoint(x: 55, y: 40), expected: .level0Index(3)),
  .init(point: CGPoint(x: 55, y: -20), expected: .level0Index(3)),
]

private let regularPlusFractionCases: [MTDisplayEditingTests.ClosestIndexCase] = [
  .init(point: CGPoint(x: 30, y: 0), expected: .level0Index(2)),
  .init(point: CGPoint(x: 30, y: 8), expected: .level0Index(2)),
  .init(point: CGPoint(x: 30, y: 40), expected: .level0Index(2)),
  .init(point: CGPoint(x: 30, y: -20), expected: .level0Index(2)),
  .init(point: CGPoint(x: 32, y: 0), expected: .level0Index(2)),
  .init(point: CGPoint(x: 32, y: 8), expected: .level0Index(2)),
  .init(point: CGPoint(x: 32, y: 40), expected: .level0Index(2)),
  .init(point: CGPoint(x: 32, y: -20), expected: .level0Index(2)),
  .init(point: CGPoint(x: 33, y: 0), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 33, y: 8), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 33, y: 40), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 33, y: -20), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 35, y: 0), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 35, y: 8), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 35, y: 40), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 35, y: -20), expected: MTMathListIndex(atLocation: 2, withSubIndex: .level0Index(0), type: .subIndexTypeDenominator)),
]

private let fractionPlusRegularCases: [MTDisplayEditingTests.ClosestIndexCase] = [
  .init(point: CGPoint(x: 15, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 15, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 13, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 13, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 13, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 13, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 11, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 11, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 11, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 11, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 9, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
  .init(point: CGPoint(x: 9, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 9, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNumerator)),
  .init(point: CGPoint(x: 9, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeDenominator)),
]

private let exponentCases: [MTDisplayEditingTests.ClosestIndexCase] = [
  .init(point: CGPoint(x: -10, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: -10, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 0), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 8), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: 40), expected: .level0Index(0)),
  .init(point: CGPoint(x: 0, y: -20), expected: .level0Index(0)),
  .init(point: CGPoint(x: 9, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 9, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 9, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 9, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 10, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 10, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 10, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 10, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 11, y: 0), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 11, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 11, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(0), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 11, y: -20), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeNucleus)),
  .init(point: CGPoint(x: 17, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 17, y: 8), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 17, y: 40), expected: MTMathListIndex(atLocation: 0, withSubIndex: .level0Index(1), type: .subIndexTypeSuperscript)),
  .init(point: CGPoint(x: 17, y: -20), expected: .level0Index(1)),
  .init(point: CGPoint(x: 30, y: 0), expected: .level0Index(1)),
  .init(point: CGPoint(x: 30, y: 8), expected: .level0Index(1)),
  .init(point: CGPoint(x: 30, y: 40), expected: .level0Index(1)),
  .init(point: CGPoint(x: 30, y: -20), expected: .level0Index(1)),
]
