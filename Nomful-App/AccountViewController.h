//
//  AccountViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <VPImageCropperViewController.h>


@interface AccountViewController : UIViewController <UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate,VPImageCropperDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seanPIc;
- (IBAction)addPhotoButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;

@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;


@end
