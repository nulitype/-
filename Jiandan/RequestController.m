
//
//  RequestController.m
//  Jiandan
//
//  Created by WongEric on 5/8/16.
//  Copyright © 2016 WongEric. All rights reserved.
//

#import "RequestController.h"
#import "TFHpple.h"

@implementation RequestController

- (NSArray *)requestWithURL:(NSURL *)url searchPath:(NSString *)searchPath {
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    NSArray *node = [parser searchWithXPathQuery:searchPath];
    
    return node;
}

@end
