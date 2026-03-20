//
//  MTView+Layout.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import "MXView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MXView (Layout)

#if TARGET_OS_OSX

- (void)setNeedsLayout;

- (void)setNeedsDisplay;

- (void)layoutIfNeeded;

#endif

@end

NS_ASSUME_NONNULL_END
