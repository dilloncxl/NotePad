//
//  FTPFileViewController.h
//  NotePad
//
//  Created by chenxiaolong on 14-10-23.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTPFileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)doLogout:(id)sender;

- (IBAction)doSync:(id)sender;

@end
