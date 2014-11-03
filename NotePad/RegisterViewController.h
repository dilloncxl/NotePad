//
//  RegisterViewController.h
//  NotePad
//
//  Created by chenxiaolong on 14-7-12.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UITextField *confirmPassword;

-(IBAction)doRegister:(id)sender;
-(IBAction)doBack:(id)sender;


@end
