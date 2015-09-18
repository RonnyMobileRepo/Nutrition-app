//
//  SelectGoalsViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGoalsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourthButton;

@property (strong, nonatomic) NSMutableArray *goalArray;

- (IBAction)buttonSelected:(UIButton *)sender;
- (IBAction)nextButtonPressed:(id)sender;

@property (strong, nonatomic) PFUser *coachUser;

@end
