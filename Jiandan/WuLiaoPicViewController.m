//
//  WuLiaoPicViewController.m
//  Jiandan
//
//  Created by WongEric on 7/6/16.
//  Copyright © 2016 WongEric. All rights reserved.
//

#import "WuLiaoPicViewController.h"
#import "TFHpple.h"
#import "WuLiaoPic.h"

@interface WuLiaoPicViewController ()

@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation WuLiaoPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getCurrentPage];
    
    [self requestWuLiaoPicWithURL:[NSURL URLWithString:@"http://jandan.net/pic"]];
}

- (void)getCurrentPage {
    NSURL *pageUrl = [NSURL URLWithString:@"http://jandan.net/pic"];
    
    NSData *WuLiaoPicData = [NSData dataWithContentsOfURL:pageUrl];
    TFHpple *WLpicParser = [TFHpple hppleWithHTMLData:WuLiaoPicData];
    NSString *currentPageQueryString = @"//div[@class='comments']/div[@class='cp-pagenavi']/span";
    
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *PageNode = [WLpicParser searchWithXPathQuery:currentPageQueryString];
    for (TFHppleElement *element in PageNode) {
        NSString *page = element.content;
        
        page = [page substringFromIndex:1];
        page = [page substringToIndex:page.length - 1];
        //NSLog(@"d---page %@", page);
        [temp addObject:page];
    }
    NSString *tempStr = [temp firstObject];
    _currentPage = [tempStr integerValue];
    //NSLog(@"%ld", (long)_currentPage);
    
}

- (void)requestWuLiaoPicWithURL:(NSURL *)url {
    NSData *WuLiaoPicData = [NSData dataWithContentsOfURL:url];
    TFHpple *WLpicParser = [TFHpple hppleWithHTMLData:WuLiaoPicData];
    
    NSString *queryPath = @"//div[@class='row']";
    NSArray *WuLiaoNode = [WLpicParser searchWithXPathQuery:queryPath];
    
    for (TFHppleElement *element in WuLiaoNode) {
        WuLiaoPic *WLpic = [[WuLiaoPic alloc] init];
        
        for (TFHppleElement *child in element.children) {
            if ([child.attributes[@"class"] isEqualToString:@"author"]) {
                for (TFHppleElement *ch in child.children) {
                    if ([ch.tagName isEqualToString:@"strong"]) {
                        WLpic.author = ch.content;
                        //NSLog(@"%@", WLpic.author);
                    }
                    if ([ch.tagName isEqualToString:@"small"]) {
                        WLpic.time = ch.firstChild.content;
                        //NSLog(@"%@", WLpic.time);
                    }
                }
            }
            if ([child.attributes[@"class"] isEqualToString:@"text"]) {
                for (TFHppleElement *ch in child.children) {
                    if ([ch.tagName isEqualToString:@"p"]) {
                        WLpic.text = ch.content;
                        NSLog(@"text:----%@",WLpic.text);
                        for (TFHppleElement *insideChild in ch.children) {
                            if ([insideChild.tagName isEqualToString:@"a"]) {
                                //NSLog(@"urls---%@", [insideChild objectForKey:@"href"]);
                                [WLpic.photoUrls addObject:[insideChild objectForKey:@"href"]];
                            }
                        }
                    }
                }
            }
            
        }
        
    }
}





@end
