//
//  SelectGoalsViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SelectGoalsViewController.h"
#import "MatchCoachViewController.h"

@interface SelectGoalsViewController ()

@end

@implementation SelectGoalsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _goalArray = [[NSMutableArray alloc] init];
    
    //clear nav bar woot woot
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MatchCoachViewController *vc = [segue destinationViewController];
    vc.coachUser = _coachUser;
}


- (IBAction)buttonSelected:(UIButton *)sender {
    
    NSLog(@"hastag selected");
    
    //get the button sender
    UIButton *selctedButton = sender;
    NSString *goalTitle = [selctedButton currentTitle];
    
    if(selctedButton.selected == YES){
        //the button is already selected
        //deselect it
        selctedButton.selected = NO;
        selctedButton.backgroundColor = [UIColor whiteColor];
        
        
    }else{
        //set it to the selected state..aka green
        selctedButton.selected = YES;
        [selctedButton setBackgroundColor:[UIColor greenColor]];
        
        //add the selected button title to array
        [_goalArray addObject:goalTitle];
        
        //we'll add the goals to parse
        [[PFUser currentUser] setObject:_goalArray forKey:@"goals"];
        [[PFUser currentUser] saveInBackground];
        
    }
        
    
}

- (IBAction)nextButtonPressed:(id)sender {
    
    [self findCoach];
}

- (PFUser *)findCoach{
    
    NSMutableArray *memberGoals = [[NSMutableArray alloc] init];
    memberGoals = [[PFUser currentUser] objectForKey:@"goals"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"goals" containedIn:memberGoals];
    [query whereKey:@"role" equalTo:@"RD"];
    NSArray *coaches = [query findObjects];
    
    _coachUser = coaches[0];
    
    NSLog(@"coach is: %@", _coachUser);
    
    
    return _coachUser;
}

@end
