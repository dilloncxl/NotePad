//
//  RegisterViewController.m
//  NotePad
//
//  Created by chenxiaolong on 14-7-12.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "RegisterViewController.h"
#import "NPUser.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

@synthesize userName, password, confirmPassword;

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
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

-(IBAction)doRegister:(id)sender {
    NSLog(@"doRegister", nil);
    
    if ([self.userName.text isEqualToString:@""]) {
        NSLog(@"用户名为空！");
        return;
    } else if ([self.password.text isEqualToString:@""]) {
        NSLog(@"密码为空！");
        return;
    } else if([self.confirmPassword.text isEqualToString:@""]) {
        NSLog(@"确认密码为空！");
        return;
    } else if (![self.password.text isEqualToString:@""] &&
        ![self.confirmPassword.text isEqualToString:@""] &&
        ![self.password.text isEqualToString:self.confirmPassword.text]) {
        NSLog(@"密码不一致！");
        return;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NP_USER" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userName=%@", self.userName.text]];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"校验用户名存在与否异常", nil);
        return;
    }
    
    if ([fetchedObjects count] > 0) {
        NSLog(@"用户名已经存在，请修改！", nil);
        return;
    }
    
    NSManagedObjectContext *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"NP_USER" inManagedObjectContext:context];
    
    [newUser setValue:self.userName.text forKey:@"userName"];
    [newUser setValue:self.password.text forKey:@"password"];
    
    if (![context save:&error]) {
        NSLog(@"不能保存：%@", [error localizedDescription]);
    } else {
        NSLog(@"%@", @"保存成功！");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // 创建一个用户记事本文件夹
        NSString *userDirectory = [documentPath stringByAppendingPathComponent:self.userName.text];
        [fileManager createDirectoryAtPath:userDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        // 创建一个上传文件夹
        NSString *upload = [userDirectory stringByAppendingPathComponent:@"upload"];
        // 创建一个下载文件夹
        NSString *download = [userDirectory stringByAppendingPathComponent:@"download"];

        [fileManager createDirectoryAtPath:upload withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:download withIntermediateDirectories:YES attributes:nil error:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)doBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

-(IBAction)backgroundTap:(id)sender {
    [userName resignFirstResponder];
    [password resignFirstResponder];
    [confirmPassword resignFirstResponder];
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

@end
