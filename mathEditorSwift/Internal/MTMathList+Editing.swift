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
    if index.atomIndex > atoms.count {
      let exception = NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      )
      exception.raise()
      return
    }

    switch index.subIndexType {
    case .none:
      insert(atom, at: index.atomIndex)

    case .nucleus:
      guard let currentAtom = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fusion is not supported if there are no subscripts or superscripts.")
      assert(atom.subScript == nil && atom.superScript == nil,
             "Cannot fuse with an atom that already has a subscript or a superscript")

      atom.subScript = currentAtom.subScript
      atom.superScript = currentAtom.superScript
      currentAtom.subScript = nil
      currentAtom.superScript = nil
      insert(atom, at: index.atomIndex + index.subIndex.atomIndex)

    case .degree, .radicand:
      guard let radical = atoms[index.atomIndex] as? MTRadical, radical.type == .radical else {
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }
      if index.subIndexType == .degree {
        radical.degree.insert(atom, atListIndex: index.subIndex)
      } else {
        radical.radicand.insert(atom, atListIndex: index.subIndex)
      }

    case .denominator, .numerator:
      guard let frac = atoms[index.atomIndex] as? MTFraction, frac.type == .fraction else {
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }
      if index.subIndexType == .numerator {
        frac.numerator.insert(atom, atListIndex: index.subIndex)
      } else {
        frac.denominator.insert(atom, atListIndex: index.subIndex)
      }

    case .subscript:
      guard let current = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      current.subScript?.insert(atom, atListIndex: index.subIndex)

    case .superscript:
      guard let current = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      current.superScript?.insert(atom, atListIndex: index.subIndex)

    @unknown default:
      break
    }
  }

  @objc(removeAtomAtListIndex:)
  public func removeAtom(atListIndex index: MTMathListIndex) {
    if index.atomIndex >= atoms.count {
      let exception = NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      )
      exception.raise()
      return
    }

    switch index.subIndexType {
    case .none:
      removeAtom(at: index.atomIndex)

    case .nucleus:
      guard let currentAtom = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fission is not supported if there are no subscripts or superscripts.")
      var previous: MTMathAtom?
      if index.atomIndex > 0 {
        previous = atoms[index.atomIndex - 1] as? MTMathAtom
      }
      if let previous,
         previous.subScript == nil,
         previous.superScript == nil {
        previous.superScript = currentAtom.superScript
        previous.subScript = currentAtom.subScript
        removeAtom(at: index.atomIndex)
      } else {
        currentAtom.nucleus = ""
      }

    case .radicand, .degree:
      guard let radical = atoms[index.atomIndex] as? MTRadical, radical.type == .radical else {
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }
      if index.subIndexType == .degree {
        radical.degree.removeAtom(atListIndex: index.subIndex)
      } else {
        radical.radicand.removeAtom(atListIndex: index.subIndex)
      }

    case .denominator, .numerator:
      guard let frac = atoms[index.atomIndex] as? MTFraction, frac.type == .fraction else {
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }
      if index.subIndexType == .numerator {
        frac.numerator.removeAtom(atListIndex: index.subIndex)
      } else {
        frac.denominator.removeAtom(atListIndex: index.subIndex)
      }

    case .subscript:
      guard let current = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      current.subScript?.removeAtom(atListIndex: index.subIndex)

    case .superscript:
      guard let current = atoms[index.atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      current.superScript?.removeAtom(atListIndex: index.subIndex)

    @unknown default:
      break
    }
  }

  @objc(removeAtomsInListIndexRange:)
  public func removeAtoms(inListIndexRange range: MTMathListRange) {
    let start = range.start

    switch start.subIndexType {
    case .none:
      removeAtoms(in: NSRange(location: start.atomIndex, length: range.length))

    case .nucleus:
      assertionFailure("Nuclear fission is not supported")

    case .radicand, .degree:
      guard let radical = atoms[start.atomIndex] as? MTRadical, radical.type == .radical else {
        assertionFailure("No radical found at index \(start.atomIndex)")
        return
      }
      if start.subIndexType == .degree {
        radical.degree.removeAtoms(inListIndexRange: range.subIndexRange)
      } else {
        radical.radicand.removeAtoms(inListIndexRange: range.subIndexRange)
      }

    case .denominator, .numerator:
      guard let frac = atoms[start.atomIndex] as? MTFraction, frac.type == .fraction else {
        assertionFailure("No fraction found at index \(start.atomIndex)")
        return
      }
      if start.subIndexType == .numerator {
        frac.numerator.removeAtoms(inListIndexRange: range.subIndexRange)
      } else {
        frac.denominator.removeAtoms(inListIndexRange: range.subIndexRange)
      }

    case .subscript:
      guard let current = atoms[start.atomIndex] as? MTMathAtom else { return }
      assert(current.subScript != nil, "No subscript for atom at index \(start.atomIndex)")
      current.subScript?.removeAtoms(inListIndexRange: range.subIndexRange)

    case .superscript:
      guard let current = atoms[start.atomIndex] as? MTMathAtom else { return }
      assert(current.superScript != nil, "No superscript for atom at index \(start.atomIndex)")
      current.superScript?.removeAtoms(inListIndexRange: range.subIndexRange)

    @unknown default:
      break
    }
  }

  @objc(atomAtListIndex:)
  public func atom(atListIndex index: MTMathListIndex?) -> MTMathAtom? {
    guard let index else { return nil }
    guard index.atomIndex < atoms.count else { return nil }
    guard let atom = atoms[index.atomIndex] as? MTMathAtom else { return nil }

    switch index.subIndexType {
    case .none, .nucleus:
      return atom

    case .subscript:
      return atom.subScript?.atom(atListIndex: index.subIndex)

    case .superscript:
      return atom.superScript?.atom(atListIndex: index.subIndex)

    case .radicand, .degree:
      guard let radical = atom as? MTRadical, atom.type == .radical else {
        return nil
      }
      if index.subIndexType == .degree {
        return radical.degree.atom(atListIndex: index.subIndex)
      } else {
        return radical.radicand.atom(atListIndex: index.subIndex)
      }

    case .numerator, .denominator:
      guard let frac = atom as? MTFraction, atom.type == .fraction else {
        return nil
      }
      if index.subIndexType == .denominator {
        return frac.denominator.atom(atListIndex: index.subIndex)
      } else {
        return frac.numerator.atom(atListIndex: index.subIndex)
      }

    @unknown default:
      return nil
    }
  }
}
