//
//  NoteInfoViewController.m
//  NotePad
//
//  Created by chenxiaolong on 14-8-25.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "NoteInfoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <Foundation/Foundation.h>
#import "NPInfo.h"


#define SERVER @"10.0.2.20"

@interface NoteInfoViewController ()

@end

@implementation NoteInfoViewController

@synthesize userName, noteInfo, ditNoteInfo, noteTitle, noteContent, noteId;

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
    
    // 编辑记事本，设置属性值
    if (self.noteInfo) {
        [self.noteTitle setText:[self.noteInfo valueForKeyPath:@"title"]];
        NSAttributedString *content = [NSKeyedUnarchiver unarchiveObjectWithData:[self.noteInfo valueForKeyPath:@"content"]];
        [self.noteContent setAttributedText:content];
        self.noteId = [self.noteInfo valueForKey:@"noteId"];
    } else {
        NSString *currentTime = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        self.noteId = [self md5:currentTime];
    }
    
    // 为图片绑定点击事件
    [self.photoPicker setUserInteractionEnabled:YES];
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPhoto:)];
    [self.photoPicker addGestureRecognizer:g];
    
    CALayer *contentLayer = [self.noteContent layer];
    contentLayer.borderColor = [[UIColor grayColor] CGColor];
    contentLayer.borderWidth = 0.5f;
    
    self.noteContent.delegate = self;
}

-(void)removePhoto:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"图片操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除图片" otherButtonTitles:nil, nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
    }
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

