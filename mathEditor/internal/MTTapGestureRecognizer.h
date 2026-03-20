//
//  MTTapGestureRecognizer.h
//
//  Small cross-platform tap gesture abstraction.
//

@import iosMath;

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>
#define MTTapGestureRecognizer UITapGestureRecognizer

#else

#import <AppKit/AppKit.h>
#define MTTapGestureRecognizer NSClickGestureRecognizer

#endif
