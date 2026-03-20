//
//  NSObject+MTEditableMathLabel_UITextInput.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MTEditableMathLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTEditableMathLabel () <UITextInput>
@end

@implementation MTEditableMathLabel (UITextInput)

// These are blank just to get a UITextInput implementation, to fix the dictation button bug.
// Proposed fix from: http://stackoverflow.com/questions/20980898/work-around-for-dictation-custom-text-view-bug

//@synthesize beginningOfDocument;@
//@synthesize endOfDocument;
//@synthesize inputDelegate;
//@synthesize markedTextRange;
//@synthesize markedTextStyle;
//@synthesize selectedTextRange;
//@synthesize tokenizer;

- (nullable UITextRange *)selectedTextRange
{
    return objc_getAssociatedObject(self, @selector(selectedTextRange));
}
- (void)setSelectedTextRange:(nullable UITextRange *)selectedTextRange
{
    objc_setAssociatedObject(self, @selector(selectedTextRange), selectedTextRange, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable id<UITextInputDelegate>)inputDelegate
{
    id (^block)(void) = objc_getAssociatedObject(self, @selector(inputDelegate));
    return block ? block() : nil;
}

- (void)setInputDelegate:(nullable id<UITextInputDelegate>)inputDelegate
{
    __weak id<UITextInputDelegate> weakDelegate = inputDelegate;
    id (^block)(void) = ^{
      return weakDelegate;
    };
    objc_setAssociatedObject(self, @selector(inputDelegate), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable UITextRange *)markedTextRange
{
    return objc_getAssociatedObject(self, @selector(markedTextRange));
}

- (nullable NSDictionary *)markedTextStyle
{
    return objc_getAssociatedObject(self, @selector(markedTextStyle));
}
- (void)setMarkedTextStyle:(nullable NSDictionary *)markedTextStyle
{
    objc_setAssociatedObject(self, @selector(markedTextStyle), markedTextStyle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UITextPosition *)beginningOfDocument
{
    return objc_getAssociatedObject(self, @selector(beginningOfDocument));
}

- (UITextPosition *)endOfDocument
{
    return objc_getAssociatedObject(self, @selector(endOfDocument));
}

- (id<UITextInputTokenizer>)tokenizer
{
    id<UITextInputTokenizer> tokenizer = objc_getAssociatedObject(self, @selector(tokenizer));
    if (!tokenizer) {
        tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
        objc_setAssociatedObject(self, @selector(tokenizer), tokenizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tokenizer;
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position
                                              inDirection:(UITextStorageDirection)direction
{
    return UITextWritingDirectionLeftToRight;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

- (void)unmarkText
{
}

- (nullable UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    return nil;
}
- (nullable UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                                inDirection:(UITextLayoutDirection)direction
{
    return nil;
}
- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    return nil;
}
- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
    return nil;
}
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return NSOrderedSame;
}
- (void)dictationRecognitionFailed
{
}
- (void)dictationRecordingDidEnd
{
}
- (CGRect)firstRectForRange:(UITextRange *)range
{
    return CGRectZero;
}

- (CGRect)frameForDictationResultPlaceholder:(id)placeholder
{
    return CGRectZero;
}
- (void)insertDictationResult:(NSArray *)dictationResult
{
}
- (id)insertDictationResultPlaceholder
{
    return nil;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return 0;
}
- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position
                                      inDirection:(UITextLayoutDirection)direction
                                           offset:(NSInteger)offset
{
    return nil;
}
- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    return nil;
}

- (nullable UITextPosition *)positionWithinRange:(UITextRange *)range
                             farthestInDirection:(UITextLayoutDirection)direction
{
    return nil;
}
- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult
{
}
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
}
- (NSArray *)selectionRectsForRange:(UITextRange *)range
{
    return nil;
}
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
}
- (void)setMarkedText:(nullable NSString *)markedText selectedRange:(NSRange)selectedRange
{
}

- (nullable NSString *)textInRange:(UITextRange *)range
{
    return nil;
}
- (nullable UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return nil;
}

#pragma mark - UITextInputTraits

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeNo;
}

- (UIReturnKeyType)returnKeyType
{
    return UIReturnKeyDefault;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return UITextSpellCheckingTypeNo;
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeASCIICapable;
}

@end

NS_ASSUME_NONNULL_END

#endif
