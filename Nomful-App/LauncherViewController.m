//
//  LauncherViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "LauncherViewController.h"
#import <Parse/Parse.h>


@interface LauncherViewController ()

@end

@implementation LauncherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetchIfNeeded]; //**THIS MUST BE IN BACKGROUND OR IFNEEDED otherwise when no network on device, the app won't load. With ifneeded the app can load even in 100% loss network! woot woot toot toot!
    
    if(currentUser){
        NSLog(@"current user is: %@", currentUser);
        
        if([currentUser[@"role"] isEqualToString:@"RD"] ||[currentUser[@"role"] isEqualToString:@"PT"] ){
            //either an RD or a PT signed in
            [self performSegueWithIdentifier:@"launchToCoach" sender:self];
        }else{
            //you are a client
            
            //but are you anonymous?
            if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                //anonymous
                NSLog(@"user is anonymous");
                [self performSegueWithIdentifier:@"isNotLoggedInSegue" sender:self];

            } else {
                //good
                
                if(currentUser[@"planType"]){
                    NSLog(@"you made it here and plan type is: %@", currentUser[@"planType"]);
                    //we are here b/c there is a value for planType...the only way this can happen is if the user
                    //has activated a trial or paid for a membership
                    [self performSegueWithIdentifier:@"isLoggedInSegue" sender:self];
                    
                }else{
                    //they have no plan type...get them ousta here!
                    //[PFUser logOut];
                    
                    [self performSegueWithIdentifier:@"isNotLoggedInSegue" sender:self];

                    
                }

            }
            
        }
    }
    else{
        //you aren't even a human
        [self performSegueWithIdentifier:@"isNotLoggedInSegue" sender:self];
    }
}

@end
