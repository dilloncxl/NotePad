//
//  NoteListViewController.m
//  NotePad
//
//  Created by chenxiaolong on 14-7-14.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.

/*
 1、实现基本的记事本功能，包括登陆、列表展示和增删改功能；  ==
 2、列表需按时间分组，本周、本月、一个月之前；            =
 3、数据存储在sqlite数据库中；                        ==
 4、数据同步上传至FTP服务器取数据；                     ==
 5、支持文字、图片和语音笔记三种形式；                  =
 6、支持搜索功能；
 7、页面布局不做限制，但要求美观大方。
 */
//

#import "NoteListViewController.h"
#import "NoteTableViewCell.h"
#import "NoteInfoViewController.h"
#import "NPInfo.h"

@interface NoteListViewController ()

@property (strong) NSArray *searchResults;

@end

@implementation NoteListViewController

@synthesize userName, fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"异常错误：%@, %@", error, [error userInfo]);
        exit(-1);
    }
    
    self.searchResults = [self.fetchedResultsController fetchedObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)doBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 页面跳转前置操作
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NoteInfoViewController *infoViewController = (NoteInfoViewController *)segue.destinationViewController;
    infoViewController.userName = self.userName;
    if ([[segue identifier] isEqualToString:@"editNote"]) {
        if ([self.searchDisplayController isActive]) {
            infoViewController.noteInfo = [self.searchResults objectAtIndex:[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow].row];
        } else {
        infoViewController.noteInfo = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        }
    }
}


#pragma mark -
#pragma mark === UITableViewDataSource Delegate Methods ===
#pragma mark -

// 分组个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
}

// 各个分组下元素个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

// 分组的名称
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        //        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        NSString *rawDateStr = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
        NSDate *date = [formatter dateFromString:rawDateStr];
        
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *formattedDateStr = [formatter stringFromDate:date];
        
        return formattedDateStr;
    } else {
        return nil;
    }
}

// table节点
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndetifier = @"noteCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndetifier];
    }
    
    NPInfo *noteInfo = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        noteInfo = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        noteInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", noteInfo.title];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    // 时区为北京时间
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:noteInfo.createTime];
//    cell.noteCreateTime.text = [NSString stringWithFormat:@"%@", timeStamp];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", timeStamp];
    
//    
//    if (cell == nil) {
//        cell = [self.tableView dequeueReusableCellWithIdentifier:UITableViewCellStyleDefault];
//    }
    
//    NoteTableViewCell *cell = (NoteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIndetifier];
//    if (cell == nil) {
//        cell = [[NoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndetifier];
//    }
//    
//    NPInfo *noteInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    cell.noteTitle.text = [NSString stringWithFormat:@"%@", noteInfo.title];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//    // 时区为北京时间
//    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"ABC"];
//    [dateFormatter setTimeZone:gmt];
//    NSString *timeStamp = [dateFormatter stringFromDate:noteInfo.createTime];
//    cell.noteCreateTime.text = [NSString stringWithFormat:@"%@", timeStamp];
    
    return cell;
}

// table节点可编辑
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 编辑每个节点处理
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        
        if (![context save:&error]) {
            NSLog(@"无法删除！ %@, %@", error, [error localizedDescription]);
            return;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.tableView) {
        if (index > 0) {
            return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1];
        } else {
            self.tableView.contentOffset = CGPointZero;
            return NSNotFound;
        }
    } else {
        return 0;
    }
}

#pragma mark -
#pragma mark === Fetched Results Controller ===
#pragma mark ===          加载数据           ===
#pragma mark -

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NP_INFO"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // 过滤条件
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userName=%@", self.userName]];

    // 时间倒序加载
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [fetchRequest setFetchBatchSize:20];
    
    // 查询结果
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                          managedObjectContext:self.managedObjectContext
                                                                            sectionNameKeyPath:@"sectionIdentifier"
                                                                                     cacheName:nil];
    
    frc.delegate = self;
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"未知异常 %@, %@", error, [error userInfo]);
    }
    
    self.searchResults = [self.fetchedResultsController fetchedObjects];
    
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark - searchBar
#pragma mark -

// 搜索展现操作
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self searchForText:searchString
                  scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

// 查询方法
- (void)searchForText:(NSString *)searchText scope:(NSString *)scope {
//    if ([searchText isEqualToString:@""]) {
//        self.searchDisplayController.searchBar.transform = CGAffineTransformMakeTranslation(0, 0);
////        self.searchDisplayController.searchBar.frame = CGRectMake(0, 0, 320, 44);
//    } else {
//        self.searchDisplayController.searchBar.transform = CGAffineTransformMakeTranslation(0, -44);
//
////        self.searchDisplayController.searchBar.frame = CGRectMake(0, - 44, 320, 44);
//    }

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
    self.searchResults = [[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:resultPredicate];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"editNote" sender:self];
    }
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect statusBarFram = [[UIApplication sharedApplication] statusBarFrame];
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subView in self.view.subviews) {
//                subView.transform = CGAffineTransformMakeTranslation(0, statusBarFram.size.height);
//            }
//        }];
//    }
    self.navigationController.navigationBar.translucent = NO;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        CGRect statusBarFram = [[UIApplication sharedApplication] statusBarFrame];
//        [UIView animateWithDuration:0.25 animations:^{
//            for (UIView *subView in self.view.subviews) {
//                subView.transform = CGAffineTransformIdentity;
//            }
//        }];
//    }
    self.navigationController.navigationBar.translucent = NO;
}

@end
