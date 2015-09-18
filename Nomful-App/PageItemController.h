//
//  PageItemController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageItemController : UIViewController


// Item controller information
@property (nonatomic) NSUInteger itemIndex; // ***
@property (nonatomic, strong) NSString *imageName; // ***

@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@end
