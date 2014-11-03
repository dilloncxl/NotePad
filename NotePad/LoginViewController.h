//
//  ViewController.h
//  NotePad
//
//  Created by chenxiaolong on 14-7-12.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;

-(IBAction)doLogin:(id)sender;

@end
