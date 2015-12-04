//
//  LogMealSinglePageViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/12/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "LogMealSinglePageViewController.h"
#import <MBProgressHUD.h>

@interface LogMealSinglePageViewController (){
    
    MBProgressHUD *hud;
    NSTimer *hudTimer;
    PFObject *goalObject;
}


@end


//declare constants
CGFloat const kNavBarMargin = 0.0; //20px for status bar too
CGFloat const kGoalTitleFontSize = 25.0;
CGFloat const kGoalContentFontSize = 15.0;
CGFloat const kButtonFontSize = 20.0;
bool keyboardIsShowing = false;



@implementation LogMealSinglePageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkTrialEnd];
    
    //main view background color
    [self loadMainView];
    
    //bottom goal container view
    [self loadBottomGoalContainer];
    
        //bottom goal information labels
        [self loadGoalStuff];
    
    //white card view that contains the camera viewfinder
    [self loadCardView];
    
    //load camera view inside card view
    [self loadCameraView];
    
    //load the capture button
    [self loadCaptureButton];
    
    
    //capture view...where the image shows after capture button pressed
    [self loadCapturedImageView];

    [self loadPastMeals];
    
    [self loadPhotoTakenActivityIndicator];
    
    [self loadViewConstraints];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkforBadgeValue) name:@"updateBarButtonBadge" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkforBadgeValue) name:@"updateGoal" object:nil];
    
    
    //put these here so that the timer isn't started prematurley on initial load 'enter foreground'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    
    //listen for keyboard notifications
    
    self.hashtagArray = [[NSMutableArray alloc] init];
    
    
}

- (void)updateLabel{

    hud.detailsLabelColor = [UIColor whiteColor];
    [hudTimer invalidate];

}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"view did disappear");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session stopRunning];
        //[self.captureLayer removeFromSuperlayer];
        
    });
}
- (void)loadMainView{
    //main view
    //blue background
    self.brandColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    self.view.backgroundColor = self.brandColor;
}

- (void)loadCardView{
    //card view that contains the camera viewfinder
    
    self.cardView = [[UIView alloc] init];
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = 6.0;
    
    self.cardView.layer.shadowOffset = CGSizeMake(4, 4);
    self.cardView.layer.shadowColor = [[UIColor colorWithRed:111.0/255.0 green:178.0/255.0 blue:155.0/255.0 alpha:1] CGColor];
    self.cardView.layer.shadowRadius = 0.0f;
    self.cardView.layer.shadowOpacity = 0.80f;
    //self.cardView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:layer.bounds] CGPath];
    
    //add to view
    [self.view addSubview:self.cardView];
    
}

- (void)loadBottomGoalContainer{
    
    self.bottomContainerView = [[UIView alloc] init];
    self.bottomContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomContainerView.backgroundColor = [UIColor whiteColor];
   
    //add to view
    [self.view addSubview:self.bottomContainerView];
    
}

- (void)loadGoalStuff{
    NSLog(@"Loading goal stuff");
    
    //alloc
    self.goalsTitleLabel = [[UILabel alloc] init];
    self.goalsLabel = [[UITextView alloc] init];
    
    //autolayout
    self.goalsTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.goalsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    //fomrat
    self.goalsLabel.font = [UIFont fontWithName:kFontFamilyName size:kGoalContentFontSize];
    self.goalsLabel.textAlignment = NSTextAlignmentLeft;
    self.goalsLabel.selectable = NO;
    self.goalsLabel.textColor = [UIColor grayColor];
    
    //format
    self.goalsTitleLabel.text = @"This week's goal:";
    self.goalsTitleLabel.textColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    self.goalsTitleLabel.font = [UIFont fontWithName:kFontFamilyName size:kGoalTitleFontSize];
    self.goalsTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    //add to view
    [self.bottomContainerView addSubview:self.goalsTitleLabel];
    [self.bottomContainerView addSubview:self.goalsLabel];
    
    [self queryForGoal];
    
}

- (void)queryForGoal{
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Goals"];
    [query fromLocalDatastore];
    [query whereKey:@"userObject" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            //set the goal label to the retreved goal text
            self.goalsLabel.text = object[@"text"];
    
        }else{
            //there was an error query on network instead
            
            PFQuery *query = [PFQuery queryWithClassName:@"Goals"];
            [query whereKey:@"userObject" equalTo:[PFUser currentUser]];
            [query orderByDescending:@"createdAt"];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (!object) {
                    //set text
                    self.goalsLabel.text = @"You and your coach will come up with your first goal when you chat on the phone :)";
                }else{
                    //set the goal label to the retreved goal text
                    self.goalsLabel.text = object[@"text"];
                    //pin for futures use
                    [object pinInBackground];
                }
            }];
       
        }
        
    }];
    
}

