//
//  NomberrySignupViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 2/5/16.
//  Copyright © 2016 Nomful, inc. All rights reserved.
//

#import "NomberrySignupViewController.h"

@interface NomberrySignupViewController (){
    UITableView *nomberryTableView;
    NSMutableArray *messagesArray;
    int messageCount;
    
    
}

@end

@implementation NomberrySignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set count to 0
    messageCount = 0;
    
    
    messagesArray = [[NSMutableArray alloc] initWithObjects:@"", @"Hey there! I'm excited for you to start your nomful journey! Let me get some more information from you so I can find you the perfect coach!",nil];
    
    //////////////
    //TABLE VIEW//
    //////////////
    nomberryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    nomberryTableView.delegate = self;
    nomberryTableView.dataSource = self;
    nomberryTableView.backgroundColor = [UIColor clearColor];
    nomberryTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [nomberryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    nomberryTableView.rowHeight = UITableViewAutomaticDimension;
    nomberryTableView.estimatedRowHeight = 144.0;

    [self.view addSubview:nomberryTableView];
    

    [self autoLayoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)autoLayoutViews{
    
    NSDictionary *views = @{@"nomberryTable": nomberryTableView};
    
    /////////////
    //TABLEVIEW//
    /////////////
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[nomberryTable]-(0)-|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];

    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(35)-[nomberryTable(100)]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
}

#pragma mark - TableView Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return messagesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"NomberryCell";
    
    NomberryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[NomberryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    
    //Set Message Label
    cell.messageLabel.text = [messagesArray objectAtIndex:indexPath.row];
    
    //Show nomberry for only last message
    if (indexPath.row != messagesArray.count-1) {
        cell.nomberryImageView.image = nil;
    }
    

    return cell;
}


- (IBAction)nextButtonPressed:(id)sender {
    
    //increase to count of our messages. Started at 0
    messageCount++;
    
    NSLog (@"Message Count Just Increased To: %d", messageCount);
    
    switch (messageCount){
        case 1:{
            
            //DISPLAY MESSAGE//
            [messagesArray addObject:@"What is motivating you to join Nomful today?"];
            
            //ANIMATE RESPONSE VIEW//
            [UIView animateWithDuration:0.5
                             animations:^{_response1Container.alpha = 1;}];

            break;} //need brackets if block in switch
        case 2:{
            
            //DISPLAY MESSAGE//
            [messagesArray addObject:@"Great! What cuisines do you typically prefer? This helps me find you the right coach."];
            
            //ANIMATE RESPONSE VIEW//
            [UIView animateWithDuration:0.5
                             animations:^{_response1Container.alpha = 0;}];
            
            break;}
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        default:
            NSLog (@"Integer out of range");
            break;
    }
    
  
    //make sure the nomberry message shows up and scrolls!
    [nomberryTableView reloadData];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: messagesArray.count-1 inSection:0];
    [nomberryTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    
    
}


//did stop scrolling...reload data so nomberry shows up? idk maybe don't even allow scrolling
- (IBAction)backButtonPressed:(id)sender {
    
    //decrease message count
    messageCount--;
    
    //remove last message from array
    [messagesArray removeObjectAtIndex:messagesArray.count-1];
    
    NSLog (@"Message Count Just Decreased To: %d", messageCount);
    
    switch (messageCount){
        case 0:{
            
            //ANIMATE OUT RESPONSE 1//
            //ANIMATE IN RESPONSE 0//
            [UIView animateWithDuration:0.5
                             animations:^{_response1Container.alpha = 0;}];
            
            break;} //need brackets if block in switch
        case 1:{
            
            //ANIMATE OUT RESPONSE 2//
            //ANIMATE IN RESPONSE 1//
            [UIView animateWithDuration:0.5
                             animations:^{_response1Container.alpha = 1;}];
            
            break;}
        case 3:{
            //ANIMATE OUT RESPONSE 3//
            //ANIMATE IN RESPONSE 2//
        
            break;}
        case 4:{
            //ANIMATE OUT RESPONSE 4//
            //ANIMATE IN RESPONSE 3//
            break;}
        case 5:{
            //ANIMATE OUT RESPONSE 5//
            //ANIMATE IN RESPONSE 4//
            break;}
        default:
            NSLog (@"Integer out of range");
            break;
    }
    
`    //make sure the nomberry message shows up and scrolls!
    [nomberryTableView reloadData];
   
    


}
@end
