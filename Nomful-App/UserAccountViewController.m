//
//  UserAccountViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "UserAccountViewController.h"

@interface UserAccountViewController ()

@end


@implementation UserAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            //NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:20.0f]                                                            }];
    
    //initilize object
    //self.chatroomObject = [[PFObject alloc] initWithClassName:@"Chatrooms"];
    [self getGoalLabel];
    
    self.GoalTextView.delegate = self;
    self.notesTextView.delegate = self;

    
    //get images from parse
    PFUser *selectedUser = self.chatroomObject[@"clientUser"];
    self.title = selectedUser[@"firstName"];
    
    PFUser *currentUser = [PFUser currentUser];
    if([currentUser[@"role"] isEqualToString:@"PT"]){
        self.GoalTextView.hidden = true;
        self.addGoalButton.hidden = true;
        self.saveNotesButton.hidden = true;
        self.notesTextView.editable = false;
    }
    
    _notesTextView.text = _chatroomObject[@"Notes"];
    
    //ui design
    _profileImage.layer.cornerRadius = 2.0;
    _notesTextView.layer.cornerRadius = 2.0;
    _GoalTextView.layer.cornerRadius = 2.0;
    
    _saveNotesButton.layer.cornerRadius = 4.0;
    _addGoalButton.layer.cornerRadius = 4.0;
    
    _goalLabel.numberOfLines = 1;
    _goalLabel.adjustsFontSizeToFitWidth = YES;
  
    PFFile *userImageFile = selectedUser[@"photo"];
    
    if(userImageFile){ //if there is data for the photo...go to parse and get the image
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                NSLog(@"getting file");
                UIImage *image = [UIImage imageWithData:imageData];
                [self.profileImage setImage:image];
                //set background to default
                [self.bacgroundImage setImage:image];

            }
        }];
    }else{
        NSLog(@"you made it");
        UIImage *backimage = [UIImage imageNamed:@"Sean.jpeg"];
        //set background to default
        [self.bacgroundImage setImage:backimage];
        
        UIImage *profimage = [UIImage imageNamed:@"profilePlaceholder.png"];
        //set background to default
        [self.profileImage setImage:profimage];
        
    }

    
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    // add the effect view to the image view
    [self.bacgroundImage addSubview:effectView];
    
    [self makeProfiilePictureACircle];
    
}

- (void)getGoalLabel{
    self.goalLabel.text = @"";
    PFQuery *query = [PFQuery queryWithClassName:@"Goals"];
    [query whereKey:@"userObject" equalTo:self.chatroomObject[@"clientUser"]];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            //set the goal label to the retreved goal text
            self.goalLabel.text = object[@"text"];
        }else
            NSLog(@"No object found/ error occured" );
    
    }];
    
}


- (IBAction)newGoalButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Do you want to set a new goal for this client?" delegate:self cancelButtonTitle:@"Nope!" otherButtonTitles:@"Yes!", nil];
    
    [alert show];
    
}

- (IBAction)saveNotesButtonPressed:(id)sender {
    //save notes button pressed
    PFUser *selectedUser = self.chatroomObject[@"clientUser"];
    [selectedUser fetch];
    
    NSString *notesString = _notesTextView.text;
    NSLog(@"string is: %@", notesString);
    
    _chatroomObject[@"Notes"] = notesString;
    [_chatroomObject saveEventually];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done!" message:@"Your notes have been savesd :)" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

- (void)sendGoal{
    //get the text from input
    NSString *newGoal = [self.GoalTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //save new goal object to parse
    PFObject *goalObject = [[PFObject alloc] initWithClassName:@"Goals"];
    goalObject[@"userObject"] = self.chatroomObject[@"clientUser"];
    goalObject[@"text"] = newGoal;
    [goalObject saveEventually];
    
    //in the mean time let's set the ui of the label to the new one
    self.goalLabel.text = newGoal;
    self.GoalTextView.text = @"The goal has been sent!!";
    [self.GoalTextView resignFirstResponder];
    [self.goalLabel resignFirstResponder];
    
    //send push notification to the user!
    //declare push variables for use in if statements
    PFQuery *pushQuery = [PFInstallation query];
    NSDictionary *data = [[NSDictionary alloc] init];
    [pushQuery whereKey:@"user" equalTo:self.chatroomObject[@"clientUser"]];
    
    //build the string for the push message to be shown
    NSString *name = [NSString stringWithFormat:@"Your current goal has been changed!"];
    
    //set the data info for the push
    data = [NSDictionary dictionaryWithObjectsAndKeys:
            name, @"alert",
            @"default", @"sound",
            @"goal", @"type",
            nil];
    
    //send the push
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [self sendGoal];
        [self.GoalTextView resignFirstResponder];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    NSLog(@"Started editing textview!");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    if(textView == self.GoalTextView){
        if([self.GoalTextView.text isEqualToString:@"Enter new goal..."]){
            self.GoalTextView.text = nil;
        }
        _isNotes = NO;
    }else{
        //note begin editing

        _isNotes = YES;
        [self dude];
    }
    

}

-(void)makeProfiilePictureACircle{
    NSLog(@"The width is: %f", self.profileImage.frame.size.width );
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    self.profileImage.layer.borderWidth = 1.0f;
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
}




-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    NSLog(@"keyboard is showing");
        
        //hide cancel button
        self.navigationItem.leftBarButtonItem = nil;
    
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        
        self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
        
        NSDictionary* keyboardInfo = [sender userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        _keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        self.originalCenter = self.view.center;

    if(_isNotes){
        [self dude];
    }
        // NSNumber *aNumber = [NSNumber numberWithFloat:newFrame.origin.y];


    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
}

-(void)dude{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         self.originalCenter = self.view.center;
                         NSLog(@"center is: %@", NSStringFromCGPoint(self.originalCenter));
                         
                         self.view.center = CGPointMake(self.originalCenter.x, (self.originalCenter.y - _keyboardFrameBeginRect.size.height));
                         
                     }];
    

}
- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    _isNotes = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         self.view.center = self.originalCenter;
                         
                     }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
