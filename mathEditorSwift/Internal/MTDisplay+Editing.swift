//
//  MTDisplay+Editing.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

import CoreText
import Foundation
import iosMath

private let invalidPosition = CGPoint(x: -1, y: -1)
private let pixelDelta: CGFloat = 2

private func codePointIndexToStringIndex(_ str: String, _ codePointIndex: UInt) -> Int {
  let utf16 = Array(str.utf16)
  var codePointCount: UInt = 0
  var i = 0

  while i < utf16.count {
    if codePointCount == codePointIndex {
      return i
    }
    codePointCount += 1

    let c = utf16[i]
    if CFStringIsSurrogateHighCharacter(c) || CFStringIsSurrogateLowCharacter(c) {
      i += 1
    }
    i += 1
  }

  return NSNotFound
}

private func distanceFromPointToRect(_ point: CGPoint, _ rect: CGRect) -> CGFloat {
  var distance: CGFloat = 0

  if point.x < rect.origin.x {
    distance += rect.origin.x - point.x
  } else if point.x > rect.maxX {
    distance += point.x - rect.maxX
  }

  if point.y < rect.origin.y {
    distance += rect.origin.y - point.y
  } else if point.y > rect.maxY {
    distance += point.y - rect.maxY
  }

  return distance
}

extension MTDisplay {
  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    nil
  }

  @objc(caretPositionForIndex:)
  public func caretPosition(for index: MTMathListIndex) -> CGPoint {
    invalidPosition
  }

  @objc(highlightCharacterAtIndex:color:)
  public func highlightCharacter(at index: MTMathListIndex, color: MTColor) {}

  @objc(highlightWithColor:)
  public func highlight(with color: MTColor) {}
}

extension MTCTLineDisplay {
  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    let relativePoint = CGPoint(x: point.x - position.x, y: point.y - position.y)
    let idx = CTLineGetStringIndexForPosition(line, relativePoint)
    if idx == kCFNotFound {
      return nil
    }

    let mlIndex = convertToMathListIndex(UInt(idx))
    assert(mlIndex <= UInt(range.length), "Returned index out of range: \(idx)")
    return MTMathListIndex.level0Index(UInt(range.location) + mlIndex)
  }

  @objc(caretPositionForIndex:)
  public func caretPosition(for index: MTMathListIndex) -> CGPoint {
    assert(index.subIndexType == .subIndexTypeNone, "Index in a CTLineDisplay cannot have sub indexes.")

    let offset: CGFloat
    if Int(index.atomIndex) == NSMaxRange(range) {
      offset = width
    } else {
      assert(NSLocationInRange(Int(index.atomIndex), range), "Index not in range")
      let strIndex = mathListIndexToStringIndex(index.atomIndex - UInt(range.location))
      offset = CTLineGetOffsetForStringIndex(line, strIndex, nil)
    }

    return CGPoint(x: position.x + offset, y: position.y)
  }

  @objc(highlightCharacterAtIndex:color:)
  public func highlightCharacter(at index: MTMathListIndex, color: MTColor) {
    assert(NSLocationInRange(Int(index.atomIndex), range))
    assert(index.subIndexType == .subIndexTypeNone || index.subIndexType == .subIndexTypeNucleus)

    if index.subIndexType == .subIndexTypeNucleus {
      assertionFailure("Nucleus highlighting not supported yet")
    }

    let charIndex = codePointIndexToStringIndex(attributedString.string, index.atomIndex - UInt(range.location))
    assert(charIndex != NSNotFound)

    let attrStr = NSMutableAttributedString(attributedString: attributedString)
    let seqRange = (attrStr.string as NSString).rangeOfComposedCharacterSequence(at: charIndex)
    attrStr.addAttribute(kCTForegroundColorAttributeName as NSAttributedString.Key,
                         value: color.cgColor,
                         range: seqRange)
    attributedString = attrStr
  }

  @objc(highlightWithColor:)
  public func highlight(with color: MTColor) {
    let attrStr = NSMutableAttributedString(attributedString: attributedString)
    attrStr.addAttribute(kCTForegroundColorAttributeName as NSAttributedString.Key,
                         value: color.cgColor,
                         range: NSRange(location: 0, length: attrStr.length))
    attributedString = attrStr
  }

  @objc(convertToMathListIndex:)
  public func convertToMathListIndex(_ strIndex: UInt) -> UInt {
    var strLenCovered: UInt = 0
    for mlIndex in 0..<atoms.count {
      if strLenCovered >= strIndex {
        return UInt(mlIndex)
      }
      guard let atom = atoms[mlIndex] as? MTMathAtom else { continue }
      strLenCovered += UInt(atom.nucleus.count)
    }
    assert(strLenCovered >= strIndex, "StrIndex should not be more than the len covered")
    return UInt(atoms.count)
  }

  @objc(mathListIndexToStringIndex:)
  public func mathListIndexToStringIndex(_ mlIndex: UInt) -> Int {
    assert(mlIndex < UInt(atoms.count), "Index not in range")

    var strIndex = 0
    for i in 0..<Int(mlIndex) {
      guard let atom = atoms[i] as? MTMathAtom else { continue }
      strIndex += atom.nucleus.count
    }
    return strIndex
  }
}