- (void)loadCameraView{
    NSLog(@"Loading Camera View");
    
    //set frame for camera view
    //width of screen for w and h
    //down for nav bar with constant
    self.cameraView = [[UIView alloc] init];
    
    //for autolayout stuff...don't need it
    self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add subview to view
    [self.cardView addSubview:self.cameraView];
    
}

- (void)loadCaptureButton{
    NSLog(@"Loading Capture button");
    
    //alloc the capture button
    self.captureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.captureButtonContainer = [[UIView alloc] init];
    
    //auto layout
    //will most definitely need constraints on this one
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.captureButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    //set img variable to the photo image
    UIImage *img = [UIImage imageNamed:@"camera-upload"];
    
    //set the bckground image of the button to the image
    [self.captureButton setBackgroundImage:img forState:UIControlStateNormal];
    
    [self.cardView addSubview:self.captureButtonContainer];
    //add to view
    [self.captureButtonContainer addSubview:self.captureButton];
    //self.captureButtonContainer.backgroundColor = [UIColor orangeColor];
    
    //listen for button pressed action
    [self.captureButton addTarget:self
                           action:@selector(captureButtonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)loadCapturedImageView{
    NSLog(@"loading captured image view");
    
    self.capturedImageView = [[UIImageView alloc] init];
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    
    //for autolayout stuff...don't need it
    self.capturedImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add subview to view
    [self.view addSubview:self.capturedImageView];
    

}

- (void)loadDetailTextView{
    NSLog(@"loading detail text view" );
    
    //allloc
    self.descriptionTextView = [[UITextView alloc] init];
    
    //autolayout
    self.descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //set placeholder
    [self.descriptionTextView setText:@"Description..."];
    
    self.descriptionTextView.font = [UIFont fontWithName:kFontFamilyName size:kGoalContentFontSize];
    self.descriptionTextView.textColor = [UIColor grayColor];
    //hide it!
    self.descriptionTextView.hidden = NO;
    
    self.descriptionTextView.delegate = self;
    
    //add to view
    [self.cardView addSubview:self.descriptionTextView];
    
}

- (void)loadSaveButton{
    NSLog(@"loading save button");
    
    //alloc
    self.saveButton = [[UIButton alloc] init];
    
    //autolayout
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    //tesign
    self.saveButton.backgroundColor = [UIColor grayColor];
    
    //set title
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    
    self.saveButton.titleLabel.font = [UIFont fontWithName:kFontFamilyName size:kButtonFontSize];
    //listen for button presses
    [self.saveButton addTarget:self
                        action:@selector(saveButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    
    //add to  view
    [self.cardView addSubview:self.saveButton];
    
}

- (void)loadHashtagContainer{
    
    self.hashtagsContainer = [[UIView alloc] init];
    
    self.hashtagsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.cardView addSubview:self.hashtagsContainer];
    
    [self loadHashtags];
}


- (void)loadHashtags{
    NSLog(@"loading hashtags");
    
    //alloc
    self.breakfastButton = [[UIButton alloc] init];
    self.lunchButton = [[UIButton alloc] init];
    self.dinnerButton = [[UIButton alloc] init];
    self.snackButton = [[UIButton alloc] init];
    self.coffeeButton = [[UIButton alloc] init];
    self.makeYourOwnButton = [[UIButton alloc] init];
    
    //autolayout
    self.breakfastButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.lunchButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.dinnerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.snackButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.coffeeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.makeYourOwnButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    //set text
    [self.breakfastButton setTitle:@"#breakfast" forState:UIControlStateNormal];
    [self.lunchButton setTitle:@"#lunch" forState:UIControlStateNormal];
    [self.dinnerButton setTitle:@"#dinner" forState:UIControlStateNormal];
    [self.snackButton setTitle:@"#snack" forState:UIControlStateNormal];
    [self.coffeeButton setTitle:@"#fluid" forState:UIControlStateNormal];
    [self.makeYourOwnButton setTitle:@"#MakeYourOwn" forState:UIControlStateNormal];
    
    [self.breakfastButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.lunchButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.dinnerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.snackButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.coffeeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.makeYourOwnButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    [self.breakfastButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.lunchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.dinnerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.snackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.coffeeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.makeYourOwnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    //set font
    
    NSString *fontFamily = @"avenir";
    CGFloat fontSize = 15.0;
    
    self.breakfastButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    self.lunchButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    self.dinnerButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    self.snackButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    self.coffeeButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    self.makeYourOwnButton.titleLabel.font = [UIFont fontWithName:fontFamily size:fontSize];
    
    
    [self.lunchButton setTitle:@"#lunch" forState:UIControlStateNormal];
    [self.dinnerButton setTitle:@"#dinner" forState:UIControlStateNormal];
    [self.snackButton setTitle:@"#snack" forState:UIControlStateNormal];
    [self.coffeeButton setTitle:@"#fluid" forState:UIControlStateNormal];
    [self.makeYourOwnButton setTitle:@"#nomful" forState:UIControlStateNormal];
    
    //borders
    
    CGFloat cornerRadius = 4;
    CGFloat borderWidth = 2;
    
    [self.breakfastButton.layer setBorderWidth:borderWidth];
    self.breakfastButton.layer.cornerRadius = cornerRadius;
    [self.breakfastButton.layer setBorderColor:[self.brandColor CGColor]];

    
    [self.lunchButton.layer setBorderWidth:borderWidth];
    self.lunchButton.layer.cornerRadius = cornerRadius;
    [self.lunchButton.layer setBorderColor:[self.brandColor CGColor]];

    
    [self.dinnerButton.layer setBorderWidth:borderWidth];
    self.dinnerButton.layer.cornerRadius = cornerRadius;
    [self.dinnerButton.layer setBorderColor:[self.brandColor CGColor]];

    
    [self.snackButton.layer setBorderWidth:borderWidth];
    self.snackButton.layer.cornerRadius = cornerRadius;
    [self.snackButton.layer setBorderColor:[self.brandColor CGColor]];

    
    [self.coffeeButton.layer setBorderWidth:borderWidth];
    self.coffeeButton.layer.cornerRadius = cornerRadius;
    [self.coffeeButton.layer setBorderColor:[self.brandColor CGColor]];

    
    [self.makeYourOwnButton.layer setBorderWidth:borderWidth];
    self.makeYourOwnButton.layer.cornerRadius = cornerRadius;
    [self.makeYourOwnButton.layer setBorderColor:[self.brandColor CGColor]];

    
    
    //add to view
    [self.hashtagsContainer addSubview:self.breakfastButton];
    [self.hashtagsContainer addSubview:self.lunchButton];
    [self.hashtagsContainer addSubview:self.dinnerButton];
    [self.hashtagsContainer addSubview:self.snackButton];
    [self.hashtagsContainer addSubview:self.coffeeButton];
    [self.hashtagsContainer addSubview:self.makeYourOwnButton];
    
    //add selectors
    //listen for button pressed action
    [self.breakfastButton addTarget:self
                             action:@selector(hashtagSelected:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.lunchButton addTarget:self
                         action:@selector(hashtagSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.dinnerButton addTarget:self
                          action:@selector(hashtagSelected:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.snackButton addTarget:self
                         action:@selector(hashtagSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.coffeeButton addTarget:self
                          action:@selector(hashtagSelected:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.makeYourOwnButton addTarget:self
                               action:@selector(hashtagSelected:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self loadHashtagsConstraints];
    
    
}

- (void)loadPastMeals{
    NSLog(@"loading past meals");
    
    //alloc
    self.pastMealsButton = [[UIButton alloc] init];
    
    //autolayout
    self.pastMealsButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    //set title
    [self.pastMealsButton setTitle:@"Past Meals" forState:UIControlStateNormal];
    
    //font
    [self.pastMealsButton.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:kGoalContentFontSize]];
    
    //background color
    self.pastMealsButton.backgroundColor = [UIColor whiteColor];
    
    //set title color
    [self.pastMealsButton setTitleColor:self.brandColor forState:UIControlStateNormal];
    
    //listen for presses
    [self.pastMealsButton addTarget:self
                             action:@selector(pastMealsButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    //add to view
    [self.bottomContainerView addSubview:self.pastMealsButton];
    
    
    
}


- (void)loadPhotoTakenActivityIndicator{
    NSLog(@"loading activity indicator");
    
    //declare container that covers the cameraview
    self.activityIndicatorContainer = [[UIView alloc] init];
    self.activityIndicatorContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    //set background of containerview
    self.activityIndicatorContainer.backgroundColor = [UIColor colorWithRed:110.0/255.0 green:177.0/255.0 blue:155.0/255.0 alpha:0.7];
    
    //make sure the view is hidden on load
    self.activityIndicatorContainer.hidden = YES;
    
    //adds container to view
    [self.capturedImageView addSubview:self.activityIndicatorContainer];
    
    //decalre new activity indicator and make it white style
    self.photoTakenActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    //not sure what this does
    self.photoTakenActivityIndicator.alpha = 1.0;
    
    //allows for autolayout ocnstraints yay!
    self.photoTakenActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add the indicator to the container view
    [self.activityIndicatorContainer addSubview:self.photoTakenActivityIndicator];
    
}


- (void)loadViewConstraints{
    //load view constraints
    
    //dictionary for views to be constrained
    NSDictionary *views = @{@"cardView"       :   self.cardView,
                            @"bottomView"     :   self.bottomContainerView,
                            @"cameraView"     :   self.cameraView,
                            @"captureButton"  :   self.captureButton,
                            @"captureView"    :   self.capturedImageView,
                            @"goalTitle"      :   self.goalsTitleLabel,
                            @"goalLabel"      :   self.goalsLabel,
                            @"buttonContainer" : self.captureButtonContainer,
                            @"pastMeal" :   self.pastMealsButton,
                            @"indicatorContainer" : self.activityIndicatorContainer
                            };
    
    
    //CARD VIEW:
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[cardView]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    //CARD VIEW: 64 px for the nav bar + 15pts from that
    //also 400 pts high
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[cardView]-(15)-[bottomView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[bottomView]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomView(150)]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[buttonContainer]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cameraView]-(0)-[buttonContainer]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];

    
    
    
    
    //CAPTURE BUTTON: horizontally center the capture button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButtonContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.captureButton
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    //CAPTURE BUTTON: horizontally center the capture button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureButtonContainer
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.captureButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];
    
    //CAMERA VIEW: 10 pts from left/right edge of view
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[cameraView]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //CAMERA VIEW: 10 pts from the top edge of card view
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[cameraView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //CAMERA VIEW: this makes it square bitichies
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.cameraView
                                                attribute:NSLayoutAttributeHeight
                                                relatedBy:NSLayoutRelationEqual
                                                toItem:self.cameraView
                                                attribute:NSLayoutAttributeWidth
                                                multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                                constant:0.0f]];

    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(25)-[captureView]-(25)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //nav bar
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(25)-[captureView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //CAMERA VIEW: this makes it square bitichies
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.capturedImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.capturedImageView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                                            constant:0.0f]];
    
    //goal title
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[goalTitle]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[goalTitle]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[goalTitle]-(0)-[goalLabel]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[goalLabel]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //ACTIVITY INDICATOR: Vertically center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.self.goalsLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pastMeal(20)]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[pastMeal(100)]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[indicatorContainer]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[indicatorContainer]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //ACTIVITY INDICATOR: Horizontally center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoTakenActivityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    //ACTIVITY INDICATOR: Vertically center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorContainer
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoTakenActivityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];

}






/////////////////////////////////////////////


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"view will appear");
    //initialize camera
    //**thisn't good here cuz it initialized on top of other camera views each time you
    //swipe to this page...eventualy crashing
    //we need to figure out how to de-initialize the camera when viewDidDissapear happens
    
    [self initializeCamera:self.cameraView];

    
        //if there is a notificaiton...show badge test
    [self checkforBadgeValue];
    
}

- (void) checkforBadgeValue{
    
    //get the current instalation
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    //if the badge count in parse is NOT zero...
    //then let's set the bar button badge to 1
    //otherwise...make sure there is no badge in the bar button item
    if (currentInstallation.badge != 0) {
        
        self.navigationItem.rightBarButtonItem.badgeValue = @"1";
        
    }else{
        self.navigationItem.rightBarButtonItem.badgeValue = @"0";
        
    }
    
    //go get the new goal from parse
    PFQuery *query = [PFQuery queryWithClassName:@"Goals"];
    [query whereKey:@"userObject" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (!error) {
            //set the goal label to the retreved goal text
            self.goalsLabel.text = object[@"text"];
        }else
            //either the current user has no goals yet
            //or an error occured
            //[ParseErrorHandlingController handleParseError:error];
            NSLog(@"No object found/ error occured" );
        
    }];

    
}

- (void)loadBeginningNavBar{
    
 

}
#pragma mark - Load Views









- (void)loadConstraints{
    NSLog(@"loading constraints");
    
    //dictionary for views to be constrained
    NSDictionary *views = @{@"cameraView"       :   self.cameraView,
                            @"captureButton"    :   self.captureButton,
                            @"saveButton"       :   self.saveButton,
                            @"descriptionView"  :   self.descriptionTextView,
                            @"pastMealsButton"  :   self.pastMealsButton,
                            @"goalsTitle"       :   self.goalsTitleLabel,
                            @"goalLabel"        :   self.goalsLabel,
                            @"breakfast"        :   self.breakfastButton,
                            @"lunch"            :   self.lunchButton,
                            @"dinner"           :   self.dinnerButton,
                            @"snack"            :   self.snackButton,
                            @"coffee"           :   self.coffeeButton,
                            @"makeYourOwn"      :   self.makeYourOwnButton,
                            @"goalsLabel"       :   self.goalsLabel};
    
    
   
    //CAMERA VIEW: vertical constraint. Camera view is 64 pts from top edge (nav bar)
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[cameraView]-(5)-[captureButton]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
    
    //CAPTURE BUTTON: horizontally center the capture button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.captureButton
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0f constant:0.0f]];
    
    
    //ACTIVITY INDICATOR: Horizontally center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorContainer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoTakenActivityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    //ACTIVITY INDICATOR: Vertically center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorContainer
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.photoTakenActivityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];

    
    //SAVE BUTTON: edge to edge
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[saveButton]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //SAVE BUTTON: bottom AND sets height to 55
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[saveButton(55)]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //DESCRIPTION VIEW: bottom AND sets height to 55
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionView(110)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //DESCRIPTION: edge to edge
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[descriptionView]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //PAST MEALS BUTTON: edge to edge
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[pastMealsButton]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //PAST MEALS BUTTON: bottom AND sets height to 55
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pastMealsButton(55)]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //GOAL TITLE: 5 pts below the capture button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureButton]-(10)-[goalsTitle]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    \
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[goalsTitle]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
//    //GOAL TITLE: Vertically center activity indicator within it's container
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
//                                                          attribute:NSLayoutAttributeCenterX
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.goalsTitleLabel
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.0f constant:0.0f]];
    
    //GOAL LABEL: the current goal is below the title lable
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[goalsTitle]-(15)-[goalLabel]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //ACTIVITY INDICATOR: Vertically center activity indicator within it's container
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.goalsLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    //button layouts
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[breakfast]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[breakfast]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[breakfast]-(0)-[lunch]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[lunch]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lunch]-(0)-[dinner]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[dinner]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dinner]-(0)-[snack]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[snack]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[snack]-(0)-[coffee]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[coffee]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[coffee]-(0)-[makeYourOwn]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[makeYourOwn]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //goals labe
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[goalsLabel]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];

    

}

