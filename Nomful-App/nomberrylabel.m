//
//  nomberrylabel.m
//  Nomful-App
//
//  Created by Sean Crowe on 2/8/16.
//  Copyright © 2016 Nomful, inc. All rights reserved.
//

#import "nomberrylabel.h"

@implementation nomberrylabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 5, 0, 0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
