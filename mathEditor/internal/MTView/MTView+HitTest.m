//
//  MTView+HitTest.m
//  MathEditor
//
//  Created by Madiyar Aitbayev on 21/03/2026.
//

#import "MTView+HitTest.h"

#if TARGET_OS_OSX

NS_ASSUME_NONNULL_BEGIN

@implementation NSView (HitTest)

- (NSView *)hitTestOutsideBounds:(NSPoint)point
{
    return [self hitTestOutsideBounds:point ignoringSubviews:@[]];
}

- (NSView *)hitTestOutsideBounds:(NSPoint)point ignoringSubviews:(NSArray<NSView *> *)ignoredSubviews
{
    if (self.hidden) {
        return nil;
    }
    NSPoint localPoint = [self convertPoint:point fromView:self.superview];
    for (NSView *child in [self.subviews reverseObjectEnumerator]) {
        if ([ignoredSubviews containsObject:child]) {
            continue;
        }
        NSView *hitView = [child hitTest:localPoint];
        if (hitView) {
            return hitView;
        }
    }
    if (NSPointInRect(localPoint, self.bounds)) {
        return self;
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_OSX
