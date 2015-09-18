//
//  MarginLabel.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "MarginLabel.h"

@implementation MarginLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 60, 0, 0}; //top left bottom right
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
