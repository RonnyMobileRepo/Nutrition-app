//
//  AppDelegate.m
//  Nomful-App
//
//  Created by Sean Crowe on 9/18/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Stripe/Stripe.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // ______________________________________________________________________________________________________________________________
    
    /*
    
    [Parse setApplicationId:PARSE_APP_ID_DEV
                  clientKey:PARSE_CLIENT_ID_DEV];
    [PFUser enableRevocableSessionInBackground];

    [Stripe setDefaultPublishableKey:STRIPE_TOKEN_DEV];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN_DEV];
    
     
    */
    
    //______________________________________________________________________________________________________________________________
    
    //LIVE
    
    ///*
     
    [Parse setApplicationId:PARSE_APP_ID
                  clientKey:PARSE_CLIENT_ID];
    [PFUser enableRevocableSessionInBackground];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [Stripe setDefaultPublishableKey:STRIPE_TOKEN];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    //*/
    
    //______________________________________________________________________________________________________________________________
    
    //BOTH
    
    [Fabric with:@[[Crashlytics class]]];
    [[ChimpKit sharedKit] setApiKey:MAILCHIMP_TOKEN];
    
    // Branch *branch = [Branch getInstance:@"144975538040099258"];
    
    // [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
    // params are the deep linked params associated with the link that the user clicked before showing up.
    // NSLog(@"deep link data: %@", [params description]);
    // }];
    
    
    //______________________________________________________________________________________________________________________________


   
    
    if([PFUser currentUser]){
        // We're logged in, we can register the user with Intercom
        PFUser *currentUser =  [PFUser currentUser];
        
        //Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:currentUser.objectId];
        
        //identifies user in mixpanel
        if(currentUser[@"firstName"]) [mixpanel.people set:@{@"$first_name": currentUser[@"firstName"]}];
        
        
    }else{
        //no user
        
    }

    
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    //global nav bar
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]]; //background of bar
    
    //style the page controller dots...
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

#pragma mark - Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    NSLog(@"You made it bro");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    
    //register for mixpanel push
    PFUser *currentUser = [PFUser currentUser];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:currentUser.objectId];
    [mixpanel.people addPushDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if( [[userInfo objectForKey:@"type"] isEqualToString:@"goal"]){
        //the notification was sent b/c a coach changed their client's goal
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woah look at you go!" message:@"Your coach changed your goal for the week :)" delegate:self cancelButtonTitle:@"Awesome!" otherButtonTitles: nil];
        [alert show];
        
        //send local notification so we can update the goal on user view
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateGoal" object:nil];
        
    }else if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"] ){
        //the notification was sent b/c a messages was sent
        
        if(![UIApplication sharedApplication].applicationState == UIApplicationStateActive){
            //when the app is NOT active then do normal push handling
            [PFPush handlePush:userInfo];
            //set local notification
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBarButtonBadge" object:nil];
            
        }else{
            //when the app IS active...we want sound and vibration and badge...but no alert view
            
            //vibrate
            //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            
            //sets the badge on the app icon on the phones home screen
            [application setApplicationIconBadgeNumber:1];
            
            //sends out a local notification...the logmeals view is listening for this and will update the bar button item
            //when the notificaiton is received
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBarButtonBadge" object:nil];
        }
        
        
    }else if ([[userInfo objectForKey:@"type"] isEqualToString:@"nom"]){
        
        //when the app is NOT active then do normal push handling
        [PFPush handlePush:userInfo];
        //set local notification
        
    }else{
        [PFPush handlePush:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"app did enter background");
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Session"];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"App did become active");
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    // start the timer for the event "App Close"
    [mixpanel timeEvent:@"Session"];
    

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.Nomful_App" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Nomful_App" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Nomful_App.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
