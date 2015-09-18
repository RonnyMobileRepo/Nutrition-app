//
//  SignUpViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SignUpViewController.h"
#import "Reachability.h"

@interface SignUpViewController ()

@end

CGFloat const kMarginForText = 60.0;


@implementation SignUpViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];

}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.uploadPhotoButton.hidden = YES;
        self.profileImage.hidden = YES;
    }
    
    [super viewDidLoad];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self checkNetworkStatus];
    
    //load the first name/ last name views...couldn't do it in storyboard
    [self loadTextViews];
    
    //set flags
    self.didUploadPhoto = NO;
    self.profileImage.hidden = YES;
    
    //listen for keyboard appearing and disappearing
    [self registerForKeyboardNotifications];
    
    //dismiss keyboard on scroll
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
   
    
    //set delegates so that the delegate methods can be accessed
    //specifically, we're using the 'return key' to move to next field
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.repasswordField.delegate = self;
    self.motivationField.delegate = self;

    
    //This gets the text in the textfields to move to the right 20px. Gives room for icons
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForText, 55)];
    [self.firstNameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.firstNameField setLeftView:spacerView];
    
    UIView *spacerView6 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 55)];
    [self.lastNameField setLeftViewMode:UITextFieldViewModeAlways];
    [self.lastNameField setLeftView:spacerView6];

    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForText, 55)];
    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailField setLeftView:spacerView1];
    
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForText, 55)];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:spacerView2];
    
    UIView *spacerView4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForText, 55)];
    [self.repasswordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.repasswordField setLeftView:spacerView4];
    
    UIView *spacerView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForText, 55)];
    [self.motivationField setLeftViewMode:UITextFieldViewModeAlways];
    [self.motivationField setLeftView:spacerView3];
    
    //make the profile image a circle!!!!!
    [self makeProfiilePictureACircle];
}


