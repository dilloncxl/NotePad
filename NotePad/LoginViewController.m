//
//  ViewController.m
//  NotePad
//
//  Created by chenxiaolong on 14-7-12.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "LoginViewController.h"
#import "NoteListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userName, password;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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


-(IBAction)doLogin:(id)sender {
    // 账号密码为空
    if ([self.userName.text isEqual:@""] ) {
        NSLog(@"用户名为空", nil);
//        [[[[iToast makeText:NSLocalizedString(@"    密码为空    ", @"")]
//           setGravity:iToastGravityTop offsetLeft:0 offsetTop:158] setDuration:iToastDurationShort] show];
        return;
    } else if ([self.password.text isEqual:@""]) {
        NSLog(@"密码为空", nil);
        return;
    }
    
    // 校验密码正确与否
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NP_USER" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"userName=%@ and password=%@", self.userName.text, self.password.text]];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
//        [self performSegueWithIdentifier:@"notePadTableList" sender:self];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
        [[NSUserDefaults standardUserDefaults] setObject:self.userName.text forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self presentViewController:controller animated:YES completion:^{}];
    } else {
        NSLog(@"用户名或密码错误！");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"notePadTableList"]) {
        NoteListViewController *listViewController = (NoteListViewController*) segue.destinationViewController;
        listViewController.userName = self.userName.text;
    }
}

-(IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

-(IBAction)backgoundTap:(id)sender {
    [userName resignFirstResponder];
    [password resignFirstResponder];
}

@end
