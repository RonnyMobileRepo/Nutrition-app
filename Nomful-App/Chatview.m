//
//  Chatview.m
//  Nomful-App
//
//  Created by Sean Crowe on 9/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "Chatview.h"
#import "Incoming.h"
#import "Outgoing.h"

@interface Chatview (){
    
    //chatroom ID
    NSString *groupId;
    
    //flags
    BOOL initialized;
    int typingCounter;
    
    //firebase objects
    Firebase *firebase1;
    Firebase *firebase2;
    
    //message arrays
    NSMutableArray *items;
    NSMutableArray *messages;
    
    //dictionaries
    NSMutableDictionary *started;
    NSMutableDictionary *avatars;
    
    //jsqmessages ui elements
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    JSQMessagesAvatarImage *avatarImageBlank;
    
}

@end

@implementation Chatview

- (id)initWith:(NSString *)groupId_

{
    self = [super init];
    groupId = groupId_;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"group id is: %@", groupId);
    
    //declare items for memory stuff i still don't get
    items = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    started = [[NSMutableDictionary alloc] init];
    avatars = [[NSMutableDictionary alloc] init];

    //set the jsqmessagesviewcontroller senderID variable to the object ID of the current user
    //same with the name
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"firstName"];
    
    //set bubble colors
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];

    //set the avatar image when chat is blank?
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profilePlaceholder.png"] diameter:30.0];

    //**havent used these before. Look into what they do
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionCopy:)];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionDelete:)];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionSave:)];
//
//    UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionCopy:)];
//    UIMenuItem *menuItemDelete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionDelete:)];
//    UIMenuItem *menuItemSave = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(actionSave:)];
//    [UIMenuController sharedMenuController].menuItems = @[menuItemCopy, menuItemDelete, menuItemSave];
    
    //lets go get the chatroom id and upon comletion, load firebase and messages
    //we should make this an initializtion thing like it was before
    
    //delcare two firebase objects
    firebase1 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, groupId]];
    firebase2 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Typing/%@", kFirechatNS, groupId]];

    [self loadMessages];
  
    
    //if there is a badge count...reset it to zero in the background
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    if([[PFUser currentUser][@"role"] isEqualToString:@"RD"]){
        UIBarButtonItem *rightPhone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"phone-barbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(callClient)];
        
        self.navigationItem.rightBarButtonItem = rightPhone;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController)
    {
        //**ClearRecentCounter(groupId);
        [firebase1 removeAllObservers];
        [firebase2 removeAllObservers];
    }
}


#pragma mark - Backend methods

- (void)loadMessages{
    NSLog(@"load messages for chatrom %@", groupId);
    initialized = NO;
    self.automaticallyScrollsToMostRecentMessage = NO;
    
    //add the observer for a child being added to the firebase stream...basically this ensures
    //that when a new message is put in stream...this method is called
    [firebase1 observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
     {
         NSLog(@"message: %@", snapshot.value);
         
         if (initialized)
         {
             //you get here when a user recieves a new message?
             BOOL incoming = [self addMessage:snapshot.value];
             if (incoming) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
             [self finishReceivingMessage];
             
             
         }else{
             [self addMessage:snapshot.value]; //** i added this so the messages load initially
         }
     }];

    [firebase1 observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         [self finishReceivingMessage];
         [self scrollToBottomAnimated:NO];
         self.automaticallyScrollsToMostRecentMessage = YES;
         self.showLoadEarlierMessagesHeader = YES;
         initialized	= YES;
     }];
}

- (BOOL)addMessage:(NSDictionary *)item
{
    //using the incoming class that we made.
    //I commented out all the other message types like video/audio and all that
    Incoming *incoming = [[Incoming alloc] initWith:self.senderId CollectionView:self.collectionView];
    JSQMessage *message = [incoming create:item];
    [items addObject:item];
    [messages addObject:message];
    return [self incoming:message];
}

- (void)loadAvatar:(NSString *)senderId
{
    if (started[senderId] == nil) started[senderId] = @YES; else return;

    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:senderId];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if ([objects count] != 0)
             {
                 PFUser *user = [objects firstObject];
                 PFFile *file = user[@"photo"];
                 [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
                  {
                      if (error == nil)
                      {
                          UIImage *image = [UIImage imageWithData:imageData];
                          avatars[senderId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
                          [self.collectionView reloadData];
                      }
                      else [started removeObjectForKey:senderId];
                  }];
             }
         }
         else if (error.code != 120) [started removeObjectForKey:senderId];
     }];
}

- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
{
    Outgoing *outgoing = [[Outgoing alloc] initWith:groupId View:self.navigationController.view];
    [outgoing send:text Video:video Picture:picture Audio:audio];

    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date

{
    [self messageSend:text Video:nil Picture:nil Audio:nil];
    [self sendPushNotifications];
}


- (void)didPressAccessoryButton:(UIButton *)sender

{
    [self actionAttach];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        return bubbleImageOutgoing;
    }
    else return bubbleImageIncoming;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = messages[indexPath.item];
    if (avatars[message.senderId] == nil)
    {
        [self loadAvatar:message.senderId];
        return avatarImageBlank;
    }
    else return avatars[message.senderId];
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return nil;
            }
        }
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        NSDictionary *item = items[indexPath.item];
        return [[NSAttributedString alloc] initWithString:item[@"status"]];
    }
    else return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    UIColor *color = [self outgoing:messages[indexPath.item]] ? [UIColor whiteColor] : [UIColor blackColor];
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = color;
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:color};
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender

{
    NSDictionary *item = items[indexPath.item];
    
    if (action == @selector(actionCopy:))
    {
        if ([item[@"type"] isEqualToString:@"text"]) return YES;
    }
    if (action == @selector(actionDelete:))
    {
        if ([self outgoing:messages[indexPath.item]]) return YES;
    }
    if (action == @selector(actionSave:))
    {
        if ([item[@"type"] isEqualToString:@"picture"]) return YES;
        if ([item[@"type"] isEqualToString:@"audio"]) return YES;
        if ([item[@"type"] isEqualToString:@"video"]) return YES;
    }
    return NO;
}


- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
    if (action == @selector(actionCopy:))		[self actionCopy:indexPath];
    if (action == @selector(actionDelete:))		[self actionDelete:indexPath];
    if (action == @selector(actionSave:))		[self actionSave:indexPath];
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return 0;
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

#pragma mark - Responding to collection view tap events


- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender

{
    //ActionPremium(self);
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath

{
    /*
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        ProfileView *profileView = [[ProfileView alloc] initWith:message.senderId User:nil];
        [self.navigationController pushViewController:profileView animated:YES];
    }
     */
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath

{
    /*
    JSQMessage *message = messages[indexPath.item];
    
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[PhotoMediaItem class]])
        {
            PhotoMediaItem *mediaItem = (PhotoMediaItem *)message.media;
            NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            [self presentViewController:browser animated:YES completion:nil];
        }
        if ([message.media isKindOfClass:[VideoMediaItem class]])
        {
            VideoMediaItem *mediaItem = (VideoMediaItem *)message.media;
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        }
    }
     */
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation

{
    
}

#pragma mark - User actions


- (void)actionAttach

{
//    [self.view endEditing:YES];
//    NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"Pictures"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
//    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
//    gridMenu.delegate = self;
//    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}


- (void)actionDelete:(NSIndexPath *)indexPath

{
    //ActionPremium(self);
}


- (void)actionCopy:(NSIndexPath *)indexPath

{
    NSDictionary *item = items[indexPath.item];
    [[UIPasteboard generalPasteboard] setString:item[@"text"]];
}


- (void)actionSave:(NSIndexPath *)indexPath

{
    //ActionPremium(self);
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    
    [self messageSend:nil Video:video Picture:picture Audio:nil];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods


- (BOOL)incoming:(JSQMessage *)message

{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}


- (BOOL)outgoing:(JSQMessage *)message

{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}

- (void)sendPushNotifications{
    
        PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
        [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {

            //we now have the chatroom object!
            //maybe later we do init with chatroomobject instead of object id
            PFQuery *pushQuery = [PFInstallation query];
            NSDictionary *data = [[NSDictionary alloc] init];
            NSString *name = [[NSString alloc] init];
            PFUser *sendPushToUser = [[PFUser alloc] init];
            
            //figure out who is sending tha push so we know who to send it  to.
            if ([[PFUser currentUser][@"role"] isEqualToString:@"Client"]){
                sendPushToUser = object[@"dietitianUser"];
             }else if ([[PFUser currentUser][@"role"] isEqualToString:@"RD"]){
                sendPushToUser = object[@"clientUser"];
            }//end if coach
            
            //set data and variables for push...send away!!
            [pushQuery whereKey:@"user" equalTo:sendPushToUser];
            name = [NSString stringWithFormat:@"You have a new messages from %@", [PFUser currentUser][@"firstName"]];
            
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"alert",
                    @1, @"badge",
                    @"default", @"sound",
                    @"message", @"type",
                    nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                //
                if(succeeded){
                    NSLog(@"push sent successfully!");
                }
            }];
            
        }];//end chatroom query
}


- (void)callClient{
    //only show if the user is an RD
    
    NSLog(@"You pressed the phone button! Woot woot!");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSString *phoneNumber = object[@"twilioNumber"];
        NSString *cleanedPhone = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        
        NSString *phoneNumbers = [@"tel://" stringByAppendingString:cleanedPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumbers]];
        
        //mixpanel tracking
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel timeEvent:@"Phone Call"];
    }];
    
    
}

@end
