//
//  MTCancelView.h
//
//  Created for the editable label clear affordance.
//

#import "MTConfig.h"

#if TARGET_OS_IPHONE

@interface MTCancelView : MTView

- (instancetype)initWithTarget:(id)target action:(SEL)action;

@end

#endif
