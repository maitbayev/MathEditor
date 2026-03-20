//
//  MTEditableMathLabel+UIResponder.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import <Foundation/Foundation.h>
#import "MTConfig.h"
#import "MTEditableMathLabel.h"
#import "MTView/MTView+FirstResponder.h"

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
 NSResponder protocol override.
 Our view can become first responder to receive user text input.
 */
- (BOOL)acceptsFirstResponder {
    return [self canBecomeFirstResponder];
}

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


#if TARGET_OS_OSX

- (void)keyDown:(NSEvent *)event {
    // interpretKeyEvents feeds the event into the input system,
    // which calls insertText: or deleteBackward: as appropriate.
    [self interpretKeyEvents:@[event]];
}

- (void)deleteBackward:(nullable id)sender {
    [self deleteBackward];
}

#endif // TARGET_OS_OSX

@end

NS_ASSUME_NONNULL_END

