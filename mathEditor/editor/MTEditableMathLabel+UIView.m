//
//  MTEditableMathLabel+NSView.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_IPHONE

#import "MTEditableMathLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTEditableMathLabel (UIView)
@end

@implementation MTEditableMathLabel(UIView)

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self doLayout];
}

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_IPHONE
