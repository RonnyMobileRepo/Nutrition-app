//
//  CoachBioViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 10/27/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "CoachBioViewController.h"

@interface CoachBioViewController (){
    
    NSString *coachNameString;
    NSString *coachCityString;
    NSString *coachBioString;
    PFFile *coachImageFile;
    NSArray *coachSpecialitesArray;
    PFImageView *profileImageView;
    UISwipeGestureRecognizer *swipeGesture;
    

}

@end

//constants
CGFloat const kTopMargin = 45.0; //add 20 pts for status bar
CGFloat const kSideMargin = 30.0;
CGFloat const kSpaceBetweenCards = 10.0;
CGFloat const kSpaceBetweenProfText = 5.0;
CGFloat const kProfileImageSize = 125.0;
CGFloat const kInsideCardMargin = 10.0;
CGFloat const kleftMarginBullets = 35.0;
CGFloat const kbulletTextHeight = 15.0;
CGFloat const kInbetweenMartin = 5.0;



@implementation CoachBioViewController

- (id)initWith:(PFObject *)coachObject_

{
    self = [super init];
    
    //coach information
    coachNameString = [coachObject_ objectForKey:@"firstName"];
    coachCityString = [coachObject_ objectForKey:@"city"];
    coachBioString = [coachObject_ objectForKey:@"bio"];
    //coachSpecialitesArray = [coachObject_ objectForKey:@""];
    
    //coach profile image
    PFFile *profileFile = [coachObject_ objectForKey:@"photo"];
    coachImageFile = profileFile;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(detectSwipe)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeGesture];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    
    coachSpecialitesArray = [[NSArray alloc] initWithObjects:@"Lose Weight",@"Gain Weight",@"Marathon",@"Energy",@"Eat Better",@"Sports", nil];
    
    
    [self loadElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadElements{
    
    //load background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smoothie-stomach.jpg"]];
    backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backgroundImage];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [backgroundImage addSubview:effectView];
    
    //x button
    UIButton *closeButton = [[UIButton alloc]init];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closeButtonPressedy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    //first card
    UIView *topCardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    topCardView.backgroundColor = [UIColor whiteColor];
    topCardView.translatesAutoresizingMaskIntoConstraints = NO;
    topCardView.layer.cornerRadius = 6.0;
    topCardView.backgroundColor = [UIColor whiteColor];
    topCardView.layer.shadowOffset = CGSizeMake(4, 4);
    topCardView.layer.shadowColor = [[UIColor colorWithRed:111.0/255.0 green:178.0/255.0 blue:155.0/255.0 alpha:1] CGColor];
    topCardView.layer.shadowRadius = 0.0f;
    topCardView.layer.shadowOpacity = 0.80f;
    [self.view addSubview:topCardView];
    
    //second card
    UIView *bottonCardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bottonCardView.backgroundColor = [UIColor whiteColor];
    bottonCardView.translatesAutoresizingMaskIntoConstraints = NO;
    bottonCardView.layer.cornerRadius = 6.0;
    bottonCardView.backgroundColor = [UIColor whiteColor];
    bottonCardView.layer.shadowOffset = CGSizeMake(4, 4);
    bottonCardView.layer.shadowColor = [[UIColor colorWithRed:111.0/255.0 green:178.0/255.0 blue:155.0/255.0 alpha:1] CGColor];
    bottonCardView.layer.shadowRadius = 0.0f;
    bottonCardView.layer.shadowOpacity = 0.80f;
    [self.view addSubview:bottonCardView];
    
    //profile picture
    profileImageView = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"Brittany-Icon.png"]];
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    profileImageView.layer.cornerRadius = kProfileImageSize / 2;
    profileImageView.layer.borderWidth = 4.0;
    profileImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    profileImageView.clipsToBounds = YES;
    [topCardView addSubview:profileImageView];
    profileImageView.file = coachImageFile;
    [profileImageView loadInBackground];
    
    //bio text
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.text = coachBioString;
    [textView setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [topCardView addSubview:textView];
    
    //name label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.text = coachNameString;
    [topCardView addSubview:nameLabel];
    
    //location label
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cityLabel.text = coachCityString;
    [cityLabel setFont:[UIFont fontWithName:kFontFamilyName size:12]];
    cityLabel.textColor = [UIColor grayColor];
    [topCardView addSubview:cityLabel];
    
    //card two title label
    UILabel *specialitesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    specialitesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    specialitesLabel.text = @"Specialties:";
    [specialitesLabel setFont:[UIFont fontWithName:kFontFamilyName size:20]];
    specialitesLabel.textColor = [UIColor blackColor];
    [bottonCardView addSubview:specialitesLabel];

    //button 1
    UIButton *bullet1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet1.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet1 setTitle: coachSpecialitesArray[0] forState:UIControlStateNormal];
    [bullet1.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet1.layer setBorderWidth:2];
    bullet1.layer.cornerRadius = 4;
    [bullet1.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet1];
    
    //button 2
    UIButton *bullet2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet2.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet2 setTitle: coachSpecialitesArray[1] forState:UIControlStateNormal];
    [bullet2.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet2.layer setBorderWidth:2];
    bullet2.layer.cornerRadius = 4;
    [bullet2.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet2];

    //button 3
    UIButton *bullet3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet3.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet3 setTitle: coachSpecialitesArray[2] forState:UIControlStateNormal];
    [bullet3.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet3 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet3.layer setBorderWidth:2];
    bullet3.layer.cornerRadius = 4;
    [bullet3.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet3];
    
    //button 4
    UIButton *bullet4 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet4.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet4 setTitle: coachSpecialitesArray[3] forState:UIControlStateNormal];
    [bullet4.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet4 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet4.layer setBorderWidth:2];
    bullet4.layer.cornerRadius = 4;
    [bullet4.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet4];

    //button 5
    UIButton *bullet5 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet5.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet5 setTitle: coachSpecialitesArray[4] forState:UIControlStateNormal];
    [bullet5.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet5 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet5 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet5.layer setBorderWidth:2];
    bullet5.layer.cornerRadius = 4;
    [bullet5.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet5];

    //button 6
    UIButton *bullet6 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet6.translatesAutoresizingMaskIntoConstraints = NO;
    [bullet6 setTitle: coachSpecialitesArray[5] forState:UIControlStateNormal];
    [bullet6.titleLabel setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bullet6 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [bullet6 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [bullet6.layer setBorderWidth:2];
    bullet6.layer.cornerRadius = 4;
    [bullet6.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    [bottonCardView addSubview:bullet6];
    
    //constraints
    
    //calc height of top card with screen height
    CGFloat screenHeight = (self.view.bounds.size.height/1.6);
    CGFloat screenWidth = (self.view.bounds.size.width);

    CGFloat bottomCardWidth = screenWidth - (kSideMargin*2);
    CGFloat buttonWidths = (bottomCardWidth - ((kInbetweenMartin * 2) + (kInsideCardMargin * 2)))/3;
    

    //convert floats to nsnumber for the constraint dictionary
    NSNumber *aNumber = [NSNumber numberWithFloat:screenHeight];
    NSNumber *topMargin = [NSNumber numberWithFloat:kTopMargin];
    NSNumber *sideMargin = [NSNumber numberWithFloat:kSideMargin];
    NSNumber *betweenCards = [NSNumber numberWithFloat:kSpaceBetweenCards];
    NSNumber *profileImage = [NSNumber numberWithFloat:kProfileImageSize];
    NSNumber *insideCardMargin = [NSNumber numberWithFloat:kInsideCardMargin];
    NSNumber *spaceBetweenProfText = [NSNumber numberWithFloat:kSpaceBetweenProfText];
    NSNumber *buttonWidth = [NSNumber numberWithFloat:buttonWidths];
    NSNumber *inbetween = [NSNumber numberWithFloat:kInbetweenMartin];



    NSDictionary *views = @{@"background": backgroundImage,
                            @"topCard":topCardView,
                            @"close":closeButton,
                            @"bottomCard": bottonCardView,
                            @"profileImage":profileImageView,
                            @"bioText":textView,
                            @"nameLabel":nameLabel,
                            @"city": cityLabel,
                            @"card2Title": specialitesLabel,
                            @"bullet1": bullet1,
                            @"bullet2": bullet2,
                            @"bullet3": bullet3,
                            @"bullet4": bullet4,
                            @"bullet5": bullet5,
                            @"bullet6": bullet6};
    
    NSDictionary *metrics = @{@"topCardHeight" :  aNumber,
                              @"topMargin": topMargin,
                              @"sideMargin": sideMargin,
                              @"betweenCards":betweenCards,
                              @"profileImageSize":profileImage,
                              @"insideMargin":insideCardMargin,
                              @"spaceProfText":spaceBetweenProfText,
                              @"buttonWidth":buttonWidth,
                              @"inbetween": inbetween};

    
    
    //background image
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[background]-(0)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //center
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:backgroundImage
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];
    
    //make square
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:backgroundImage
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:backgroundImage
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                                            constant:0.0f]];
 
    //close button
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(10)-[close(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[close(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //top card
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(topMargin)-[topCard(topCardHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(sideMargin)-[topCard]-(sideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //bottom card
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(sideMargin)-[bottomCard]-(sideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topCard]-(betweenCards)-[bottomCard(125)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //profile image****not done
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-20)-[profileImage(profileImageSize)]"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-20)-[profileImage(profileImageSize)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //bio text
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insideMargin)-[bioText]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[profileImage]-(spaceProfText)-[bioText]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    //name Label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[profileImage]-(insideMargin)-[nameLabel]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(15)-[nameLabel(15)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //city label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[profileImage]-(insideMargin)-[city]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel]-(0)-[city(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //specialties
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insideMargin)-[card2Title]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(insideMargin)-[card2Title(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

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

-(void)closeButtonPressedy{
    NSLog(@"close button pressed");
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void)detectSwipe{
    [self dismissViewControllerAnimated:YES completion:^{
    //
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
