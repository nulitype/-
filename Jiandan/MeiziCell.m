//
//  MeiziCell.m
//  Jiandan
//
//  Created by WongEric on 16/4/6.
//  Copyright © 2016年 WongEric. All rights reserved.
//

#import "MeiziCell.h"
#import "MeiziUrl.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
@interface MeiziCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation MeiziCell

- (void)setMeizi:(MeiziUrl *)meiziUrl {
    NSURL *imageURL = [NSURL URLWithString:meiziUrl.src];
    //NSLog(@"%@",imageURL);
    [self.imageView setImageWithURL:imageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

@end