// 返回
-(IBAction)doBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 保存操作
-(IBAction)doSave:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // 创建时间
    NSDate *createTime = [NSDate date];
    
    NSData *content = [NSKeyedArchiver archivedDataWithRootObject:self.noteContent.attributedText];
    
    // 更新
    if (self.noteInfo) {
        [self.noteInfo setValue:self.noteTitle.text forKeyPath:@"title"];
        [self.noteInfo setValue:content forKeyPath:@"content"];
        [self.noteInfo setValue:createTime forKeyPath:@"createTime"];
        [self.noteInfo setValue:[self getDateIdentifier:createTime] forKeyPath:@"sectionIdentifier"];
        [self.noteInfo setValue:[self getYearAndWeeks] forKey:@"yearAndWeeks"];
        [self.noteInfo setValue:self.noteId forKey:@"noteId"];
    } else {
        // 新增
        NSManagedObjectContext *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"NP_INFO" inManagedObjectContext:context];
        
        [newNote setValue:self.noteTitle.text forKey:@"title"];
        [newNote setValue:content forKey:@"content"];
        [newNote setValue:self.userName forKey:@"userName"];
        [newNote setValue:createTime forKeyPath:@"createTime"];
        [newNote setValue:[self getDateIdentifier:createTime] forKeyPath:@"sectionIdentifier"];
        [newNote setValue:[self getYearAndWeeks] forKey:@"yearAndWeeks"];
        [newNote setValue:self.noteId forKey:@"noteId"];
    }
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        NSLog(@"无法保存！ %@   %@", error, [error localizedDescription]);
    } else {
        [self performSelectorInBackground:@selector(writeFile:) withObject:createTime];
//        [self writeFile:createTime];
        
        [self performSelectorInBackground:@selector(ftpUploadFile) withObject:nil];
//        [self ftpUploadFile];
        
//        [self performSelectorInBackground:@selector(ftpDownloadFile) withObject:nil];
//        [self ftpDownloadFile];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 本地记事本文件存储
- (void) writeFile:(NSDate *)createTime{
    // 获取document目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *uploadDir = [documentPath stringByAppendingPathComponent:[self.userName stringByAppendingPathComponent:@"upload"]];
    // 记事本文件名 /用户名/upload/*********@-@title@-@createTime.txt  @-@
    NSString *noteFile = [[[[[[[self.userName stringByAppendingPathComponent:@"upload"]
                           stringByAppendingPathComponent:self.noteId] stringByAppendingString:@"@-@"]
                          stringByAppendingString:self.noteTitle.text] stringByAppendingString:@"@-@"]
                          stringByAppendingString:[dateFormatter stringFromDate:createTime]]stringByAppendingString:@".txt"];
    // 创建一个用户记事本文本
    NSString *noteDirectory = [documentPath stringByAppendingPathComponent:noteFile];
    
    NSData *contentData = [NSKeyedArchiver archivedDataWithRootObject:self.noteContent.attributedText];
    // 记事本内容
    NSMutableDictionary *dicNote = [[NSMutableDictionary alloc] init];
    [dicNote setObject:self.noteTitle.text forKey:@"title"];
    [dicNote setObject:contentData forKey:@"content"];
    [dicNote setObject:self.userName forKey:@"userName"];
    [dicNote setObject:createTime forKey:@"createTime"];
    [dicNote setObject:[self getDateIdentifier:createTime] forKey:@"sectionIdentifier"];
    [dicNote setObject:[self getYearAndWeeks] forKey:@"yearAndWeeks"];
    [dicNote setObject:self.noteId forKey:@"noteId"];
    
    NSString *content = [NSString stringWithFormat:@"%@", dicNote];
    NSData *dataNote  = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *arrayFiles = [fileManager subpathsAtPath:uploadDir];
    for (NSString *fileName in arrayFiles) {
        if ([[fileName componentsSeparatedByString:@"@-@"][0] isEqualToString:self.noteId]) {
            [fileManager removeItemAtPath:[uploadDir stringByAppendingPathComponent:fileName] error:nil];
        }
    }
    
    
    // 本地存储记事本
    [fileManager createFileAtPath:noteDirectory contents:dataNote attributes:nil];
}

// 上传文件
- (void) ftpUploadFile {
    FTPManager *ftpManager = [[FTPManager alloc] init];
    
    FMServer *fmServer = [FMServer serverWithDestination:SERVER
                                                username:@"chenxiaolong"
                                                password:@"cxl"];
    
    NSArray *fileNameArray = [ftpManager contentsOfServer:fmServer];
    
    BOOL isExist = FALSE;
    // 用户文件夹是否存在
    for (NSDictionary *fileDic in fileNameArray) {
        if ([[fileDic valueForKey:@"kCFFTPResourceName"] isEqualToString:self.userName]) {
            isExist = TRUE;
            break;
        }
    }
    
    if (!isExist) {
        if ([ftpManager createNewFolder:self.userName atServer:fmServer]) {
            NSLog(@"ftp上创建用户目录");
            [ftpManager chmodFileNamed:self.userName to:777 atServer:fmServer];
        }
    }
    // ftp服务，链接至个人文件夹
    FMServer *fmFileServer = [FMServer serverWithDestination:[SERVER stringByAppendingPathComponent:self.userName]
                                                    username:@"chenxiaolong"
                                                    password:@"cxl"];
    
    // 删除同noteId文件
    NSArray *ftpFiles = [ftpManager contentsOfServer:fmFileServer];
    for (NSDictionary *dic in ftpFiles) {
        NSString *sourceName = [dic valueForKey:@"kCFFTPResourceName"];
        
        if ([[sourceName componentsSeparatedByString:@"@-@"][0] isEqualToString:self.noteId]) {
            [ftpManager deleteFileNamed:sourceName fromServer:fmFileServer];
        }
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *uploadDir = [documentPath stringByAppendingPathComponent:[self.userName stringByAppendingPathComponent:@"upload"]];
    
    NSArray *arrayFiles = [fileManager subpathsAtPath:uploadDir];
    
    for (NSString *fileItem in arrayFiles) {
        if (![[fileItem pathExtension] isEqualToString:@"txt"]) {
            continue;
        }
        
        NSString *uploadFile = [uploadDir stringByAppendingPathComponent:fileItem];
        NSURL *urlNote = [NSURL fileURLWithPath:uploadFile];
        
        // 将文件上传至ftp/用户名/下
        BOOL bFlag = [ftpManager uploadFile:urlNote toServer:fmFileServer];
        
        // 上传成功
        if (bFlag) {
            NSLog(@"成功上传文件:%@", fileItem);
            // 授权文件权限
            [ftpManager chmodFileNamed:fileItem to:777 atServer:fmFileServer];
            // 删除本地文件
            [fileManager removeItemAtURL:urlNote error:nil];
        }
    }
}

/*
 *  @brief MD5加密字符串
 */
-(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


// 获取年与星期标识  哪一年，第几周
-(NSNumber *) getYearAndWeeks {
    //  先定义一个遵循某个历法的日历对象
    NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //  通过已定义的日历对象，获取某个时间点的NSDateComponents表示，并设置需要表示哪些信息（NSYearCalendarUnit, NSMonthCalendarUnit, NSDayCalendarUnit等）
    NSDateComponents *dateComponents = [greCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSWeekOfMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekdayOrdinalCalendarUnit fromDate:[NSDate date]];
    
    NSInteger weeks = [dateComponents weekOfYear];
    NSInteger year = [dateComponents year];

    NSInteger yearAndWeeks = year * 100 + weeks;
    if ([dateComponents weekday] == 1) {
        yearAndWeeks = yearAndWeeks - 1;
    }
    
    return [NSNumber numberWithLong:yearAndWeeks];
}

// 获取时间标识  年月日
- (NSDate *) getDateIdentifier:(NSDate *)createTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *timeStamp = [dateFormatter stringFromDate:createTime];
    dateFormatter.dateFormat = @"yyyy-MM-dd  HH:mm:ss";
    NSDate *someDateInUTC = [dateFormatter dateFromString:[timeStamp stringByAppendingString:@" 00:00:00"]];
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateIdentifier = [someDateInUTC dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateIdentifier;
}

// 拍照后的回调函数
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    
    // 拍照获取图片
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else { // 从图库中获取图片
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.noteContent.attributedText];
        
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [self imageCompressForSize:image targetSize:CGSizeMake(100, 100)];
    
    NSAttributedString *attStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:attStringWithImage];

    self.noteContent.attributedText = attributedString;
        

    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 等比缩小图片
-(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

// 取消设置头像
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 头像点击事件
- (void) clickPhoto:(UITapGestureRecognizer *)recongnizer {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"记事本图像"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"拍照"
                                  otherButtonTitles:@"从图库中选择", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

// 头像设置源选择
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([actionSheet.title isEqualToString:@"记事本图像"]) {
        [self tackPic:buttonIndex];
    }
}

// 拍照
- (void)tackPic:(NSInteger) buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        // 判断照相机是否可用
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"设备中没有相机功能" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        } else {
            [self didPhotoPicker:UIImagePickerControllerSourceTypeCamera];
        }
    } else if (buttonIndex == 1) {
        [self didPhotoPicker:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 2) {
        NSLog(@"取消");
    }
}

// 获取图片
- (void)didPhotoPicker:(NSUInteger)sourceType {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType ;
    [self presentViewController:picker animated:YES completion:nil];
}

-(IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender {
    [noteTitle resignFirstResponder];
    [noteContent resignFirstResponder];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    CGRect rect = CGRectMake(20, 113, 280, 235);
    self.noteContent.frame = rect;
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    CGRect rect = CGRectMake(20, 113, 280, 435);
    self.noteContent.frame = rect;
    return YES;

}



@end

