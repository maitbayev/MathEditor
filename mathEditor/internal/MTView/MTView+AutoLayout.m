//
//  MTView+AutoLayout.m
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#import "MTConfig.h"
#import "MTView+AutoLayout.h"

@implementation MXView (AutoLayout)

- (void)pinToSuperview
{
    [self pinToSuperviewWithTop:0 leading:0 bottom:0 trailing:0];
}

- (void)pinToSuperviewWithTop:(CGFloat)top leading:(CGFloat)leading bottom:(CGFloat)bottom trailing:(CGFloat)trailing
{
    MTView *superview = self.superview;
    if (!superview)
        return;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:superview.topAnchor constant:top],
        [self.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor constant:leading],
        [self.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor constant:-trailing],
        [self.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor constant:-bottom]
    ]];
}

@end