- (IBAction)closeButtonPressed:(id)sender {
    NSLog(@"closeButton Pressed");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SignInButtonPressed:(id)sender {
    
    if([self checkNetworkStatus]){
        //alert is shown
        
    }else{
        //no network warning
        [self.activityIndicator startAnimating];
        
        //Get the information from the fields
        NSString *firstName = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lastName = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *emailAddress = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *repassword = [self.repasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *motiv = [self.motivationField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //NSString *motivation = [self.birthdayField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        
        //form validation
        NSString *alertString = [[NSString alloc] init];
        bool showAlert = false;
        
        if (![emailAddress containsString:@"rd.com"]) {
            //this is so i can make users...stupid jenk
            
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                self.didUploadPhoto = YES;
            }
            
            if(self.didUploadPhoto == NO){
                alertString = @"Please upload a photo!";
                showAlert = true;
            }else if([firstName isEqualToString:@""]){
                alertString = @"Please enter your first name.";
                showAlert = true;
            }else if([lastName isEqualToString:@""]){
                alertString = @"Please enter your last name.";
                showAlert = true;
            }else if([emailAddress isEqualToString:@""]){
                alertString = @"Please enter your email address.";
                showAlert = true;
            }else if([password isEqualToString:@""]){
                alertString = @"Please enter a password.";
                showAlert = true;
            }else if([repassword isEqualToString:@""]){
                alertString = @"Please enter your password again.";
                showAlert = true;
            }else if(![password isEqualToString:repassword]){
                alertString = @"Make sure your passwords match!";
                showAlert = true;
            }else if([motiv isEqualToString:@""]){
                alertString = @"Make sure you enter your motivation!";
                showAlert = true;
            }else if(!self.checkBox.selected){
                alertString = @"Make sure you read and agree to the terms!";
                showAlert = true;
            }
            if(showAlert){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oh No!" message:alertString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
                [self.activityIndicator stopAnimating];
            }
        }
        
        
        //sign up new user
        PFUser *newUser = [PFUser user];
        newUser.username = emailAddress;
        newUser.password = password;
        newUser.email = emailAddress;
        newUser[@"firstName"] = firstName;
        newUser[@"lastName"] = lastName;
        newUser[@"motivation"] = motiv;
        newUser[@"role"] = @"Client";
        
        //if ther was a validation alert shown, we don't want it to attempt a sign up
        //because then multiple alerts will appear to the user...we don't want that
        //therefore...if showAlert is false then attempt sign up
        if(!showAlert){
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(!error){
                    if(self.didUploadPhoto == YES){
                        //the user uploaded his own photo
                        NSLog(@"User uploaded his photo");
                        
                        if (![[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                            //if not ipad...uplaod image
                            [self uploadPhotoToParse];
                        }

                    }
                    
                    [self.activityIndicator stopAnimating];
                    //user is signed up...let's have them enter access code
                    [self performSegueWithIdentifier:@"verifyPhoneScreen" sender:self];
                    
                    //register with intercom
                    PFUser *currentUser =  [PFUser currentUser];
                    [Intercom registerUserWithUserId:currentUser.objectId email:currentUser.email];
                    
                    
                    //register with Mixpanel
                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                    [mixpanel identify:currentUser.objectId];
                    [mixpanel.people set:@{@"$first_name"    : firstName,
                                           @"$last_name"     : lastName,
                                           @"$email"         : emailAddress}];
                    
                    
                    //save installation
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    currentInstallation[@"user"] = [PFUser currentUser];
                    [currentInstallation saveEventually];
                    
                    NSLog(@"You just saved the user on the installation in parse");
                    
                    
                }//end !error
                else{
                    [self.activityIndicator stopAnimating];

                    //there was an error on RD block
                    UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                }//end else
                
            }];//end sign up bloack
            
        }//end if show alert!
        

    }
}

#pragma mark - Image Picker Stuff

- (IBAction)pickImagePressed:(id)sender {
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
   
    }
    else if(buttonIndex == 1){
        //takephoto was pressed
        //show the camera
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:self.imagePicker animated:YES completion:nil];

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
        self.profileImage.image = [self squareImageFromImage:self.image scaledToSize:newSize];
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
    
    self.didUploadPhoto = YES;
    self.profileImage.hidden = NO;
    self.uploadPhotoButton.hidden = YES;
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

#pragma mark - Keyboard Stuff

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    //self.scrollView.scrollEnabled = YES;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"keyboard height is: %fl", kbSize.height);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+150, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
//    CGRect aRect = self.view.frame;
//    aRect.size.height -= kbSize.height;
//    if (!CGRectContainsPoint(aRect, self.loginButton.frame.origin) ) {
//        [self.scrollView scrollRectToVisible:self.loginButton.frame animated:YES];
//    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
    } else if(textField == self.lastNameField) {
        [self.emailField becomeFirstResponder];
    }else if(textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }else if(textField == self.passwordField) {
        [self.repasswordField becomeFirstResponder];
    }else if(textField == self.repasswordField) {
        [self.motivationField becomeFirstResponder];
    }else if(textField == self.motivationField) {
        NSLog(@"button pressed");
        [self SignInButtonPressed:self.loginButton];
    }
    return NO;
}

-(void)makeProfiilePictureACircle{
    NSLog(@"The width is: %f", self.profileImage.frame.size.width );
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 4.0f;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;

}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField{
    UIImage *image = [[UIImage alloc] init];
    
    if (textField == self.firstNameField){
        //name
        image = [UIImage imageNamed:@"user-selected"];
        self.nameFieldIcon.image = image;
    }else if(textField == self.emailField){
        //email
        image = [UIImage imageNamed:@"email-selected"];
        [self.emailFieldIcon setImage:image];
    }else if(textField == self.passwordField){
        //pass
        image = [UIImage imageNamed:@"password-selected"];
        [self.passwordFieldIcon setImage:image];
    }else if(textField == self.repasswordField){
        //motivation
        image = [UIImage imageNamed:@"password-selected"];
        [self.motivationFieldIcon setImage:image];
    }else if(textField == self.motivationField){
        //motivation
        image = [UIImage imageNamed:@"motivation-selected"];
        [self.realMotivationIcon setImage:image];
    }
}