#pragma mark - Camera View


- (void) initializeCamera:(UIView *)cameraView {
    NSLog(@"INITIALIZING CAMERA...");
    
    //self.cameraIsInitialized = YES;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill]; //AVLayerVideoGravityResizeAspectFill
    
    captureVideoPreviewLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    
    //sublayer
    
    [cameraView.layer addSublayer:captureVideoPreviewLayer];

    
    UIView *view = cameraView;
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width);
    [captureVideoPreviewLayer setFrame:frame];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
    
    bool FrontCamer = NO; //this variable changes the camera that is used!!!!
    
    if (!FrontCamer) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
            UIAlertView *cameralert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"The main functionality of Nomful is a camera to snap photos of meals. Please use a device with a camera for the best experience. :)" delegate:self cancelButtonTitle:@"Got It!" otherButtonTitles: nil];
            [cameralert show];
        }else
            [session addInput:input];
    }
    
    
    if (FrontCamer) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }else
            [session addInput:input];
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:self.stillImageOutput];
    
    [session startRunning];
    _session = session;
    _captureLayer = captureVideoPreviewLayer;
    
    
    NSLog(@"...CAMERA DONE INITIALIZING");
    
}


#pragma mark - helper methods

- (IBAction)accountBarButtonPressed:(id)sender {
    NSLog(@"Account Bar Button Pressed");
    [self performSegueWithIdentifier:@"showProfile" sender:self];
}