extension MTFractionDisplay {
  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    if point.x < position.x - pixelDelta {
      return MTMathListIndex.level0Index(UInt(range.location))
    } else if point.x > position.x + width + pixelDelta {
      return MTMathListIndex.level0Index(UInt(NSMaxRange(range)))
    } else {
      let numeratorDistance = distanceFromPointToRect(point, numerator.displayBounds)
      let denominatorDistance = distanceFromPointToRect(point, denominator.displayBounds)
      if numeratorDistance < denominatorDistance {
        return MTMathListIndex(atLocation: UInt(range.location),
                               withSubIndex: numerator.closestIndex(to: point),
                               type: .subIndexTypeNumerator)
      } else {
        return MTMathListIndex(atLocation: UInt(range.location),
                               withSubIndex: denominator.closestIndex(to: point),
                               type: .subIndexTypeDenominator)
      }
    }
  }

  @objc(caretPositionForIndex:)
  public func caretPosition(for index: MTMathListIndex) -> CGPoint {
    assert(index.subIndexType == .subIndexTypeNone)
    return CGPoint(x: position.x, y: position.y)
  }

  @objc(highlightCharacterAtIndex:color:)
  public func highlightCharacter(at index: MTMathListIndex, color: MTColor) {
    assert(index.subIndexType == .subIndexTypeNone)
    highlight(with: color)
  }

  @objc(highlightWithColor:)
  public func highlight(with color: MTColor) {
    numerator.highlight(with: color)
    denominator.highlight(with: color)
  }

  @objc(subAtomForIndexType:)
  public func subAtom(forIndexType type: MTMathListSubIndexType) -> MTMathListDisplay? {
    switch type {
    case .subIndexTypeNumerator:
      return numerator
    case .subIndexTypeDenominator:
      return denominator
    default:
      assertionFailure("Not a fraction subtype \(type.rawValue)")
      return nil
    }
  }
}

extension MTRadicalDisplay {
  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    if point.x < position.x - pixelDelta {
      return MTMathListIndex.level0Index(UInt(range.location))
    } else if point.x > position.x + width + pixelDelta {
      return MTMathListIndex.level0Index(UInt(NSMaxRange(range)))
    } else {
      let degreeDistance = distanceFromPointToRect(point, degree.displayBounds)
      let radicandDistance = distanceFromPointToRect(point, radicand.displayBounds)

      if degreeDistance < radicandDistance {
        return MTMathListIndex(atLocation: UInt(range.location),
                               withSubIndex: degree.closestIndex(to: point),
                               type: .subIndexTypeDegree)
      } else {
        return MTMathListIndex(atLocation: UInt(range.location),
                               withSubIndex: radicand.closestIndex(to: point),
                               type: .subIndexTypeRadicand)
      }
    }
  }

  @objc(caretPositionForIndex:)
  public func caretPosition(for index: MTMathListIndex) -> CGPoint {
    assert(index.subIndexType == .subIndexTypeNone)
    return CGPoint(x: position.x, y: position.y)
  }

  @objc(highlightCharacterAtIndex:color:)
  public func highlightCharacter(at index: MTMathListIndex, color: MTColor) {
    assert(index.subIndexType == .subIndexTypeNone)
    highlight(with: color)
  }

  @objc(highlightWithColor:)
  public func highlight(with color: MTColor) {
    radicand.highlight(with: color)
  }

  @objc(subAtomForIndexType:)
  public func subAtom(forIndexType type: MTMathListSubIndexType) -> MTMathListDisplay? {
    switch type {
    case .subIndexTypeRadicand:
      return radicand
    case .subIndexTypeDegree:
      return degree
    default:
      assertionFailure("Not a radical subtype \(type.rawValue)")
      return nil
    }
  }
}

