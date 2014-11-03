//
//  NoteTableViewCell.m
//  NotePad
//
//  Created by chenxiaolong on 14-8-24.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "NoteTableViewCell.h"

@implementation NoteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