- (IBAction)chatBarButtonItemPressed:(id)sender {
    NSLog(@"Account Bar Button Pressed");
    [self performSegueWithIdentifier:@"chatSegue" sender:self];
}

- (IBAction)cancelButtonPressed:(id)sender{
    NSLog(@"cancel bar button pressed");
    self.navBar.hidden = true;
    
    [self imageSaveSuccessful];
}
- (IBAction)saveButtonPressed:(id)sender {
    NSLog(@"Save button pressed");
    //take the image captured save to PARSE
    //show a sign of success to the user
    //display the meal timeline with new image in it?
    //save the hastags as an array to parse
    [self.descriptionTextView resignFirstResponder];

    self.activityIndicatorContainer.hidden = NO;
    [self.view bringSubviewToFront:self.activityIndicatorContainer];
    [self.photoTakenActivityIndicator startAnimating];
    
    //save image to parse
    [self saveImageToParse:self.capturedImage];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"chatSegue"]) {
        //do somethign
        MessagesViewController *vc = [segue destinationViewController];
        vc.youAreDietitian = NO;
    }else if( [segue.identifier isEqualToString:@"trialEnded"]){
        //trial is up!
        CheckoutViewController *vc = [segue destinationViewController];
        vc.trialDidEnd = true;
        vc.coachUserFromSegue = _chatroom[@"dietitianUser"];
    }
}
- (IBAction)captureButtonPressed:(id)sender {
    //capture button was pressed
    //freeze the frame to the caputured photo
    //display description section
    
    //change nav
    
    self.navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width, 64)];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    self.navBar.backgroundColor = [UIColor whiteColor];
    
    navItem.title = @"";
    
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    navItem.leftBarButtonItem.tintColor = self.brandColor;
    
    self.navBar.items = @[ navItem ];
    
    [self.view addSubview:self.navBar];
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self.navBar];

    


    //these can't be in the view did load because when a user signs up, the keyboard
    //is still showing briefly from the lat view. This causes the notificaiton to be
    //pinged and a lot of wonky stuff with the nav bar happens
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //call the capture image method to get the image
    [self capImage];
    
}

