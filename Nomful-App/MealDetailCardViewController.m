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
}

@end

@implementation MealDetailCardViewController


- (id)initWith:(PFFile *)mealImage_ withDescriptionText:(NSString *)mealDescription_

{
    self = [super init];
    mealImageFile = mealImage_;
    mealDescription = mealDescription_;
    self.view.backgroundColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadElements];
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
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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
@end
