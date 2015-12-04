//
//  AppDelegate.h
//  Nomful-App
//
//  Created by Sean Crowe on 9/18/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSString *channelPartner;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

