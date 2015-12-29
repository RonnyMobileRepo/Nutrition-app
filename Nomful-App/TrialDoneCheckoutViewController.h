//
//  TrialDoneCheckoutViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 12/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrialDoneCheckoutViewController : UIViewController

//actions
- (IBAction)planViewPressed:(UIButton *)button;
- (IBAction)purchaseButtonPressed:(id)sender;


//props
@property (weak, nonatomic) IBOutlet UIView *planViewLeft;
@property (weak, nonatomic) IBOutlet UIView *planViewMiddle;
@property (weak, nonatomic) IBOutlet UIView *planViewRight;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UILabel *planDescriptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *planBullet1;
@property (weak, nonatomic) IBOutlet UILabel *planBullet2;
@property (weak, nonatomic) IBOutlet UILabel *planBullet3;
@property (weak, nonatomic) IBOutlet UILabel *planBullet4;

//vars
@property (strong, nonatomic) UIColor *planColor;

@end
