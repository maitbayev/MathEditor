//
//  Expectations.swift
//  MathEditorSwift
//
//  Created by Madiyar Aitbayev on 27/03/2026.
//

import Testing
import iosMath

/// Asserts that `MTMathListBuilder` serializes a `MTMathList` back to the expected LaTeX string.
func expectLatex(
  _ expected: String,
  from mathList: MTMathList,
  _ comment: Comment? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) {
  let actual = MTMathListBuilder.mathList(toString: mathList)
  #expect(
    expected == actual,
    comment ?? "LaTeX mismatch:\n  expected: \"\(expected)\"\n    actual: \"\(actual)\"",
    sourceLocation: sourceLocation
  )
}

/// Asserts that a `MTMathList.stringValue` equals the expected string.
func expectStringValue(
  of mathList: MTMathList,
  to expected: String,
  _ comment: Comment? = nil,
  sourceLocation: SourceLocation = #_sourceLocation
) {
  let actual = mathList.stringValue
  #expect(
    expected == actual,
    comment ?? "stringValue mismatch:\n  expected: \"\(expected)\"\n    actual: \"\(actual)\"",
    sourceLocation: sourceLocation
  )
}
