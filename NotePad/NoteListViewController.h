//
//  NoteListViewController.h
//  NotePad
//
//  Created by chenxiaolong on 14-7-14.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property(strong, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, retain)NSString *userName;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(IBAction)doBack:(id)sender;

@end
