//
//  CoachPageContentViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 11/17/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachPageContentViewController : UIViewController

//UI ELEMENTS
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *coachLabel;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet PFImageView *roundProfileImageView;

- (IBAction)goButtonPressed:(id)sender;

//DELEGATE STUFF?
@property NSUInteger pageIndex;
@property NSString *titleText;
@property PFUser *coachUserObject;


@end
