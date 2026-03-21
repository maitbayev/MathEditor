//
//  MTEditableMathLabel+NSView.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_IPHONE

#import "MTEditableMathLabel.h"
#import "MTCaretView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTEditableMathLabel (UIView)
@end

@implementation MTEditableMathLabel(UIView)

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self doLayout];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
    BOOL inside = [super pointInside:point withEvent:event];
    if (inside) {
        return YES;
    }
    // check if a point is in the caret view.
    return [self.caretView pointInside:[self convertPoint:point toView:self.caretView] withEvent:event];
}

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_IPHONE
