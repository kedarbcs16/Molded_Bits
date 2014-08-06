//
//  CustomTableViewCell.h
//  trialTableView
//
//  Created by ks.behara on 8/4/14.
//  Copyright (c) 2014 ks.behara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cellImageView;
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellDetailTextLabel;


@end
