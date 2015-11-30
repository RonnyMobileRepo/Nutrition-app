//
//  CoachPageContentViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 11/17/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "CoachPageContentViewController.h"
#import "SignUpConversationViewController.h"

@interface CoachPageContentViewController ()

@end

CGFloat const kTopMargin1 = 45.0; //add 20 pts for status bar
CGFloat const kSideMargin1 = 35.0; //between card and edge
CGFloat const kInsideCardMargin1 = 5.0;
CGFloat const kleftMarginBullets1 = 10.0;
CGFloat const kbulletTextHeight1 = 15.0;
CGFloat const kInbetweenMartin1 = 5.0;



@implementation CoachPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //**set this fromt he user passed to us (coachUserObject)
    PFUser *coachUser = _coachUserObject;
    
    [coachUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //get coach user info
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",[coachUser valueForKey:@"firstName"], [coachUser valueForKey:@"lastName"]];
        NSString *aboutMeString = coachUser[@"aboutMe"];
        NSString *myPhilString = coachUser[@"myPhilosophy"];
        NSString *cityString = coachUser[@"city"];
        _coachSpecialitesArray = [[NSMutableArray alloc] initWithArray:coachUser[@"goals"]];
        NSLog(@"coach goals ar %@", _coachSpecialitesArray);
        PFFile *imageFile = coachUser[@"photo"];


        
        
        //background image
        _backgroundImageView.file = imageFile;
        [_backgroundImageView loadInBackground];

        //profile image
        _roundProfileImageView.file = imageFile;
        [_roundProfileImageView loadInBackground];
        
        //first name last initian Sean C.
        NSArray* firstLastStrings = [fullName componentsSeparatedByString:@" "];
        NSString* firstName = [firstLastStrings objectAtIndex:0];
        NSString* lastName = [firstLastStrings objectAtIndex:1];
        char lastInitialChar = [lastName characterAtIndex:0];
        NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar];
        self.coachLabel.text = newNameStr;

        //about me
        _aboutMeTextView.text = aboutMeString;
        _philTextView.text = myPhilString;
        _cityLabel.text = cityString;
        
       
        
        //text views
        [_aboutMeTextView setTextColor:[UIColor whiteColor]];
        [_aboutMeTextView setFont:[UIFont fontWithName:kFontFamilyName100 size:14.0]];
        [_philTextView setTextColor:[UIColor whiteColor]];
        [_philTextView setFont:[UIFont fontWithName:kFontFamilyName100 size:14.0]];
        
        [self loadButtons];

    }];
    
    
    
    //LOAD STYLES
    //CARDVIEW NOT VISIBLE
    [_cardView setBackgroundColor:[UIColor clearColor]];
    _cardView.layer.cornerRadius = 20.0;
    
    //IMAGE
    _backgroundImageView.layer.cornerRadius = 20.0;
    _backgroundImageView.layer.masksToBounds = YES; //need this for corner radius
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [_backgroundImageView addSubview:effectView];
    
    _roundProfileImageView.layer.cornerRadius = _roundProfileImageView.frame.size.width / 2;
    _roundProfileImageView.clipsToBounds = YES;

    //BUTTON
    _goButton.layer.borderWidth = 1.0;
    [_goButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    _goButton.layer.cornerRadius = 6.0;
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender {
    // Xcode will complain if we access a weak property more than
    // once here, since it could in theory be nilled between accesses
    // leading to unpredictable results. So we'll start by taking
    // a local, strong reference to the delegate.
    id<CoachCardDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(childViewController:didChooseCoach:)]) {
        [strongDelegate childViewController:self didChooseCoach:_coachUserObject];
    }

}