-(IBAction)textFieldDidEndEditing:(UITextField *)textField{
    UIImage *image = [[UIImage alloc] init];
    
    if (textField == self.firstNameField && ([self.firstNameField.text isEqualToString:@""])){
        //name
        image = [UIImage imageNamed:@"user"];
        self.nameFieldIcon.image = image;
    }else if(textField == self.emailField && ([self.emailField.text isEqualToString:@""])){
        //email
        image = [UIImage imageNamed:@"email"];
        [self.emailFieldIcon setImage:image];
    }else if(textField == self.passwordField && ([self.passwordField.text isEqualToString:@""])){
        //pass
        image = [UIImage imageNamed:@"password"];
        [self.passwordFieldIcon setImage:image];
    }else if(textField == self.repasswordField && ([self.repasswordField.text isEqualToString:@""])){
        //motivation
        image = [UIImage imageNamed:@"password"];
        [self.motivationFieldIcon setImage:image];
    }else if(textField == self.motivationField && ([self.motivationField.text isEqualToString:@""])){
        //motivation
        image = [UIImage imageNamed:@"motivation"];
        [self.realMotivationIcon setImage:image];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"showGroupCode"]){
        //the client login was successful let's have them enter access code
    }
    
}

-(void)loadTextViews{
    
    self.firstNameField = [[UITextField alloc] init];
    self.lastNameField = [[UITextField alloc] init];
    
    self.firstNameField.backgroundColor = [UIColor clearColor];
    self.lastNameField.backgroundColor = [UIColor clearColor];
    
    self.firstNameField.tintColor = [UIColor blueColor]; //this is the cursor color! yay
    self.lastNameField.tintColor = [UIColor blueColor];

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.firstNameField.backgroundColor = [UIColor whiteColor];
        self.lastNameField.backgroundColor = [UIColor whiteColor];
    }
    
    [self.firstNameField setFont:[UIFont fontWithName:@"Avenir" size:14]];
    [self.lastNameField setFont:[UIFont fontWithName:@"Avenir" size:14]];

    self.firstNameField.placeholder = @"First Name";
    self.lastNameField.placeholder = @"Last Name";
    
    self.lastNameField.translatesAutoresizingMaskIntoConstraints = NO;
    self.firstNameField.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    [self.scrollView addSubview:self.lastNameField];
    [self.scrollView addSubview:self.firstNameField];
    
    //constraints

    //Define the keys for constraints
    NSDictionary *viewsDictionary = @{@"firstName":self.firstNameField,
                                      @"lastName":self.lastNameField,
                                      @"profileImage":self.profileImage,
                                      @"addPhotoButton" : self.uploadPhotoButton};
    
    float width = self.view.bounds.size.width/2;

    NSDictionary *metrics = @{@"width":@(width)};
    
    //set distance from profile
    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[profileImage]-1-[firstName]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    
    
    //set width to half screen
    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[firstName]-width-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    //set height to 55
    [self.firstNameField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[firstName(==55)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDictionary]];
    
    NSArray *constraint_POS_V_last = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[profileImage]-1-[lastName]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    
    
    //set width to half screen
    NSArray *constraint_POS_H_last = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-width-[lastName]-0-|"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:viewsDictionary];
    
    //set height to 55
    [self.lastNameField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lastName(==55)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:constraint_POS_V];
    [self.view addConstraints:constraint_POS_H];
    [self.view addConstraints:constraint_POS_V_last];
    [self.view addConstraints:constraint_POS_H_last];

}

-(bool)checkNetworkStatus{
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if([self stringFromStatus:status] != nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Problem!"
                                                        message:[self stringFromStatus:status] delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return true;
    }else{
        return false;
    }
    
}

- (NSString *)stringFromStatus:(NetworkStatus) status {
    
    NSString *string;
    switch(status) {
        case NotReachable:
            string = @"Sorry, you don't have network access at this time. Please check wifi and cellular settings.";
            break;
        case ReachableViaWiFi:
            string = nil;
            break;
        case ReachableViaWWAN:
            string = nil;
            break;
        default:
            string = nil;
            break;
    }
    return string;
}


- (IBAction)checkBoxChecked:(id)sender {
    
    if(!self.checkBox.selected){
        self.checkBox.selected = YES;
    }else{
        self.checkBox.selected = NO;
    }
}
@end
