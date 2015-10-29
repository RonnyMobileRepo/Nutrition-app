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



@implementation CoachBioViewController

- (id)initWith:(PFObject *)coachObject_

{
    self = [super init];
    
    //coach information
    coachNameString = [coachObject_ objectForKey:@""];
    coachCityString = [coachObject_ objectForKey:@""];
    coachBioString = [coachObject_ objectForKey:@""];
    coachSpecialitesArray = [coachObject_ objectForKey:@""];
    
    //coach profile image
    PFFile *profileFile = [coachObject_ objectForKey:@"photo"];
    coachImageFile = profileFile;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    
    coachSpecialitesArray = [[NSArray alloc] initWithObjects:@"Sex",@"Pre-Natal",@"Weight Loss",@"Sports Nutrition",@"Eating Better Bitches", nil];
    
    [self loadElements];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadElements{
    
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
    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Brittany-Icon.png"]];
    profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
    profileImageView.layer.cornerRadius = kProfileImageSize / 2;
    profileImageView.layer.borderWidth = 4.0;
    profileImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    profileImageView.clipsToBounds = YES;
    
    [topCardView addSubview:profileImageView];
    
    //bio text
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.text = @" \"Hi! I'm Brittany Chin :) horseradish azuki bean lettuce avocado asparagus okra. Kohlrabi radish okra azuki bean corn fava bean mustard tigernut jÃ­cama green bean celtuce collard greens avocado quandong fennel gumbo black-eyed pea. Grape silver beet watercress potato tigernut corn groundnut. Chickweed okra pea winter purslane coriander yarrow sweet pepper radish garlic brussels sprout groundnut summer purslane earthnut pea tomato spring onion azuki bean gourd. Gumbo kakadu plum komatsuna black-eyed pea green bean zucchini gourd winter purslane silver beet rock.\" ";
    [textView setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [topCardView addSubview:textView];
    
    //name label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.text = @"Brittany Chin, RD";
    [topCardView addSubview:nameLabel];
    
    //location label
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
    cityLabel.text = @"Chicago, IL";
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

    //bullet 1
    UILabel *bullet1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet1.translatesAutoresizingMaskIntoConstraints = NO;
    bullet1.text = coachSpecialitesArray[0];
    [bullet1 setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bottonCardView addSubview:bullet1];

    //bullet 2
    UILabel *bullet2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet2.translatesAutoresizingMaskIntoConstraints = NO;
    bullet2.text = coachSpecialitesArray[1];
    [bullet2 setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bottonCardView addSubview:bullet2];
    
    //bullet 3
    UILabel *bullet3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet3.translatesAutoresizingMaskIntoConstraints = NO;
    bullet3.text = coachSpecialitesArray[2];
    [bullet3 setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bottonCardView addSubview:bullet3];
    
    //bullet 4
    UILabel *bullet4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    bullet4.translatesAutoresizingMaskIntoConstraints = NO;
    bullet4.text = coachSpecialitesArray[3];
    [bullet4 setFont:[UIFont fontWithName:kFontFamilyName size:15]];
    [bottonCardView addSubview:bullet4];

    //constraints
    
    //calc height of top card with screen height
    CGFloat screenHeight = (self.view.bounds.size.height/1.6);
    
    //convert floats to nsnumber for the constraint dictionary
    NSNumber *aNumber = [NSNumber numberWithFloat:screenHeight];
    NSNumber *topMargin = [NSNumber numberWithFloat:kTopMargin];
    NSNumber *sideMargin = [NSNumber numberWithFloat:kSideMargin];
    NSNumber *betweenCards = [NSNumber numberWithFloat:kSpaceBetweenCards];
    NSNumber *profileImage = [NSNumber numberWithFloat:kProfileImageSize];
    NSNumber *insideCardMargin = [NSNumber numberWithFloat:kInsideCardMargin];
    NSNumber *spaceBetweenProfText = [NSNumber numberWithFloat:kSpaceBetweenProfText];
    NSNumber *leftMarginBullets = [NSNumber numberWithFloat:kleftMarginBullets];
    NSNumber *bulletHeight = [NSNumber numberWithFloat:kbulletTextHeight];

    
    

    
  
    NSDictionary *views = @{@"topCard":topCardView,
                            @"bottomCard": bottonCardView,
                            @"profileImage":profileImageView,
                            @"bioText":textView,
                            @"nameLabel":nameLabel,
                            @"city": cityLabel,
                            @"specialties":specialitesLabel,
                            @"bullet1": bullet1,
                            @"bullet2":bullet2,
                            @"bullet3":bullet3,
                            @"bullet4":bullet4};
    
    NSDictionary *metrics = @{@"topCardHeight" :  aNumber,
                              @"topMargin": topMargin,
                              @"sideMargin": sideMargin,
                              @"betweenCards":betweenCards,
                              @"profileImageSize":profileImage,
                              @"insideMargin":insideCardMargin,
                              @"spaceProfText":spaceBetweenProfText,
                              @"leftMargin": leftMarginBullets,
                              @"bulletHeight":bulletHeight};

 
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
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[topCard]-(betweenCards)-[bottomCard]-(sideMargin)-|"
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
    
    //city labe;
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[profileImage]-(insideMargin)-[city]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nameLabel]-(0)-[city(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    //card two label
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(insideMargin)-[specialties]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(insideMargin)-[specialties(20)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //bullets 1
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[specialties]-(15)-[bullet1(bulletHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftMargin)-[bullet1]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //bullets 2
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet1]-(10)-[bullet2(bulletHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftMargin)-[bullet2]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

    //bullets 3
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet2]-(10)-[bullet3(bulletHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftMargin)-[bullet3]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    //bullets 3
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bullet3]-(10)-[bullet4(bulletHeight)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftMargin)-[bullet4]-(insideMargin)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];

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
