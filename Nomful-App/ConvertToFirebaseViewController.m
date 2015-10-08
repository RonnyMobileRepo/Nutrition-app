//
//  ConvertToFirebaseViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 10/7/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "ConvertToFirebaseViewController.h"

@interface ConvertToFirebaseViewController (){
    //chatroom ID
    NSString *groupId;
}

@end

@implementation ConvertToFirebaseViewController

- (id)initWith:(NSString *)groupId_

{
    self = [super init];
    groupId = groupId_;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"group id is: %@", groupId);
    
    //build the ui
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.alpha = 0.8f;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable chatroom, NSError * _Nullable error) {
      
        //
        PFQuery *messagesQuery = [[PFQuery alloc] initWithClassName:@"Messages"];
        [messagesQuery whereKey:@"chatroom" equalTo:chatroom];
        //[messagesQuery orderByDescending:@"chatroom"];
        [messagesQuery orderByAscending:@"createdAt"];
        [messagesQuery includeKey:@"fromUser"];
        //[messagesQuery setSkip: 1000];
        messagesQuery.limit = 1000;
        
        [messagesQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            //objects is all messages sorted by chatroom first then ordered by time with most recent on top
            NSLog(@"We now have %lu messages", objects.count);
            
            NSArray *messagesArray = objects;
            int totalMessages = (int)[messagesArray count];
            
            PFObject *message = [[PFObject alloc] initWithClassName:@"Messages"];
            
            int i = 0;
            for (message in objects) {
                
                //get the sender user
                PFUser *fromUser = message[@"fromUser"];
                
                //build firebase object
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                
                item[@"userId"] = fromUser.objectId;
                item[@"name"] = fromUser[@"firstName"];
                item[@"date"] = [self Date2String:message.createdAt];
                item[@"status"] = @"Delivered";
                
                item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
                item[@"video_duration"] = item[@"audio_duration"] = @0;
                item[@"picture_width"] = item[@"picture_height"] = @0;
                
                item[@"text"] = message[@"content"];
                item[@"type"] = @"text";
                
                Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, groupId]];
                Firebase *reference = [firebase childByAutoId];
                item[@"messageId"] = reference.key;
                
                [reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
                 {
                     if (error != nil) NSLog(@"Outgoing sendMessage network error.");
                 }];
                
                i++;
                
                if (i == totalMessages) {
                    //we have reached the last message
                    [self dismissViewControllerAnimated:YES completion:^{
                        //save chatroom as converted
                        chatroom[@"upgradedToFirebase"] = @"Yes";
                        [chatroom saveEventually];
                        
                    }];
                }
            }
            
           
            
        }];
        
    }];
    
    
    
    
    
    
}

-(NSString*)Date2String:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
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
