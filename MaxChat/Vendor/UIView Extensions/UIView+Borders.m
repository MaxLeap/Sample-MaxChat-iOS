//
//  UIView+Borders.m
//
//  Created by Aaron Ng on 12/28/13.
//  Copyright (c) 2013 Delve. All rights reserved.
//

#import "UIView+Borders.h"


@implementation UIView(Borders)

- (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    [self.layer addSublayer:border];
}

- (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

- (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
    [self.layer addSublayer:border];
}

@end
