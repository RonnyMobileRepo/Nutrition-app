//
//  AccountViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

CGFloat const kMarginForTexts = 60.0;


@implementation AccountViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //display profile image from parse
    PFUser *user = [PFUser currentUser];
    NSLog(@"current user is: %@", user);
    
    PFFile *userImageFile = user[@"photo"];
    NSLog(@"user image: %@", user[@"photo"]);
    
    if(userImageFile){ //if there is data for the photo...go to parse and get the image
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                NSLog(@"getting file");
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profileImage setImage:image];
                //set background to default
                [self.seanPIc setImage:image];
            }
        }];
    }
    else{
        //there is no photo on parse set to uplaod photo image
        self.profileImage.image = [UIImage imageNamed:@"photoupload"]; //otherwise show the placeholder
        
        //make photo button active
        self.addPhotoButton.hidden = NO;
        
        //set background to default
        self.seanPIc.image = [UIImage imageNamed:@"Sean.jpeg"];
    }
    
    //make profile picture a circle
    [self makeProfiilePictureACircle];
    
    //Get info from parse and display in fields
    self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@",[user valueForKey:@"firstName"], [user valueForKey:@"lastName"]];
    self.birthdayLabel.text = [NSString stringWithFormat:@"%@",[user valueForKey:@"motivation"]];
    
    if(!user[@"motivation"]){
        self.birthdayLabel.text = @"";
    }
    
}

- (void)goToHome{
    //go to home view....
    
}
-(void)makeProfiilePictureACircle{
    NSLog(@"The width is: %f", self.profileImage.frame.size.width );
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 4.0f;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [self.seanPIc addSubview:effectView];
    
}


- (IBAction)addPhotoButtonPressed:(id)sender {
    //You selected to upload an image. I will show you two options
    //You can take a pic or choose an existing one
    NSLog(@"Pick Image Pressed");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Choose Existing",@"Take Photo",nil];
    [actionSheet showInView:self.view];

    
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //You are looking at an action sheet
    //I make sure you are taken to the camera or the library
    NSLog(@"Action Sheet Pressed");
    
    if(buttonIndex == 0){
        //choose existing was pressed
        //show the library
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex == 1){
        //takephoto was pressed
        //show the camera
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    
    
}


- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //You finished selecting an image, whether through taking a pic or selecting
    //first dismiss the picker
    //then show the cropper to make it square
    NSLog(@"Image Selected");
    
    
    [picker dismissViewControllerAnimated:NO completion:^() {
        
        UIImage *portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    NSLog(@"Cropper View Controller Show");
    
    self.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // dismiss the image cropper
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
        CGFloat newSize = 100.0f; //this is the size of the square that we want
        UIImage *imageset =  [self squareImageFromImage:self.image scaledToSize:newSize];

        self.profileImage.image = imageset;
        self.seanPIc.image = imageset;
        
        //[self makeProfiilePictureACircle];
        [self uploadPhotoToParse];

        
    }];
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    NSLog(@"Scaled to Size Called");
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - Helper Methods
-(void)uploadPhotoToParse{
    //declasre a file datatype and a filename datatype
    NSData *fileData;
    NSString *fileName;
    UIImage *newImage = self.profileImage.image; //lets try setting the new image to the image property that was set in the didfinishpickingimage method
    
    fileData = UIImagePNGRepresentation(newImage);
    fileName = @"image.png";
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    
    //save file
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Occured!"
                                                                message:@"Try sending message again"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            // [self.activityIndicatorView stopAnimating];
            [alertView show];
            
        }
        else{
            //success, file is on parse.com
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:file forKey:@"photo"];
            //save parse object in background
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Occured!"
                                                                        message:@"Try sending message again"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    //[self.activityIndicatorView stopAnimating];
                    [alertView show];
                }
                else{
                    //success
                    //[self reset];
                    //NSLog(@"hey");
                    
                }
                
            }];
            
        }
    }];
}

@end
