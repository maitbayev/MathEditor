//
//  MTEditableMathLabel+NSView.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_OSX

#import "MTEditableMathLabel.h"
#import "MTMathUILabel.h"

@import MathEditorSwift;

NS_ASSUME_NONNULL_BEGIN

@interface MTEditableMathLabel (NSView)
@end

@interface MTEditableMathLabel ()
@property (nonatomic) MTMathUILabel *label;
@end

@implementation MTEditableMathLabel(NSView)

- (void)layout {
    [super layout];
    [self doLayout];
}

- (BOOL)isFlipped {
    return YES;
}

- (nullable NSView *)hitTest:(NSPoint)point {
    return [self hitTestOutsideBounds:point ignoringSubviews:@[self.label]];
}

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_OSX
