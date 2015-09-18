//
//  pagecontentViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pagecontentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property NSUInteger pageIndex;
@property NSString *imgFile;
@property NSString *txtTitle;

@property (weak) IBOutlet NSLayoutConstraint *topSpaceToTLG;

@end
