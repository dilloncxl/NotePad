//
//  FTPFileViewController.m
//  NotePad
//
//  Created by chenxiaolong on 14-10-23.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "FTPFileViewController.h"
#import "FTPManager.h"
#import "FTPFileTableViewCell.h"
#import "NPInfo.h"

#define SERVER @"10.0.2.20"

@interface FTPFileViewController ()

@property (nonatomic, retain) NSString *userName;

@property (nonatomic, strong) NSMutableArray *files;

@property (nonatomic, strong) NSMutableArray *downFileNames;

@end

@implementation FTPFileViewController

@synthesize userName, files, downFileNames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    files = [NSMutableArray arrayWithCapacity:1];
    downFileNames = [NSMutableArray arrayWithCapacity:1];
    

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    FTPManager *ftpManager = [[FTPManager alloc] init];
    // ftp服务，链接至个人文件夹   @ftpaddress/用户名
    FMServer *fmServer = [FMServer serverWithDestination:[SERVER stringByAppendingPathComponent:self.userName]
                                                username:@"chenxiaolong"
                                                password:@"cxl"];
    
    [self doSelectText:[ftpManager contentsOfServer:fmServer]];
}

- (NSManagedObjectContext *) managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

// 过滤出txt文件
- (void) doSelectText:(NSArray *) fileArrar {
    for (NSDictionary *dic in fileArrar) {
        NSString *fileName = [dic valueForKey:@"kCFFTPResourceName"];
        if ([[fileName pathExtension] isEqualToString:@"txt"]) {
            [files addObject:dic];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    files = [NSMutableArray arrayWithCapacity:1];
    downFileNames = [NSMutableArray arrayWithCapacity:1];

    FTPManager *ftpManager = [[FTPManager alloc] init];
    // ftp服务，链接至个人文件夹   @ftpaddress/用户名
    FMServer *fmServer = [FMServer serverWithDestination:[SERVER stringByAppendingPathComponent:self.userName]
                                                username:@"chenxiaolong"
                                                password:@"cxl"];
    
    [self doSelectText:[ftpManager contentsOfServer:fmServer]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [files count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     FTPFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCellIdentifier" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[FTPFileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fileCellIdentifier"];
    }
    
    NSDictionary *dic = [files objectAtIndex:indexPath.row];
    
    NSString *resourceName = [dic valueForKey:@"kCFFTPResourceName"];
    NSArray *fileName = [resourceName componentsSeparatedByString:@"@-@"];
    
    cell.title.text = fileName[1];
    cell.createTime.text = [fileName[2] stringByDeletingPathExtension];
    
    return cell;
}

// 选中行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [[files objectAtIndex:indexPath.row] valueForKey:@"kCFFTPResourceName"];
    
    [downFileNames addObject:fileName];
}

// 取消选中行
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = [[files objectAtIndex:indexPath.row] valueForKey:@"kCFFTPResourceName"];
    [downFileNames removeObject:fileName];
}

// 登出
- (IBAction)doLogout:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 同步
- (IBAction)doSync:(id)sender {
    if ([downFileNames count] == 0) {
        return;
    }
    
    FTPManager *ftpManager = [[FTPManager alloc] init];
    // ftp服务，链接至个人文件夹   @ftpaddress/用户名
    FMServer *fmServer = [FMServer serverWithDestination:[SERVER stringByAppendingPathComponent:self.userName]
                                                username:@"chenxiaolong"
                                                password:@"cxl"];


    // 获取document目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    // 下载的目录为 /document/用户名/download/
    NSString *downloadDir = [documentPath stringByAppendingPathComponent:[self.userName stringByAppendingPathComponent:@"download"]];
    NSURL *downloadUrl = [NSURL fileURLWithPath:downloadDir];
    
    for (NSString *item in downFileNames) {
        BOOL bFlag = [ftpManager downloadFile:item toDirectory:downloadUrl fromServer:fmServer];

        if (!bFlag) {
            continue;
        }
        
        [self doSyncDB:item downloadDir:downloadDir];
    }
}

- (void) doSyncDB:(NSString *)fileName downloadDir:(NSString *)downloadDir{
    NSString *noteId = [fileName componentsSeparatedByString:@"@-@"][0];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"NP_INFO" inManagedObjectContext:context]];
    
    NSLog(@"noteId: %@", noteId);
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"noteId=%@", noteId]];
    
    NSError *qError = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&qError];
    // 获取下载文件
    NSDictionary *noteDic = [NSDictionary dictionaryWithContentsOfFile:[downloadDir stringByAppendingPathComponent:fileName]];
    
    if (!noteDic) {
        NSLog(@"获取下载文件内容错误");
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +SSSS";
    NSDate *createTimeUTC = [dateFormatter dateFromString:[noteDic valueForKey:@"createTime"]];
    // 由于时区不同，设置时区GMT
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *createTime = [createTimeUTC dateByAddingTimeInterval:timeZoneSeconds];
    NSDate *sectionIdentifierUTC = [dateFormatter dateFromString:[noteDic valueForKey:@"sectionIdentifier"]];
    NSDate *sectionIdentifier = [sectionIdentifierUTC dateByAddingTimeInterval:timeZoneSeconds];
    NSString *strYearAndWeeks = [noteDic valueForKey:@"yearAndWeeks"];
    NSNumberFormatter *numberFormater = [[NSNumberFormatter alloc] init];
    NSNumber *yearAndWeeks = [numberFormater numberFromString:strYearAndWeeks];
    
    if (result.count > 0) {  // 更新
        NPInfo *entity = [result objectAtIndex:0];
        entity.title = [noteDic valueForKey:@"title"];
        entity.content = [noteDic valueForKey:@"content"];
        entity.createTime = createTime;
        entity.photoUrl = [noteDic valueForKey:@"photoUrl"];
        entity.sectionIdentifier =  sectionIdentifier;
        entity.yearAndWeeks = yearAndWeeks;
    } else { // 新增
        NSManagedObjectContext *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"NP_INFO" inManagedObjectContext:context];
        
        [newNote setValue:[noteDic valueForKey:@"title"] forKey:@"title"];
        [newNote setValue:[noteDic valueForKey:@"content"] forKey:@"content"];
        [newNote setValue:[noteDic valueForKey:@"photoUrl"]  forKey:@"photoUrl"];
        [newNote setValue:[noteDic valueForKey:@"userName"]  forKey:@"userName"];
        [newNote setValue:[noteDic valueForKey:@"noteId"] forKey:@"noteId"];
        [newNote setValue:createTime forKeyPath:@"createTime"];
        [newNote setValue:sectionIdentifier forKeyPath:@"sectionIdentifier"];
        [newNote setValue:yearAndWeeks forKey:@"yearAndWeeks"];
    }
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"无法保存！ %@   %@", error, [error localizedDescription]);
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[downloadDir stringByAppendingPathComponent:fileName] error:nil];
}



@end
