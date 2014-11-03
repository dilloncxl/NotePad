//
//  NoteTableViewCell.h
//  NotePad
//
//  Created by chenxiaolong on 14-8-24.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *noteTitle;

@property (nonatomic, weak) IBOutlet UILabel *noteCreateTime;

@end
