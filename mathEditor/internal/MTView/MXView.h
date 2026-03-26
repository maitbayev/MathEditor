//
//  MXView.h
//  MathEditor
//
//  Created by Madiyar Aitbayev on 20/03/2026.
//

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#define MXView NSView
#else
#import <UIKit/UIKit.h>
#define MXView UIView
#endif
