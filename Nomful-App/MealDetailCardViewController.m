//
//  MealDetailCardViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 10/21/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "MealDetailCardViewController.h"

@interface MealDetailCardViewController (){
    
    PFFile *mealImageFile;
    NSString *mealDescription;
    UIView *container;
    NSArray *hashtagArray;
}

@end

@implementation MealDetailCardViewController


- (id)initWith:(PFObject *)mealObject_

{
    self = [super init];
    
    //Get the meal image FILE from parse
    PFFile *mealFile = [mealObject_ objectForKey:@"mealPhoto"];
    mealImageFile = mealFile;
    
    mealDescription = [mealObject_ objectForKey:@"description"];
    hashtagArray = [mealObject_ objectForKey:@"hashtagsArrays"];
    NSLog(@"hash array: %@", hashtagArray);
    
    self.title = [self timestampFormatter:mealObject_.createdAt];
    
    self.brandColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    self.view.backgroundColor = _brandColor;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadElements];
    [self loadHashtagButtons];
    [self selectHashtagButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helper Methods

-(void)loadElements{
    NSLog(@"Meal Detail: Loading Elements");
    
    //container view
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:container];
    
    //container design
    container.layer.cornerRadius = 6.0;
    container.backgroundColor = [UIColor whiteColor];
    container.layer.shadowOffset = CGSizeMake(4, 4);
    container.layer.shadowColor = [[UIColor colorWithRed:111.0/255.0 green:178.0/255.0 blue:155.0/255.0 alpha:1] CGColor];
    container.layer.shadowRadius = 0.0f;
    container.layer.shadowOpacity = 0.80f;

    //imageview
    PFImageView *imageView = [[PFImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.file = mealImageFile;
    [imageView loadInBackground];
    [container addSubview:imageView];
    
    //uitextview
    UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionTextView.text = mealDescription;
    [container addSubview:descriptionTextView];
    
    
    //constraints
    
    NSDictionary *views = @{@"container": container,
                            @"imageView": imageView,
                            @"description": descriptionTextView};
    
    
    //profile image is 8 pts from top and 100 pts tall
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(80)-[container]-(15)-|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[container]-(10)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //image view
    [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[imageView]-(5)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[imageView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //description text
    [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(5)-[description]-(5)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView]-(5)-[description]-(5)-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
   
    [self.view addConstraint: [NSLayoutConstraint constraintWithItem:imageView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:imageView
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                                            constant:0.0f]];
    
}

- (void)loadHashtagButtons{
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
    
    NSString *fontFamily = kFontFamilyName;
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
    [container addSubview:self.breakfastButton];
    [container addSubview:self.lunchButton];
    [container addSubview:self.dinnerButton];
    [container addSubview:self.snackButton];
    [container addSubview:self.coffeeButton];
    [container addSubview:self.makeYourOwnButton];
    
    [self loadHashtagsConstraints];
    
    
}

- (void)loadHashtagsConstraints{
    NSDictionary *views = @{@"breakfast"    :   self.breakfastButton,
                            @"lunch"         :   self.lunchButton,
                            @"dinner"        :   self.dinnerButton,
                            @"snack"         :   self.snackButton,
                            @"coffee"        :   self.coffeeButton,
                            @"nomful"       :   self.makeYourOwnButton
                            };
    
    NSDictionary *metrics = @{@"buttonWidth"    :   @30,
                              @"buttonLength"   :   @100};
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[breakfast(buttonWidth)]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[breakfast(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[lunch(buttonWidth)]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[breakfast]-(10)-[lunch(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[dinner(buttonWidth)]-(10)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[lunch]-(10)-[dinner(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[snack(buttonWidth)]-(10)-[breakfast]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[snack(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[coffee(buttonWidth)]-(10)-[lunch]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[snack]-(10)-[coffee(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nomful(buttonWidth)]-(10)-[dinner]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[coffee]-(10)-[nomful(buttonLength)]"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    
    
    
}

-(void)selectHashtagButtons{
    
    for (NSString *hashtag in hashtagArray) {
        
        if ([hashtag isEqualToString:@"#lunch"]) {
            _lunchButton.selected = YES;
            [_lunchButton setBackgroundColor:self.brandColor];
            [_lunchButton.layer setBorderColor:[self.brandColor CGColor]];
            
        }
        if ([hashtag isEqualToString:@"#breakfast"]) {
            _breakfastButton.selected = YES;
            [_breakfastButton setBackgroundColor:self.brandColor];
            [_breakfastButton.layer setBorderColor:[self.brandColor CGColor]];
            
        }
        if ([hashtag isEqualToString:@"#dinner"]) {
            _dinnerButton.selected = YES;
            [_dinnerButton setBackgroundColor:self.brandColor];
            [_dinnerButton.layer setBorderColor:[self.brandColor CGColor]];

            
        }
        if ([hashtag isEqualToString:@"#snack"]) {
            _snackButton.selected = YES;
            [_snackButton setBackgroundColor:self.brandColor];
            [_snackButton.layer setBorderColor:[self.brandColor CGColor]];

            
        }
        if ([hashtag isEqualToString:@"#fluid"]) {
            _coffeeButton.selected = YES;
            [_coffeeButton setBackgroundColor:self.brandColor];
            [_coffeeButton.layer setBorderColor:[self.brandColor CGColor]];

            
        }
        if ([hashtag isEqualToString:@"#nomful"]) {
            _makeYourOwnButton.selected = YES;
            [_makeYourOwnButton setBackgroundColor:self.brandColor];
            [_makeYourOwnButton.layer setBorderColor:[self.brandColor CGColor]];

        }
       
    }
    
}

- (NSString *)timestampFormatter:(NSDate *)date{
    
    //decalre new formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //set variable time to the DATE (when photo was taken) passed from the cellForRowAtIndexPath
    NSDate *time = date;
    
    //set NSDateComponents to the date the photo was taken
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:time];
    
    //set a variable for TODAY with current time
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    
    //if the timestamp of when the photo was taken is equal to today...
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        
        //...then we set the format to "Today at 2:43 PM"
        [formatter setDateFormat:@"h:mm a"];
        NSString *todayDate = [formatter stringFromDate:time];
        NSString *returnString = [NSString stringWithFormat:@"Today at %@", todayDate];
        
        return returnString;
        
    }else{
        //..if the time of the photo taken is NOT today...
        
        //...then we set the format of the stamp to "April 07 at 2:43 PM"
        [formatter setDateFormat:@"MMMM dd"];
        
        //set a string to the timestamp from time of photo taken (time)
        NSString *dateString = [formatter stringFromDate:time];
        
        //sets the hour format
        [formatter setDateFormat:@"h:mm a"];
        NSString *timeString = [formatter stringFromDate:time];
        
        //final built string combinging the month and day with the time "April 07" + "2:43 PM"
        NSString *messageDate = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
        return messageDate;
    }
    
}

@end
