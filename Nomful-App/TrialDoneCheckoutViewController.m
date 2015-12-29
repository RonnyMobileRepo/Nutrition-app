//
//  TrialDoneCheckoutViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 12/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "TrialDoneCheckoutViewController.h"

@interface TrialDoneCheckoutViewController ()

@end

@implementation TrialDoneCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //vars
    _planColor = [UIColor colorWithRed:126.0/255.0 green:202/255.0 blue:175/255.0 alpha:1.0];
    
    //rounded corners
    _planViewLeft.layer.cornerRadius = 4.0;
    _planViewMiddle.layer.cornerRadius = 4.0;
    _planViewRight.layer.cornerRadius = 4.0;

    //borders
    _planViewLeft.layer.borderColor = [[UIColor blackColor] CGColor];
    _planViewLeft.layer.borderWidth = 1.0;
    _planViewRight.layer.borderColor = [[UIColor blackColor] CGColor];
    _planViewRight.layer.borderWidth = 1.0;
    
    _purchaseButton.layer.cornerRadius = 8.0;

    //showdow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_planViewMiddle.bounds];
    _planViewMiddle.layer.masksToBounds = NO;
    _planViewMiddle.layer.shadowColor = [UIColor blackColor].CGColor;
    _planViewMiddle.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _planViewMiddle.layer.shadowOpacity = 0.7f;
    _planViewMiddle.layer.shadowPath = shadowPath.CGPath;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)planViewPressed:(UIButton *)button{
    NSLog(@"Plan: %@ selected!", button);
    //1 = healthy start
    //2 = bootcamp
    //3 = lifestyle
    
    //update the plan description
    [self updatePlanDescription:button];
    
    if (button.tag == 1) {
        _planViewLeft.backgroundColor = _planColor;
        _planViewMiddle.backgroundColor = [UIColor whiteColor];
        _planViewRight.backgroundColor = [UIColor whiteColor];
        
    }else if(button.tag == 2){
        _planViewLeft.backgroundColor = [UIColor whiteColor];
        _planViewMiddle.backgroundColor = _planColor;
        _planViewRight.backgroundColor = [UIColor whiteColor];
        
    }else if(button.tag == 3){
        _planViewLeft.backgroundColor = [UIColor whiteColor];
        _planViewMiddle.backgroundColor = [UIColor whiteColor];
        _planViewRight.backgroundColor = _planColor;
    }
    
}

-(void)updatePlanDescription:(UIButton *)planSelected{
    
    //string vars
    NSString *planTitleString;
    NSString *bullet1String1;
    NSString *bullet1String2;
    NSString *bullet1String3;
    NSString *bullet1String4;
    
    //change strings based on plan selected
    if (planSelected.tag == 1) {

        planTitleString = @"HEALTHY START";
        bullet1String1 = @"Initial phone assesment";
        bullet1String2 = @"Daily feedback and support";
        bullet1String3 = @"Quick meal sharing";
        bullet1String4 = @"Help with recipes, questions, etc";
        
    }else if(planSelected.tag == 2){
        planTitleString = @"BOOTCAMP";
        bullet1String1 = @"12-week immersive program";
        bullet1String2 = @"Complete personalized evaluation";
        bullet1String3 = @"Weekly progress tracking";
        bullet1String4 = @"Regular phone assesments";
        
    }else if(planSelected.tag == 3){
        planTitleString = @"LIFESTYLE";
        bullet1String1 = @"BULLET 1";
        bullet1String2 = @"BULLET 2";
        bullet1String3 = @"BULLET 3";
        bullet1String4 = @"BULLET 4";
    }

    
    _planDescriptionTitle.text = planTitleString;
    _planBullet1.text = bullet1String1;
    _planBullet2.text = bullet1String2;
    _planBullet3.text = bullet1String3;
    _planBullet4.text = bullet1String4;

    
}

@end
