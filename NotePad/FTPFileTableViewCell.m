//
//  FTPFileTableViewCell.m
//  NotePad
//
//  Created by chenxiaolong on 14-10-23.
//  Copyright (c) 2014年 chenxiaolong. All rights reserved.
//

#import "FTPFileTableViewCell.h"

@implementation FTPFileTableViewCell

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