- (void)loadButtons{
    //button 1
    UIButton *bullet1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet1.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet1.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet1.layer setBorderWidth:2];
    bullet1.layer.cornerRadius = 4;
    [bullet1.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet1.hidden = true;
    [_cardView addSubview:bullet1];
    
    //button 2
    UIButton *bullet2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet2.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet2.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet2.layer setBorderWidth:2];
    bullet2.layer.cornerRadius = 4;
    [bullet2.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet2.hidden = true;
    [_cardView addSubview:bullet2];
    
    //button 3
    UIButton *bullet3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet3.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet3.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet3.layer setBorderWidth:2];
    bullet3.layer.cornerRadius = 4;
    [bullet3.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet3.hidden = true;
    [_cardView addSubview:bullet3];
    
    //button 4
    UIButton *bullet4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet4.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet4.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet4.layer setBorderWidth:2];
    bullet4.layer.cornerRadius = 4;
    [bullet4.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet4.hidden = true;
    [_cardView addSubview:bullet4];
    
    //button 5
    UIButton *bullet5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet5.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet5.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet5 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet5 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet5.layer setBorderWidth:2];
    bullet5.layer.cornerRadius = 4;
    [bullet5.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet5.hidden = true;
    [_cardView addSubview:bullet5];
    
    //button 6
    UIButton *bullet6 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet6.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet6.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:14]];
    [bullet6 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bullet6 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet6.layer setBorderWidth:2];
    bullet6.layer.cornerRadius = 4;
    [bullet6.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    bullet6.hidden = true;
    [_cardView addSubview:bullet6];
    
    
    //set titles
    if(_coachSpecialitesArray.count > 0){
        [bullet1 setTitle: _coachSpecialitesArray[0] forState:UIControlStateNormal];
        bullet1.hidden = false;
        
    }
    
    if(_coachSpecialitesArray.count > 1){
        [bullet2 setTitle: _coachSpecialitesArray[1] forState:UIControlStateNormal];
        bullet2.hidden = false;
    }
    
    if(_coachSpecialitesArray.count > 2){
        [bullet3 setTitle: _coachSpecialitesArray[2] forState:UIControlStateNormal];
        bullet3.hidden = false;
    }
    
    if(_coachSpecialitesArray.count > 3){
        [bullet4 setTitle: _coachSpecialitesArray[3] forState:UIControlStateNormal];
        bullet4.hidden = false;
    }
    
    if(_coachSpecialitesArray.count > 4){
        [bullet5 setTitle: _coachSpecialitesArray[4] forState:UIControlStateNormal];
        bullet5.hidden = false;
    }
    
    if(_coachSpecialitesArray.count > 5){
        [bullet6 setTitle: _coachSpecialitesArray[5] forState:UIControlStateNormal];
        bullet6.hidden = false;
    }
    
    //constraints
    
    //calc height of top card with screen height
    CGFloat screenHeight = (self.view.bounds.size.height/1.6);
    CGFloat screenWidth = (self.view.bounds.size.width);
    
    CGFloat bottomCardWidth = screenWidth - (kSideMargin1*2);
    CGFloat buttonWidths = (bottomCardWidth - ((kInbetweenMartin1 * 2) + (kInsideCardMargin1 * 2)))/3;
    
    
    //convert floats to nsnumber for the constraint dictionary
    NSNumber *aNumber = [NSNumber numberWithFloat:screenHeight];
    NSNumber *topMargin = [NSNumber numberWithFloat:kTopMargin1];
    NSNumber *sideMargin = [NSNumber numberWithFloat:kSideMargin1];
    NSNumber *insideCardMargin = [NSNumber numberWithFloat:kInsideCardMargin1];
    NSNumber *buttonWidth = [NSNumber numberWithFloat:buttonWidths];
    NSNumber *inbetween = [NSNumber numberWithFloat:kInbetweenMartin1];
    
    
    
    NSDictionary *views = @{@"card2Title": _specialtiesTitleLabe,
                            @"bottomCard": _cardView,
                            @"bullet1": bullet1,
                            @"bullet2": bullet2,
                            @"bullet3": bullet3,
                            @"bullet4": bullet4,
                            @"bullet5": bullet5,
                            @"bullet6": bullet6};
    
    NSDictionary *metrics = @{@"topCardHeight" :  aNumber,
                              @"topMargin": topMargin,
                              @"sideMargin": sideMargin,
                              @"insideMargin":insideCardMargin,
                              @"buttonWidth":buttonWidth,
                              @"inbetween": inbetween};
    

    
    //button 1
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insideMargin)-[bullet1(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[card2Title]-(insideMargin)-[bullet1(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //button 2
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[bullet1]-(inbetween)-[bullet2(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[card2Title]-(insideMargin)-[bullet2(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    //button 3
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[bullet2]-(inbetween)-[bullet3(buttonWidth)]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[card2Title]-(insideMargin)-[bullet3(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    //button 4
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insideMargin)-[bullet4(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet1]-(inbetween)-[bullet4(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //button 5
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[bullet4]-(inbetween)-[bullet5(buttonWidth)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet2]-(inbetween)-[bullet5(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //button 6
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[bullet5]-(inbetween)-[bullet6(buttonWidth)]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet3]-(inbetween)-[bullet6(30)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    

}

@end
