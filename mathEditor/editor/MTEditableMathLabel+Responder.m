//
//  MTEditableMathLabel+UIResponder.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "MTConfig.h"
#import "MTEditableMathLabel.h"
#import "MTView/MTView+FirstResponder.h"
// #import "AppKit/AppKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTEditableMathLabel (Responder)
@end

@implementation MTEditableMathLabel (Responder)

#if TARGET_OS_IPHONE
- (nullable UIView *)inputView
{
    return self.keyboard;
}
#endif // TARGET_OS_IPHONE

/**
 UIResponder protocol override.
 Our view can become first responder to receive user text input.
 */
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    BOOL canBecome = [super becomeFirstResponder];
    if (canBecome) {
        [self doBecomeFirstResponder];
    } else {
        // Sometimes it takes some time
        // [self performSelector:@selector(startEditing) withObject:nil afterDelay:0.0];
    }
    return canBecome;
}

/**
 UIResponder protocol override.
 Called when our view is being asked to resign first responder state.
 */
- (BOOL)resignFirstResponder
{
    BOOL val = YES;
    if ([self isFirstResponder]) {
        val = [super resignFirstResponder];
        [self doResignFirstResponder];
    }
    return val;
}

@end

NS_ASSUME_NONNULL_END

#endif
