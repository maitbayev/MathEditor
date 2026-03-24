import Foundation
import iosMath

@objc
public extension MTMathList {
  @objc(insertAtom:atListIndex:)
  func mtInsertAtom(_ atom: MTMathAtom, atListIndex index: MTMathListIndex) {
    guard index.atomIndex <= atoms.count else {
      NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      ).raise()
      return
    }

    switch index.subIndexType {
    case kMTSubIndexTypeNone:
      insertAtom(atom, at: index.atomIndex)

    case kMTSubIndexTypeNucleus:
      let currentAtom = atoms[index.atomIndex]
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fusion is not supported if there are no subscripts or superscripts.")
      assert(atom.subScript == nil && atom.superScript == nil,
             "Cannot fuse with an atom that already has a subscript or a superscript")

      atom.subScript = currentAtom.subScript
      atom.superScript = currentAtom.superScript
      currentAtom.subScript = nil
      currentAtom.superScript = nil
      insertAtom(atom, at: index.atomIndex + index.subIndex.atomIndex)

    case kMTSubIndexTypeDegree, kMTSubIndexTypeRadicand:
      guard let radical = atoms[index.atomIndex] as? MTRadical else {
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }

      if index.subIndexType == kMTSubIndexTypeDegree {
        radical.degree.mtInsertAtom(atom, atListIndex: index.subIndex)
      } else {
        radical.radicand.mtInsertAtom(atom, atListIndex: index.subIndex)
      }

    case kMTSubIndexTypeDenominator, kMTSubIndexTypeNumerator:
      guard let frac = atoms[index.atomIndex] as? MTFraction else {
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }

      if index.subIndexType == kMTSubIndexTypeNumerator {
        frac.numerator.mtInsertAtom(atom, atListIndex: index.subIndex)
      } else {
        frac.denominator.mtInsertAtom(atom, atListIndex: index.subIndex)
      }

    case kMTSubIndexTypeSubscript:
      let current = atoms[index.atomIndex]
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      current.subScript?.mtInsertAtom(atom, atListIndex: index.subIndex)

    case kMTSubIndexTypeSuperscript:
      let current = atoms[index.atomIndex]
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      current.superScript?.mtInsertAtom(atom, atListIndex: index.subIndex)

    @unknown default:
      assertionFailure("Unsupported subIndexType")
    }
  }

  @objc(removeAtomAtListIndex:)
  func mtRemoveAtom(atListIndex index: MTMathListIndex) {
    guard index.atomIndex < atoms.count else {
      NSException(
        name: .rangeException,
        reason: "Index \(index.atomIndex) is out of bounds for list of size \(atoms.count)",
        userInfo: nil
      ).raise()
      return
    }

    switch index.subIndexType {
    case kMTSubIndexTypeNone:
      removeAtom(at: index.atomIndex)

    case kMTSubIndexTypeNucleus:
      let currentAtom = atoms[index.atomIndex]
      assert(currentAtom.subScript != nil || currentAtom.superScript != nil,
             "Nuclear fission is not supported if there are no subscripts or superscripts.")

      let previous: MTMathAtom? = index.atomIndex > 0 ? atoms[index.atomIndex - 1] : nil
      if let previous, previous.subScript == nil && previous.superScript == nil {
        previous.superScript = currentAtom.superScript
        previous.subScript = currentAtom.subScript
        removeAtom(at: index.atomIndex)
      } else {
        currentAtom.nucleus = ""
      }

    case kMTSubIndexTypeRadicand, kMTSubIndexTypeDegree:
      guard let radical = atoms[index.atomIndex] as? MTRadical else {
        assertionFailure("No radical found at index \(index.atomIndex)")
        return
      }

      if index.subIndexType == kMTSubIndexTypeDegree {
        radical.degree.mtRemoveAtom(atListIndex: index.subIndex)
      } else {
        radical.radicand.mtRemoveAtom(atListIndex: index.subIndex)
      }

    case kMTSubIndexTypeDenominator, kMTSubIndexTypeNumerator:
      guard let frac = atoms[index.atomIndex] as? MTFraction else {
        assertionFailure("No fraction found at index \(index.atomIndex)")
        return
      }

      if index.subIndexType == kMTSubIndexTypeNumerator {
        frac.numerator.mtRemoveAtom(atListIndex: index.subIndex)
      } else {
        frac.denominator.mtRemoveAtom(atListIndex: index.subIndex)
      }

    case kMTSubIndexTypeSubscript:
      let current = atoms[index.atomIndex]
      assert(current.subScript != nil, "No subscript for atom at index \(index.atomIndex)")
      current.subScript?.mtRemoveAtom(atListIndex: index.subIndex)

    case kMTSubIndexTypeSuperscript:
      let current = atoms[index.atomIndex]
      assert(current.superScript != nil, "No superscript for atom at index \(index.atomIndex)")
      current.superScript?.mtRemoveAtom(atListIndex: index.subIndex)

    @unknown default:
      assertionFailure("Unsupported subIndexType")
    }
  }

  @objc(removeAtomsInListIndexRange:)
  func mtRemoveAtoms(inListIndexRange range: MTMathListRange) {
    let start = range.start

    switch start.subIndexType {
    case kMTSubIndexTypeNone:
      removeAtoms(in: NSRange(location: start.atomIndex, length: range.length))

    case kMTSubIndexTypeNucleus:
      assertionFailure("Nuclear fission is not supported")

    case kMTSubIndexTypeRadicand, kMTSubIndexTypeDegree:
      guard let radical = atoms[start.atomIndex] as? MTRadical else {
        assertionFailure("No radical found at index \(start.atomIndex)")
        return
      }

      if start.subIndexType == kMTSubIndexTypeDegree {
        radical.degree.mtRemoveAtoms(inListIndexRange: range.subIndexRange)
      } else {
        radical.radicand.mtRemoveAtoms(inListIndexRange: range.subIndexRange)
      }

    case kMTSubIndexTypeDenominator, kMTSubIndexTypeNumerator:
      guard let frac = atoms[start.atomIndex] as? MTFraction else {
        assertionFailure("No fraction found at index \(start.atomIndex)")
        return
      }

      if start.subIndexType == kMTSubIndexTypeNumerator {
        frac.numerator.mtRemoveAtoms(inListIndexRange: range.subIndexRange)
      } else {
        frac.denominator.mtRemoveAtoms(inListIndexRange: range.subIndexRange)
      }

    case kMTSubIndexTypeSubscript:
      let current = atoms[start.atomIndex]
      assert(current.subScript != nil, "No subscript for atom at index \(start.atomIndex)")
      current.subScript?.mtRemoveAtoms(inListIndexRange: range.subIndexRange)

    case kMTSubIndexTypeSuperscript:
      let current = atoms[start.atomIndex]
      assert(current.superScript != nil, "No superscript for atom at index \(start.atomIndex)")
      current.superScript?.mtRemoveAtoms(inListIndexRange: range.subIndexRange)

    @unknown default:
      assertionFailure("Unsupported subIndexType")
    }
  }

  @objc(atomAtListIndex:)
  func mtAtom(atListIndex index: MTMathListIndex?) -> MTMathAtom? {
    guard let index else { return nil }
    guard index.atomIndex < atoms.count else { return nil }

    let atom = atoms[index.atomIndex]

    switch index.subIndexType {
    case kMTSubIndexTypeNone, kMTSubIndexTypeNucleus:
      return atom

    case kMTSubIndexTypeSubscript:
      return atom.subScript?.mtAtom(atListIndex: index.subIndex)

    case kMTSubIndexTypeSuperscript:
      return atom.superScript?.mtAtom(atListIndex: index.subIndex)

    case kMTSubIndexTypeRadicand, kMTSubIndexTypeDegree:
      guard let radical = atom as? MTRadical else { return nil }
      return index.subIndexType == kMTSubIndexTypeDegree
        ? radical.degree.mtAtom(atListIndex: index.subIndex)
        : radical.radicand.mtAtom(atListIndex: index.subIndex)

    case kMTSubIndexTypeNumerator, kMTSubIndexTypeDenominator:
      guard let frac = atom as? MTFraction else { return nil }
      return index.subIndexType == kMTSubIndexTypeDenominator
        ? frac.denominator.mtAtom(atListIndex: index.subIndex)
        : frac.numerator.mtAtom(atListIndex: index.subIndex)

    @unknown default:
      return nil
    }
  }
}
