//
//  NomberrySignupViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 2/5/16.
//  Copyright © 2016 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NomberryTableViewCell.h"

@interface NomberrySignupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)nextButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *response1Container;
- (IBAction)backButtonPressed:(id)sender;

@end
