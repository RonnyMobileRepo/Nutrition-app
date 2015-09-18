//
//  editImageViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/9/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class editImageViewController;
@protocol editImageDelegate <NSObject>
@end

@interface editImageViewController : UIViewController

@property (weak) id<editImageDelegate> delegateModals;
@property (weak) id<editImageDelegate> delegates;

@property (strong, nonatomic) PFObject *mealObject;
@property (weak, nonatomic) IBOutlet PFImageView *mealImageView;
@property (strong, nonatomic) PFFile *mealFile;
@property (strong, nonatomic) NSString *mealDescription;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextview;

@end
