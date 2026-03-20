//
//  MTCancelView.m
//
//  Created for the editable label clear affordance.
//

#if TARGET_OS_IPHONE

#import "MTCancelView.h"
#import "MTTapGestureRecognizer.h"

@interface MTCancelView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MTCancelView

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        UIImage *image = [UIImage systemImageNamed:@"xmark.circle"];
        if (image != nil) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.tintColor = [MTColor secondaryLabelColor];
        [self addSubview:_imageView];

        [NSLayoutConstraint activateConstraints:@[
            [_imageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_imageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
            [_imageView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_imageView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        ]];

        self.userInteractionEnabled = YES;
        MTTapGestureRecognizer *tapRecognizer = [[MTTapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:tapRecognizer];
        self.hidden = YES;
    }
    return self;
}

@end

#endif