- (IBAction)pastMealsButtonPressed:(id)sender{
    NSLog(@"past meals button pressed");
    
    //segue to the past meals view
    [self performSegueWithIdentifier:@"pastMealsSegue" sender:self];
}

- (IBAction)hashtagSelected:(UIButton *)sender {
    NSLog(@"hastag selected");
    [self.descriptionTextView resignFirstResponder];
    
    //get the button sender
    UIButton *selctedButton = sender;
    NSString *hashtagTitle = selctedButton.titleLabel.text;
    
    if(selctedButton.selected == YES){
        //the button is already selected
        //deselect it
        selctedButton.selected = NO;
        selctedButton.backgroundColor = [UIColor whiteColor];
        //remove the selected button from the array
        [self.hashtagArray removeObject:hashtagTitle];
        
    }else{
        //set it to the selected state..aka green
        selctedButton.selected = YES;
        [selctedButton setBackgroundColor:self.brandColor];
        [selctedButton.layer setBorderColor:[self.brandColor CGColor]];
        
        //add the current button to the selected array
        //when we save the meal to parse...we can get the title of the button
        
        //get the string from the label
        
        //add the selected button title to array
        [self.hashtagArray addObject:hashtagTitle];

    }
    
}


- (void) capImage { //method to capture image from AVCaptureSession video feed
    NSLog(@"CAPTURING IMAGE...");
    
    
    //camera stuff i don't get
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *imageFromData = [[UIImage alloc] initWithData:imageData];
            
            //set the size of the square we want the image file to be
            CGFloat newSize = self.view.bounds.size.width;
            
            //set newImage to the resized photo
            UIImage *newImage = [self squareImageFromImage:imageFromData scaledToSize:newSize];
            
            //set the image property of the capturedimageview
            self.capturedImageView.image = newImage;
            
            //add the captured image to the view
            [self.cardView addSubview:self.capturedImageView];
            
            //set the local image property to access the newly sized image
            self.capturedImage = newImage;
            self.captureButton.hidden = YES;
            
            //change ui
            [self showDescription];

            
            //RESIZING STUFF
            ///////////////
            
            // Resize the image to be square (what is shown in the preview)
            UIImage *resizedImage = [imageFromData resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                                bounds:CGSizeMake(560.0f, 560.0f)
                                                  interpolationQuality:kCGInterpolationHigh];
            // Create a thumbnail and add a corner radius for use in table views
            UIImage *thumbnailImage = [imageFromData thumbnailImage:400.0f
                                          transparentBorder:0.0f
                                               cornerRadius:0.0f
                                       interpolationQuality:kCGInterpolationDefault];
            
            // Get an NSData representation of our images. We use JPEG for the larger image
            // for better compression and PNG for the thumbnail to keep the corner radius transparency
            imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
            NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
            
            // Create the PFFiles and store them in properties since we'll need them later
            self.photoFile = [PFFile fileWithData:imageData];
            self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
            
            // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
            self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            
            [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }];
                } else {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
            }];
            
            //END RESIZING STUFF
            ////////////////////

        
        }
        
    }];
    
    NSLog(@"... CAPTURING IMAGE DONE");

}

