//
//  imageDetailViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "imageDetailViewController.h"

@interface imageDetailViewController ()

@end

@implementation imageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFFile *imageFile  = [self.objectFromSegue objectForKey:@"mealPhoto"];
    
    PFImageView *photo = [[PFImageView alloc] init];
    photo.file = imageFile;
    
    self.fullSizeImage.image = photo.image;
    
    
        //set description view
    self.descriptionTextView.text = self.objectFromSegue[@"description"];
    

    //set hash tag lable
    NSArray *hashtagArray = self.objectFromSegue[@"hashtagsArrays"];
    
    //set hashtoag array if its more than zero count
    if(hashtagArray.count > 0){
        NSLog(@"you are here");
        self.arrayLabel.text = hashtagArray[0];
    }
    self.timeLabel.text = [self timestampFormatter:self.objectFromSegue.createdAt];
    
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

@end
