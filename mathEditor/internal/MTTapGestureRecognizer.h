//
//  MTTapGestureRecognizer.h
//
//  Small cross-platform tap gesture abstraction.
//

#import "MTConfig.h"

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#define MTTapGestureRecognizer UITapGestureRecognizer

static inline CGPoint MTTapGestureLocationInView(MTTapGestureRecognizer *gesture, MTView *view)
{
    return [gesture locationInView:view];
}

#else

#import <AppKit/AppKit.h>

#define MTTapGestureRecognizer NSClickGestureRecognizer

static inline CGPoint MTTapGestureLocationInView(MTTapGestureRecognizer *gesture, MTView *view)
{
    return [gesture locationInView:view];
}

#endif
