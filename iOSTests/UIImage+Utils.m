//
//  UIImage+Utils.m
//  iOSTests
//
//  Created by Philipp Schunker on 20.11.22.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

+ (UIImage * _Nullable)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * _Nullable image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
