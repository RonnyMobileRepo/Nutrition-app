//
//  MealDetailCardViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 10/21/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MealDetailCardViewController : UIViewController

- (id)initWith:(PFObject *)mealObject_;

//hashtag buttons
@property (strong, nonatomic) UIButton *breakfastButton;
@property (strong, nonatomic) UIButton *lunchButton;
@property (strong, nonatomic) UIButton *dinnerButton;
@property (strong, nonatomic) UIButton *snackButton;
@property (strong, nonatomic) UIButton *coffeeButton;
@property (strong, nonatomic) UIButton *nomfulButton;
@property (strong, nonatomic) UIButton *makeYourOwnButton;

@property (strong, nonatomic) UIColor *brandColor;

@end
