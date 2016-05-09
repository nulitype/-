//
//  RequestController.h
//  Jiandan
//
//  Created by WongEric on 5/8/16.
//  Copyright © 2016 WongEric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestController : NSObject

- (NSMutableArray *)requestWithURL:(NSURL *)url searchPath:(NSString *)searchPath;

@end