- (void)loadHashtagsConstraints{
    NSDictionary *views = @{@"breakfast"    :   self.breakfastButton,
                            @"lunch"         :   self.lunchButton,
                            @"dinner"        :   self.dinnerButton,
                            @"snack"         :   self.snackButton,
                            @"coffee"        :   self.coffeeButton,
                            @"nomful"       :   self.makeYourOwnButton
                            };
    
    CGFloat buttonLength =  (self.cardView.bounds.size.width - 60)/3;   //10*2 = 20 for margin from container to card
                                                                        //10*2 = 20 for margin from button to container
                                                                        //10*2 = 20 for margin between buttons
                                                                              // 60
    NSNumber * aNumber = [NSNumber numberWithFloat:buttonLength];

    
    NSDictionary *metrics = @{@"buttonWidth"    :   @30,
                              @"buttonLength"   :   aNumber};
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[breakfast(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[breakfast(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[lunch(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[breakfast]-(10)-[lunch(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[dinner(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lunch]-(10)-[dinner(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[breakfast]-(10)-[snack(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[snack(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lunch]-(10)-[coffee(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[snack]-(10)-[coffee(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dinner]-(10)-[nomful(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[coffee]-(10)-[nomful(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    
    
}

- (void)showDescription{
    
    //load description and hashtag view
    [self loadDetailTextView];
    
    //load save buton
    [self loadSaveButton];
    
    //load #s
    [self loadHashtagContainer];
    
    
    //dictionary for views to be constrained
    NSDictionary *views = @{@"cardView"       :   self.cardView,
                            @"captureView"    :   self.capturedImageView,
                            @"descriptionView" :  self.descriptionTextView,
                            @"saveButton"     :   self.saveButton,
                            @"bottomView"     : self.bottomContainerView,
                            @"hashtagContainer" : self.hashtagsContainer
                            };

    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureView]-(0)-[descriptionView]-(-10)-[hashtagContainer]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[descriptionView]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[saveButton]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[saveButton(55)]-(0)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[hashtagContainer]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[hashtagContainer(100)]-(0)-[saveButton]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    
    [self.view layoutIfNeeded];
    
    //CARD VIEW: 64 px for the nav bar + 15pts from that
    //also 400 pts high
    
    self.verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[cardView]-(15)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views];
    
    [self.view addConstraints:self.verticalConstraints];
    
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[captureView]-(0)-[descriptionView]-(0)-[hashtagContainer]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[descriptionView]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    

    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:self.capturedImageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.capturedImageView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                                            constant:0.0f]];
    
  

    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         self.bottomContainerView.hidden = YES;
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
    
    
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
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

#pragma mark - Sticky keyboard


-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    NSLog(@"keyboard is showing");
    if(!keyboardIsShowing){
        keyboardIsShowing = true;
        
        //hide cancel button
        self.navigationItem.leftBarButtonItem = nil;

        
        //bring view to front so it goes over the overlay!!
        //[self.view bringSubviewToFront:self.descriptionTextView];
    //    
        CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
        
        self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
        
        NSDictionary* keyboardInfo = [sender userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
       // NSNumber *aNumber = [NSNumber numberWithFloat:newFrame.origin.y];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             
                             self.originalCenter = self.view.center;
                             NSLog(@"center is: %@", NSStringFromCGPoint(self.originalCenter));
                             
                             self.view.center = CGPointMake(self.originalCenter.x, (self.originalCenter.y - keyboardFrameBeginRect.size.height));
                             
                         }];

    }
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    keyboardIsShowing = false;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         
                         self.view.center = self.originalCenter;
                         
                     }];

}


-(void)saveImageToParse:(UIImage *)image{
    
    NSLog(@"You are going to save the image to Parse... %@", [PFUser currentUser]);
    
    
    if (!self.photoFile || !self.thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Dismiss",nil];
        [alert show];
        return;
    }
    
    // Create a Photo object
    PFObject *photo = [PFObject objectWithClassName:@"Meals"];
    [photo setObject:[PFUser currentUser] forKey:@"userObject"];
    //[photo setObject:self.photoFile forKey:@"mealPhoto"];
    [photo setObject:self.thumbnailFile forKey:@"mealPhoto"];
    [photo setObject:self.hashtagArray forKey:@"hashtagsArrays"];
    [photo setObject:self.self.descriptionTextView.text forKey:@"description"];


    
    // Photos are public, but may only be modified by the user who uploaded them
//    PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
//    [photoACL setPublicReadAccess:YES];
//    photo.ACL = photoACL;
    
    // Request a background execution task to allow us to finish uploading
    // the photo even if the app is sent to the background
    self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Save the Photo PFObject
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            NSLog(@"Photo failed to save: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }else{
            NSLog(@"Photo Saved!");
            
            //set current user
            PFUser *currentUser = [PFUser currentUser];
            
            //query for the current chatroom from local datastore
            PFQuery *query = [[PFQuery alloc] initWithClassName:@"Chatrooms"];
            [query whereKey:@"clientUser" equalTo:currentUser];
            [query fromLocalDatastore];
            
            //get the chatroom
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if(!error){
                    _chatroom = object;
                    //set coach user
                    PFUser *coachUser = object[@"dietitianUser"];
                    
                    //Prepare push
                    PFQuery *pushQuery = [PFInstallation query];
                    NSDictionary *data = [[NSDictionary alloc] init];
                    
                    //query instals for coach user device
                    [pushQuery whereKey:@"user" equalTo:coachUser];
                    
                    //set message
                    NSString *message = [NSString stringWithFormat:@"Check out what %@ %@ just ate! :)", currentUser[@"firstName"],currentUser[@"lastName"]];
                    
                    //set the data info for the push
                    data = [NSDictionary dictionaryWithObjectsAndKeys:
                            message, @"alert",
                            @"default", @"sound",
                            @"nom", @"type",
                            nil];
                    
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery];
                    [push setData:data];
                    [push sendPushInBackground];
                    
                    //mixpanel tracking
                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                    [mixpanel track:@"Meal Saved"];

                    
                }
                else{
                    NSLog(@"SEAN: %@", error);
                    //[ParseErrorHandlingController handleParseError:error];
                }
            }];
            
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
    }];
    
    // Dismiss this screen...success
    
    [self imageSaveSuccessful];
    self.activityIndicatorContainer.hidden = YES;
    [self.photoTakenActivityIndicator stopAnimating];
    
             
}

- (void)imageSaveSuccessful{
    //image was successfuly saved
    //do sumin
    
    //load original nav bar
    self.navBar.hidden = true;

    [self.descriptionTextView resignFirstResponder];
 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [self.view removeConstraints:self.verticalConstraints];
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                    
                         [self.detailsContainerView removeFromSuperview];
                         [self.hashtagsContainer removeFromSuperview];
                         self.bottomContainerView.hidden = NO;
                         [self.saveButton removeFromSuperview];
                         self.captureButton.hidden = NO;
                         self.capturedImageView.image = nil;
                         
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}



- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    NSLog(@"Started editing textview!");
    
    if([self.descriptionTextView.text isEqualToString:@"Description..."]){
        self.descriptionTextView.text = nil;
    }
    
    //go away cancel button
    self.navigationItem.leftBarButtonItem = nil;
    
    //set right button to done
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)doneEditing{
    
    //resign keyboard
    [self.descriptionTextView resignFirstResponder];
    
    //declare left bar button to cancel
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    
    //set left button to cancel
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //set right button to nothing
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.view bringSubviewToFront:self.saveButton];

  
}

- (void)didEnterForeground{
    NSLog(@"did enter foreground");
    [self initializeCamera:self.cameraView];
    [self checkTrialEnd];
}

- (void)didEnterBackground{
    NSLog(@"did enter background");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_session stopRunning];
        //[self.captureLayer removeFromSuperlayer];
    });

}


- (void)checkTrialEnd{
    
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //
            if(!error){
                NSDate *trialEndDate = [PFUser currentUser][@"trialEndDate"];
                
                NSDate *today = [NSDate date]; // it will give you current date
                //NSDate *newDate = [dateFormatter dateWithString:@"xxxxxx"]; // your date
                
                NSComparisonResult result;
                //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
                
                result = [today compare:trialEndDate]; // comparing two dates
                
            
                if([PFUser currentUser][@"trialEndDate"] && result==NSOrderedDescending){
                    //trial period is up!
                    
                    //query for the current chatroom
                    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Chatrooms"];
                    [query whereKey:@"clientUser" equalTo:[PFUser currentUser]];
                    [query fromLocalDatastore];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                        
                        if (!error) {
                            NSLog(@"check for trial: using local object");
                            _chatroom = object;
                            [self performSegueWithIdentifier:@"trialEnded" sender:self];
                        }else{
                            PFQuery *query = [[PFQuery alloc] initWithClassName:@"Chatrooms"];
                            [query whereKey:@"clientUser" equalTo:[PFUser currentUser]];
                            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                
                                if (!error) {
                                    NSLog(@"check for trial: using network object");

                                    _chatroom = object;
                                    [object pinInBackground];
                                    [self performSegueWithIdentifier:@"trialEnded" sender:self];
                                }
                            
                            }];
                        }
                        
                       
                    }];
                    
                    UIAlertView *trialAlert = [[UIAlertView alloc] initWithTitle:@"Membership Renewal" message:@"Your membership period has ended, please complete payment to continue workign with your coach" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles: nil];
                    
                    [trialAlert show];
                    
                }else{
                    
                }

            }
        }];
    
    //this the logic for testing the date in case we want to do other stuff
    //        if(result==NSOrderedAscending)
    //            NSLog(@"today is before the trial end date...it is coming up!");
    //        else if(result==NSOrderedDescending)
    //            NSLog(@"Today is after the day the trial ended. Which means the user must upgrade. ");
    //        else
    //            NSLog(@"Today is the last day of the trial. It's ending tomorrow");
    //        


}


@end
