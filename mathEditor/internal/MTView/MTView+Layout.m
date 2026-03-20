//
//  MTView+Layout.m
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import "MTView+Layout.h"

@implementation MXView (Layout)

#if TARGET_OS_OSX

- (void)setNeedsLayout
{
    [self setNeedsLayout:YES];
}

- (void)setNeedsDisplay
{
    [self setNeedsDisplay:YES];
}

- (void)layoutIfNeeded
{
    [self layoutSubtreeIfNeeded];
}

#endif

@end
