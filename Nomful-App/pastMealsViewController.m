//
//  pastMealsViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/16/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "pastMealsViewController.h"
#import "imageDetailViewController.h"
#import "MealDetailCardViewController.h"

@interface pastMealsViewController ()

@end

@implementation pastMealsViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    //we need to do initWithCoder since we're using storyboards
    //if we were doing this programmaticlly it would be the usual initWithStyle
    
    self = [super initWithCoder:aCoder];
    if (self) {
        
        //set the current user
        self.currentUser = [PFUser currentUser];
        
        // The className to query on
        self.parseClassName = @"Meals";
        
        // The key of the PFObject to display in the label of the default cell style
        //self.textKey = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        //set number of objects per page
        self.objectsPerPage = 10;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"loading view did load");
    
    //set public property to the clientUser object
    self.clientUser = self.chatroomObject[@"clientUser"];
    
    //get the first name of the client
    NSString *clientName = self.clientUser[@"firstName"];
    
    //set the title of the view to the client first name
    self.title = clientName;
    
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIFont fontWithName:kFontFamilyName size:20] forKey:NSFontAttributeName];
    [titleBarAttributes setValue:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
    
    UIBarButtonItem *leftCancel = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
    self.navigationItem.leftBarButtonItem = leftCancel;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];

  
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //sets the image size to half sreen...fits two per row
    CGSize width = CGSizeMake(self.view.bounds.size.width/2, self.view.bounds.size.width/2);
    
    return width;
    
}

- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:^{
        //doo soomthign
    }];
}

- (PFQuery *)queryForCollection{
    NSLog(@"loading query");
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //        if (self.objects.count == 0) {
    //            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //        }
    
    //if the userObject is the same as our cuurent client...yayshark!
    [query whereKey:@"userObject" equalTo:self.currentUser];
    [query orderByDescending:@"createdAt"];
    
    return query;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    static NSString *identifier = @"Cell";
    
    ClientMealsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //Get the meal image FILE from parse
    PFFile *thumbnail = [object objectForKey:@"mealPhoto"];
    
    //set the custom cell mealImage property to the placeholder image
    cell.mealImageView.image = [UIImage imageNamed:@"profilePlaceholder.png"];
    
    //set the FILE of the custom cell mealImage property to the thumbnail from parse
    cell.mealImageView.file = thumbnail;
    
    //load the image in the background....parse you are amazing
    [cell.mealImageView loadInBackground];
    
    //cell.mealTimeLabel.text = object.createdAt;
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //get the meal object
    PFObject *objectd = [self.objects objectAtIndex:indexPath.row];
    
    //instantiate the detail view with the meal description and image file
    MealDetailCardViewController *mealView = [[MealDetailCardViewController alloc] initWith:objectd];
    
    //add to nav stack
    [self.navigationController pushViewController:mealView animated:YES];
    
    //log event in mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Meal Detail Viewed" properties:@{@"Meal_ID":objectd.objectId}];
    
    [self.collectionView
     deselectItemAtIndexPath:indexPath animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showMealImageSegue"]) {
        imageDetailViewController *vc = segue.destinationViewController;
        vc.objectFromSegue = sender;
        vc.chatroomObject = _chatroomObject;
    }
}




@end
