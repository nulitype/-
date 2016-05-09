//
//  DuanziCell.m
//  Jiandan
//
//  Created by WongEric on 16/4/9.
//  Copyright © 2016年 WongEric. All rights reserved.
//

#import "DuanziCell.h"
#import "Duanzi.h"

@interface DuanziCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *celltextLabel;



@end

@implementation DuanziCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.celltextLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 10;
}

- (void)setDuanzi:(Duanzi *)duanzi {
    _duanzi = duanzi;
    
    self.nameLabel.text = duanzi.name;
    self.timeLabel.text = duanzi.time;
    self.celltextLabel.text = duanzi.text;
    
    [self layoutIfNeeded];
    
    duanzi.cellHeight = CGRectGetMaxY(self.celltextLabel.frame) + 10;
    
    
}

@end
