//
//  MTMathList+Editing.swift
//  MathEditor
//
//  Created by Madiyar Aitbayev on 24/03/2026.
//

import Foundation
import iosMath

extension MTMathList {
  @objc(insertAtom:atListIndex:)
  public func insert(_ atom: MTMathAtom, atListIndex index: MTMathListIndex) {
    if index.atomIndex > UInt(atoms.count) {
      let exception = NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      )
      exception.raise()
      return
    }

    switch index.subIndexType {
    case .subIndexTypeNone:
      insertAtom(atom, at: index.atomIndex)

    case .subIndexTypeNucleus:
      let atomIndex = Int(index.atomIndex)
      guard let currentAtom = atoms[atomIndex] as? MTMathAtom else { return }
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fusion is not supported if there are no subscripts or superscripts.")
      assert(atom.subScript == nil && atom.superScript == nil,
             "Cannot fuse with an atom that already has a subscript or a superscript")
      guard let subIndex = index.sub else { return }

      atom.subScript = currentAtom.subScript
      atom.superScript = currentAtom.superScript
      currentAtom.subScript = nil
      currentAtom.superScript = nil
      insertAtom(atom, at: index.atomIndex + subIndex.atomIndex)

    case .subIndexTypeDegree, .subIndexTypeRadicand:
      let atomIndex = Int(index.atomIndex)
      guard let radical = atoms[atomIndex] as? MTRadical, radical.type == .radical else {
        // Not radical, quit.
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }
      guard let subIndex = index.sub else { return }
      if index.subIndexType == .subIndexTypeDegree {
        radical.degree?.insert(atom, atListIndex: subIndex)
      } else {
        radical.radicand?.insert(atom, atListIndex: subIndex)
      }

    case .subIndexTypeDenominator, .subIndexTypeNumerator:
      let atomIndex = Int(index.atomIndex)
      guard let frac = atoms[atomIndex] as? MTFraction, frac.type == .fraction else {
        // Not a fraction, quit.
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }
      guard let subIndex = index.sub else { return }
      if index.subIndexType == .subIndexTypeNumerator {
        frac.numerator.insert(atom, atListIndex: subIndex)
      } else {
        frac.denominator.insert(atom, atListIndex: subIndex)
      }

    case .subIndexTypeSubscript:
      let atomIndex = Int(index.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      guard let subIndex = index.sub else { return }
      current.subScript?.insert(atom, atListIndex: subIndex)

    case .subIndexTypeSuperscript:
      let atomIndex = Int(index.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      guard let subIndex = index.sub else { return }
      current.superScript?.insert(atom, atListIndex: subIndex)

    case .subIndexTypeInner:
      break

    @unknown default:
      break
    }
  }

  @objc(removeAtomAtListIndex:)
  public func removeAtom(atListIndex index: MTMathListIndex) {
    if index.atomIndex >= UInt(atoms.count) {
      let exception = NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      )
      exception.raise()
      return
    }

    switch index.subIndexType {
    case .subIndexTypeNone:
      removeAtom(at: index.atomIndex)

    case .subIndexTypeNucleus:
      let atomIndex = Int(index.atomIndex)
      guard let currentAtom = atoms[atomIndex] as? MTMathAtom else { return }
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fission is not supported if there are no subscripts or superscripts.")
      var previous: MTMathAtom?
      if index.atomIndex > 0 {
        previous = atoms[Int(index.atomIndex - 1)] as? MTMathAtom
      }
      if let previous,
         previous.subScript == nil,
         previous.superScript == nil {
        previous.superScript = currentAtom.superScript
        previous.subScript = currentAtom.subScript
        removeAtom(at: index.atomIndex)
      } else {
        // No previous atom, or the previous atom already has a sub/superscript.
        currentAtom.nucleus = ""
      }

    case .subIndexTypeRadicand, .subIndexTypeDegree:
      let atomIndex = Int(index.atomIndex)
      guard let radical = atoms[atomIndex] as? MTRadical, radical.type == .radical else {
        // Not radical, quit.
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }
      guard let subIndex = index.sub else { return }
      if index.subIndexType == .subIndexTypeDegree {
        radical.degree?.removeAtom(atListIndex: subIndex)
      } else {
        radical.radicand?.removeAtom(atListIndex: subIndex)
      }

    case .subIndexTypeDenominator, .subIndexTypeNumerator:
      let atomIndex = Int(index.atomIndex)
      guard let frac = atoms[atomIndex] as? MTFraction, frac.type == .fraction else {
        // Not a fraction, quit.
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }
      guard let subIndex = index.sub else { return }
      if index.subIndexType == .subIndexTypeNumerator {
        frac.numerator.removeAtom(atListIndex: subIndex)
      } else {
        frac.denominator.removeAtom(atListIndex: subIndex)
      }

    case .subIndexTypeSubscript:
      let atomIndex = Int(index.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      guard let subIndex = index.sub else { return }
      current.subScript?.removeAtom(atListIndex: subIndex)

    case .subIndexTypeSuperscript:
      let atomIndex = Int(index.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      guard let subIndex = index.sub else { return }
      current.superScript?.removeAtom(atListIndex: subIndex)

    case .subIndexTypeInner:
      break

    @unknown default:
      break
    }
  }

  @objc(removeAtomsInListIndexRange:)
  public func removeAtoms(inListIndexRange range: MTMathListRange) {
    let start = range.start

    switch start.subIndexType {
    case .subIndexTypeNone:
      removeAtoms(in: NSRange(location: Int(start.atomIndex), length: Int(range.length)))

    case .subIndexTypeNucleus:
      assertionFailure("Nuclear fission is not supported")

    case .subIndexTypeRadicand, .subIndexTypeDegree:
      let atomIndex = Int(start.atomIndex)
      guard let radical = atoms[atomIndex] as? MTRadical, radical.type == .radical else {
        // Not radical, quit.
        assertionFailure("No radical found at index \(start.atomIndex)")
        return
      }
      guard let subIndexRange = range.subIndex() else { return }
      if start.subIndexType == .subIndexTypeDegree {
        radical.degree?.removeAtoms(inListIndexRange: subIndexRange)
      } else {
        radical.radicand?.removeAtoms(inListIndexRange: subIndexRange)
      }

    case .subIndexTypeDenominator, .subIndexTypeNumerator:
      let atomIndex = Int(start.atomIndex)
      guard let frac = atoms[atomIndex] as? MTFraction, frac.type == .fraction else {
        // Not a fraction, quit.
        assertionFailure("No fraction found at index \(start.atomIndex)")
        return
      }
      guard let subIndexRange = range.subIndex() else { return }
      if start.subIndexType == .subIndexTypeNumerator {
        frac.numerator.removeAtoms(inListIndexRange: subIndexRange)
      } else {
        frac.denominator.removeAtoms(inListIndexRange: subIndexRange)
      }

    case .subIndexTypeSubscript:
      let atomIndex = Int(start.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(start.atomIndex)")
      guard let subIndexRange = range.subIndex() else { return }
      current.subScript?.removeAtoms(inListIndexRange: subIndexRange)

    case .subIndexTypeSuperscript:
      let atomIndex = Int(start.atomIndex)
      guard let current = atoms[atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(start.atomIndex)")
      guard let subIndexRange = range.subIndex() else { return }
      current.superScript?.removeAtoms(inListIndexRange: subIndexRange)

    case .subIndexTypeInner:
      break

    @unknown default:
      break
    }
  }

  @objc(atomAtListIndex:)
  public func atom(atListIndex index: MTMathListIndex?) -> MTMathAtom? {
    guard let index else { return nil }
    guard index.atomIndex < UInt(atoms.count) else { return nil }
    guard let atom = atoms[Int(index.atomIndex)] as? MTMathAtom else { return nil }

    switch index.subIndexType {
    case .subIndexTypeNone, .subIndexTypeNucleus:
      return atom

    case .subIndexTypeSubscript:
      guard let subIndex = index.sub else { return nil }
      return atom.subScript?.atom(atListIndex: subIndex)

    case .subIndexTypeSuperscript:
      guard let subIndex = index.sub else { return nil }
      return atom.superScript?.atom(atListIndex: subIndex)

    case .subIndexTypeRadicand, .subIndexTypeDegree:
      guard let radical = atom as? MTRadical, atom.type == .radical else {
        // No radical at this index.
        return nil
      }
      guard let subIndex = index.sub else { return nil }
      if index.subIndexType == .subIndexTypeDegree {
        return radical.degree?.atom(atListIndex: subIndex)
      } else {
        return radical.radicand?.atom(atListIndex: subIndex)
      }

    case .subIndexTypeNumerator, .subIndexTypeDenominator:
      guard let frac = atom as? MTFraction, atom.type == .fraction else {
        // No fraction at this index.
        return nil
      }
      guard let subIndex = index.sub else { return nil }
      if index.subIndexType == .subIndexTypeDenominator {
        return frac.denominator.atom(atListIndex: subIndex)
      } else {
        return frac.numerator.atom(atListIndex: subIndex)
      }

    case .subIndexTypeInner:
      return nil

    @unknown default:
      return nil
    }
  }
}
