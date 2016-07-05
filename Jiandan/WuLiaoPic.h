//
//  WuLiaoPic.h
//  Jiandan
//
//  Created by WongEric on 7/6/16.
//  Copyright © 2016 WongEric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WuLiaoPic : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, strong) NSMutableArray *photoUrls;
@property (nonatomic, copy) NSString *time;

@end
