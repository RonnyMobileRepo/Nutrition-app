//
//  ConvertToFirebaseViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 10/7/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "ConvertToFirebaseViewController.h"

@interface ConvertToFirebaseViewController (){
    //chatroom ID
    NSString *groupId;
}

@end

@implementation ConvertToFirebaseViewController

- (id)initWith:(NSString *)groupId_

{
    self = [super init];
    groupId = groupId_;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"group id is: %@", groupId);
    
    //build the ui
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadViewElements];
    

}

-(NSString*)Date2String:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadViewElements{
    NSLog(@"loading view elements for convert view");
    
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    containerView.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    containerView.layer.cornerRadius = 4.0;
    [self.view addSubview:containerView];
    
    //let's add a label in the middle
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    mainLabel.text = @"Chatroom Upgrade";
    mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    mainLabel.numberOfLines = 3;
    mainLabel.textAlignment = NSTextAlignmentCenter;
    mainLabel.layer.cornerRadius = 4.0;
    mainLabel.clipsToBounds = YES; //need this for the corner radius
    mainLabel.textColor = [UIColor whiteColor];
    mainLabel.font = [UIFont fontWithName:kFontFamilyName size:25.0];
    [containerView addSubview:mainLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    descriptionLabel.text = @"New features include the ability to send pictures in case you forget to log a meal, faster and more reliable messaging, and overall it just works smoother :) Enjoy!";
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.numberOfLines = 6;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.layer.cornerRadius = 4.0;
    descriptionLabel.clipsToBounds = YES; //need this for the corner radius
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont fontWithName:kFontFamilyName size:20.0];
    [containerView addSubview:descriptionLabel];
    
    
    //add activity indicator
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    
    
    //add button
    _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 100)];
    [_doneButton setTitle:@"Let's See it!" forState:UIControlStateNormal];
    [_doneButton setTitleColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.backgroundColor = [UIColor whiteColor];
    _doneButton.layer.cornerRadius = 2.0;
    _doneButton.clipsToBounds = YES;
    [_doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_doneButton];


    //constrainstss
    
    NSDictionary *views = @{@"mainLabel": mainLabel,
                            @"indicator":_activityIndicator,
                            @"doneButton": _doneButton,
                            @"container": containerView,
                            @"description": descriptionLabel};
    
    //_________________________________________________________________________________________________________

    //set container view
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[container]-(20)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[container]-(20)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    //_________________________________________________________________________________________________________
    
    
    //label view
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[mainLabel]-(30)-|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[mainLabel]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    //_________________________________________________________________________________________________________
    
    
    //descrition view
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[description]-(30)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:descriptionLabel
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];

    
    //_________________________________________________________________________________________________________

    //done button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(50)-[doneButton]-(50)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[doneButton]-(30)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    

    
  
    //_________________________________________________________________________________________________________


    //indicator
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    //_________________________________________________________________________________________________________

   
    [self convert];
}

- (void)finishUpdatingChatroom{
    
    //send push notification to coach
    //dismiss view
    [_activityIndicator stopAnimating];
    
    // _doneButton.hidden = NO;
    
    
    
}

- (void)doneButtonPressed{
    NSLog(@"done button pressed");
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
}

- (void)convert{
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable chatroom, NSError * _Nullable error) {
        
        //
        PFQuery *messagesQuery = [[PFQuery alloc] initWithClassName:@"Messages"];
        [messagesQuery whereKey:@"chatroom" equalTo:chatroom];
        //[messagesQuery orderByDescending:@"chatroom"];
        [messagesQuery orderByAscending:@"createdAt"];
        [messagesQuery includeKey:@"fromUser"];
        //[messagesQuery setSkip: 1000];
        messagesQuery.limit = 1000;
        
        [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            //objects is all messages sorted by chatroom first then ordered by time with most recent on top
            NSLog(@"We now have %lu messages", objects.count);
            
            if (objects.count > 0) {
                //
                NSArray *messagesArray = objects;
                int totalMessages = (int)[messagesArray count];
                
                PFObject *message = [[PFObject alloc] initWithClassName:@"Messages"];
                
                int i = 0;
                for (message in objects) {
                    
                    //get the sender user
                    PFUser *fromUser = message[@"fromUser"];
                    
                    //build firebase object
                    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                    
                    item[@"userId"] = fromUser.objectId;
                    item[@"name"] = fromUser[@"firstName"];
                    item[@"date"] = [self Date2String:message.createdAt];
                    item[@"status"] = @"Delivered";
                    
                    item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
                    item[@"video_duration"] = item[@"audio_duration"] = @0;
                    item[@"picture_width"] = item[@"picture_height"] = @0;
                    
                    item[@"text"] = message[@"content"];
                    item[@"type"] = @"text";
                    
                    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, groupId]];
                    Firebase *reference = [firebase childByAutoId];
                    item[@"messageId"] = reference.key;
                    
                    [reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
                     {
                         if (error != nil) NSLog(@"Outgoing sendMessage network error.");
                     }];
                    
                    i++;
                    
                    if (i == totalMessages || i == 0) {
                        //we have reached the last message
                        NSLog(@"last message reached");
                        
                        //wait to show button
                        
                        
                        chatroom[@"upgradedToFirebase"] = @"Yes";
                        [chatroom saveInBackground];
                        
                        [self finishUpdatingChatroom];
                        
                    }
                }
                
            }
            
        }];
        
    }];
    
    
    

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
