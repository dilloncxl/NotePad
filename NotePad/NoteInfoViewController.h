//
//  NoteInfoViewController.h
//  NotePad
//
//  Created by chenxiaolong on 14-8-25.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPManager.h"


@interface NoteInfoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>

@property(nonatomic, strong)NSString *userName;
//
//@property (strong, nonatomic) NSString *photoUrl;

@property (strong, nonatomic) NSString *noteId;

@property (strong) NSManagedObject *noteInfo;

@property (strong, nonatomic) NSDictionary *ditNoteInfo;

@property (assign, nonatomic) IBOutlet UITextField *noteTitle;

@property (assign, nonatomic) IBOutlet UITextView *noteContent;

@property (assign, nonatomic) IBOutlet UIButton *photoPicker;

-(IBAction)doBack:(id)sender;

-(IBAction)doSave:(id)sender;

-(IBAction)textFieldDoneEditing:(id)sender;

-(IBAction)backgroundTap:(id)sender;

@end