extension MTMathListDisplay {
  @objc(closestIndexToPoint:)
  public func closestIndex(to point: CGPoint) -> MTMathListIndex? {
    let translatedPoint = CGPoint(x: point.x - position.x, y: point.y - position.y)

    var closest: MTDisplay?
    var xbounds = [MTDisplay]()
    var minDistance = CGFloat.greatestFiniteMagnitude

    for atom in subDisplays {
      let bounds = atom.displayBounds
      if bounds.origin.x - pixelDelta <= translatedPoint.x && translatedPoint.x <= bounds.maxX + pixelDelta {
        xbounds.append(atom)
      }

      let distance = distanceFromPointToRect(translatedPoint, bounds)
      if distance < minDistance {
        closest = atom
        minDistance = distance
      }
    }

    let atomWithPoint: MTDisplay?
    if xbounds.isEmpty {
      if translatedPoint.x <= -pixelDelta {
        return MTMathListIndex.level0Index(UInt(range.location))
      } else if translatedPoint.x >= width + pixelDelta {
        return MTMathListIndex.level0Index(UInt(NSMaxRange(range)))
      } else {
        atomWithPoint = closest
      }
    } else if xbounds.count == 1 {
      atomWithPoint = xbounds[0]
      if translatedPoint.x >= width - pixelDelta,
         translatedPoint.y <= atomWithPoint!.displayBounds.minY - pixelDelta {
        return MTMathListIndex.level0Index(UInt(NSMaxRange(range)))
      }
    } else {
      atomWithPoint = closest
    }

    guard let atomWithPoint else { return nil }

    let index = atomWithPoint.closestIndex(to: translatedPoint)

    if let closestLine = atomWithPoint as? MTMathListDisplay {
      assert(closestLine.type == .linePositionSubscript || closestLine.type == .linePositionSuperscript,
             "MTLine type regular inside an MTLine - shouldn't happen")
      let type: MTMathListSubIndexType = (closestLine.type == .linePositionSubscript) ? .subIndexTypeSubscript : .subIndexTypeSuperscript
      let lineIndex = Int(closestLine.index)
      guard lineIndex != NSNotFound else { return nil }
      return MTMathListIndex(atLocation: UInt(lineIndex), withSubIndex: index, type: type)
    } else if atomWithPoint.hasScript, let index {
      if Int(index.atomIndex) == NSMaxRange(atomWithPoint.range) {
        return MTMathListIndex(atLocation: index.atomIndex - 1,
                               withSubIndex: MTMathListIndex.level0Index(1),
                               type: .subIndexTypeNucleus)
      }
    }

    return index
  }

  @objc(subAtomForIndex:)
  public func subAtom(for index: MTMathListIndex) -> MTDisplay? {
    if index.subIndexType == .subIndexTypeSuperscript || index.subIndexType == .subIndexTypeSubscript {
      for atom in subDisplays {
        if let lineAtom = atom as? MTMathListDisplay,
           Int(index.atomIndex) == Int(lineAtom.index) {
          if (lineAtom.type == .linePositionSubscript && index.subIndexType == .subIndexTypeSubscript)
              || (lineAtom.type == .linePositionSuperscript && index.subIndexType == .subIndexTypeSuperscript) {
            return lineAtom
          }
        }
      }
    } else {
      for atom in subDisplays {
        if !(atom is MTMathListDisplay) && NSLocationInRange(Int(index.atomIndex), atom.range) {
          switch index.subIndexType {
          case .subIndexTypeNone, .subIndexTypeNucleus:
            return atom

          case .subIndexTypeDegree, .subIndexTypeRadicand:
            if let radical = atom as? MTRadicalDisplay {
              return radical.subAtom(forIndexType: index.subIndexType)
            }
            return nil

          case .subIndexTypeNumerator, .subIndexTypeDenominator:
            if let frac = atom as? MTFractionDisplay {
              return frac.subAtom(forIndexType: index.subIndexType)
            }
            return nil

          case .subIndexTypeSubscript, .subIndexTypeSuperscript, .subIndexTypeInner:
            assertionFailure("Unexpected index type for this path")
            return nil

          @unknown default:
            return nil
          }
        }
      }
    }
    return nil
  }

  @objc(caretPositionForIndex:)
  public func caretPosition(for index: MTMathListIndex) -> CGPoint {
    var pos = invalidPosition

    if Int(index.atomIndex) == NSMaxRange(range) {
      pos = CGPoint(x: width, y: 0)
    } else if NSLocationInRange(Int(index.atomIndex), range) {
      guard let atom = subAtom(for: index) else { return invalidPosition }
      if index.subIndexType == .subIndexTypeNucleus {
        guard let subIndex = index.sub else { return invalidPosition }
        let nucleusPosition = index.atomIndex + subIndex.atomIndex
        pos = atom.caretPosition(for: MTMathListIndex.level0Index(nucleusPosition))
      } else if index.subIndexType == .subIndexTypeNone {
        pos = atom.caretPosition(for: index)
      } else {
        guard let subIndex = index.sub else { return invalidPosition }
        pos = atom.caretPosition(for: subIndex)
      }
    } else {
      return invalidPosition
    }

    if pos == invalidPosition {
      return pos
    }

    return CGPoint(x: pos.x + position.x, y: pos.y + position.y)
  }

  @objc(highlightCharacterAtIndex:color:)
  public func highlightCharacter(at index: MTMathListIndex, color: MTColor) {
    if NSLocationInRange(Int(index.atomIndex), range), let atom = subAtom(for: index) {
      if index.subIndexType == .subIndexTypeNucleus || index.subIndexType == .subIndexTypeNone {
        atom.highlightCharacter(at: index, color: color)
      } else if let subIndex = index.sub {
        atom.highlightCharacter(at: subIndex, color: color)
      }
    }
  }

  @objc(highlightWithColor:)
  public func highlight(with color: MTColor) {
    for atom in subDisplays {
      atom.highlight(with: color)
    }
  }
}
