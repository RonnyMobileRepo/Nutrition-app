//
//  imageDetailViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface imageDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *fullSizeImage;
@property (strong, nonatomic) PFObject *objectFromSegue;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel
;
@property (weak, nonatomic) IBOutlet UILabel *arrayLabel;
@property (strong, nonatomic) UILabel *timeFromPrev;

@property (strong, nonatomic) PFObject *chatroomObject;

- (NSString *)timestampFormatter:(NSDate *)date;

@end
