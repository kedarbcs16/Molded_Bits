//
//  ContentTableVIewControllerViewController.m
//  trialTableView
//
//  Created by ks.behara on 8/4/14.
//  Copyright (c) 2014 ks.behara. All rights reserved.
//

#import "ContentTableVIewControllerViewController.h"

@interface ContentTableVIewControllerViewController ()
{
    UIRefreshControl *refControl;
   
    NSMutableArray *tableInfoArray;
    NSMutableURLRequest *urlReq;
    NSURLConnection *urlConn;
    NSDictionary *receivedData;
}
@end

@implementation ContentTableVIewControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    refControl = [[UIRefreshControl alloc]init];
    self.navigationController.navigationBar.topItem.title = @"Table Feed";
    [_contentTableView addSubview:refControl];
    [refControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
   tableInfoArray = [[NSMutableArray alloc]init];
    [refControl beginRefreshing];
    urlReq = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/posts/stream/global"]  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:12.0];
    urlConn = [[NSURLConnection alloc]initWithRequest:urlReq delegate:self];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)refreshNotification:(NSNotification *)noti
{
    [refControl beginRefreshing];
    [self refresh];
}
-(void)refresh
{
  
    [NSURLConnection connectionWithRequest:urlReq delegate:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableInfoArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell = [_contentTableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell)
    {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
        [cell.cellDetailTextLabel  setNumberOfLines:0];
        [cell.cellDetailTextLabel setLineBreakMode:0];
    
        if (![[[tableInfoArray objectAtIndex:indexPath.row] valueForKey:@"avatar_image"]isEqualToString:@" "])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                cell.cellImageView.image = (UIImage *)[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[tableInfoArray objectAtIndex:indexPath.row] valueForKey:@"avatar_image"]]] ];
            });
            
        }
        
        cell.cellDetailTextLabel.text = [tableInfoArray[indexPath.row]valueForKey:@"text"];
        cell.cellTextLabel.text = [tableInfoArray[indexPath.row]valueForKey:@"username" ];
        
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [[tableInfoArray objectAtIndex:[indexPath row]] valueForKey:@"text"];
    
    CGSize constraint = CGSizeMake(320 - (1 * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:0];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    NSLog(@"height for row at index : %ld is %f",(long)indexPath.row,height + (1 * 2) + 10);
    
    
    
    return height + (1 * 2) + 12;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
  //  receivedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    @try {
        receivedData =  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
       
        if ([receivedData objectForKey:@"data"])
        {
            [self parseDataFromDict];
        }
       
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while parsing is : %@",[exception description]);
    }
    
    
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [refControl endRefreshing];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
-(void)parseDataFromDict
{
    
   NSArray*arr =  [receivedData objectForKey:@"data"];
    if (arr)
    {
       
        [tableInfoArray removeAllObjects];
        
    for (NSDictionary*dict in arr)
    {
        NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
        if ([dict objectForKey:@"user"])
        {
            if ([[dict objectForKey:@"user"] objectForKey:@"username"])
            {

                [mutDict setValue:[[dict objectForKey:@"user"] objectForKey:@"username"] forKey:@"username"];
            }
            else
            {
 
                [mutDict setValue:@" " forKey:@"username"];
            }
            
        
        if ([[dict objectForKey:@"user"]objectForKey:@"description"])
        {
            if ([[[dict objectForKey:@"user"]objectForKey:@"description"] objectForKey:@"text"])
            {
 
                [mutDict setValue:[[[dict objectForKey:@"user"]objectForKey:@"description"] objectForKey:@"text"]  forKey:@"text"];
            }
            else
            {
 
                [mutDict setValue:@" " forKey:@"text"];
            }
        }
         else
         {
 
             [mutDict setValue:@" " forKey:@"text"];
         }
            if ([[dict objectForKey:@"user"]objectForKey:@"avatar_image"])
            {
                if ([[[dict objectForKey:@"user"]objectForKey:@"avatar_image"]objectForKey:@"url"])
                {
                    [mutDict setValue:[[[dict objectForKey:@"user"]objectForKey:@"avatar_image"]objectForKey:@"url"]  forKey:@"avatar_image"];
                }
                else
                {
 
                    [mutDict setValue:@" " forKey:@"avatar_image"];
                }
            }
            else
            {
 
                [mutDict setValue:@" " forKey:@"avatar_image"];
            }
            
        }
        if ([dict objectForKey:@"created_at"])
        {
            [mutDict setValue:[dict objectForKey:@"created_at"] forKey:@"created_at"];
        }
        else
        {
            [mutDict setValue:@" " forKey:@"created_at"];
        }
        [tableInfoArray addObject:mutDict];
    }
     //tableInfoArray sort
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init ];
        [dateFormatter1 setDateFormat:@"yyyy-mm-ddTHH:mm a"];
        
        tableInfoArray = [NSMutableArray arrayWithArray:
                          [tableInfoArray sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *obj1, NSMutableDictionary *obj2)
                           {
                               NSDate *date1 = [dateFormatter1 dateFromString:[obj1 valueForKey:@"created_at"]];
                               NSDate *date2 = [dateFormatter1 dateFromString:[obj2 valueForKey:@"created_at"]];
                               return [date1 compare:date2];
                           }] ] ;
    [_contentTableView reloadData];
    [refControl endRefreshing];
}
}

@end
