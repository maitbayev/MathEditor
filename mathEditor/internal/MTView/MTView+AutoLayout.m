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
    MTView *superview = self.superview;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor],
        [self.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor],
        [self.topAnchor constraintEqualToAnchor:superview.topAnchor],
        [self.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor]
    ]];
}

@end
