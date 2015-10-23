//
//  ClientCollectionViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ClientCollectionViewController.h"
#import "MealDetailCardViewController.h"

@interface ClientCollectionViewController ()

@end

@implementation ClientCollectionViewController

- (id)initWithCoder:(NSCoder *)aCoder
{
    //we need to do initWithCoder since we're using storyboards
    //if we were doing this programmaticlly it would be the usual initWithStyle
    
    self = [super initWithCoder:aCoder];
    if (self) {
        
        //I'm not sure why...but it errors out if we don't set the key here as well...
        //will test this again once viewcontroller is in the navigation and not stand alone
//        [Parse setApplicationId:@"EcHepDGBmNvZhRx8D1vMFLzMPgqAXqfIjpiIJuIe"
//                      clientKey:@"C0f7frNwhubdUjZplLyowAbEw4CUnmls6lubcs0M"];
        
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
    
    //set the clientuser propeorty to the client user object
    self.clientUser = self.chatroomObject[@"clientUser"];
    [self.clientUser fetchIfNeeded];
    
    //set public property to the clientUser object
    self.clientUser = self.chatroomObject[@"clientUser"];
    
    //get the first name of the client
    NSString *clientName = self.clientUser[@"firstName"];
    
    //set the title of the view to the client first name
    self.title = clientName;
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //sets the image size to half sreen...fits two per row
    CGSize width = CGSizeMake(self.view.bounds.size.width/2, self.view.bounds.size.width/2);
    
    return width;
    
}

-(void)goToChat{
    [self performSegueWithIdentifier:@"goToChat" sender:self];
}
- (PFQuery *)queryForCollection{
    NSLog(@"loading query");
    
    //set the clientuser propeorty to the client user object
    self.clientUser = self.chatroomObject[@"clientUser"];
    [self.clientUser fetchIfNeeded];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
//        if (self.objects.count == 0) {
//            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//        }
    
    //if the userObject is the same as our cuurent client...yayshark!
    [query whereKey:@"userObject" equalTo:self.clientUser];
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
    
    //time stamp label
    cell.mealTimeLabel.text = [self timestampFormatter:object.createdAt];
    cell.mealTimeLabel.adjustsFontSizeToFitWidth = YES;
    
    //hashtag label
    NSArray *hashtagArray = object[@"hashtagsArray"];
    NSLog(@"array is: %@", hashtagArray);
    
    if(hashtagArray.count > 0){
        cell.hashtagLabel.text = hashtagArray[0];
        cell.hashtagLabel.adjustsFontSizeToFitWidth = YES;

    }
    
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
    
    if ([segue.identifier isEqualToString:@"showImage"]) {
        imageDetailViewController *vc = segue.destinationViewController;
        vc.objectFromSegue = sender;
        vc.chatroomObject = self.chatroomObject;
    }else{
        MessagesViewController *vc = [segue destinationViewController];
        vc.youAreDietitian = true;
        vc.chatroomObjectFromList = self.chatroomObject;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NextPageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Add activity indicator to let the user know that more images are coming.
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell setBackgroundView:spinner];
    [spinner startAnimating];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If the scroll has reached the end of the screen.
    if (([scrollView contentSize].height - [scrollView contentOffset].y) < [self.view bounds].size.height)
    {
        // As long as there no other network request in place.
        if (![self isLoading])
        {
            // Trigger the load of the next page.
            [self loadNextPage];
        }
    }
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
