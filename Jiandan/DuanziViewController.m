//
//  DuanziViewController.m
//  Jiandan
//
//  Created by WongEric on 16/4/9.
//  Copyright © 2016年 WongEric. All rights reserved.
//

#import "DuanziViewController.h"
#import "Duanzi.h"
#import "TFHpple.h"


@interface DuanziViewController ()

@property (nonatomic, strong) NSMutableArray *duanziArray;

@end

@implementation DuanziViewController {

    NSInteger _currentpage;
}

- (NSMutableArray *)duanziArray {
    if (!_duanziArray) {
        _duanziArray = [NSMutableArray array];
    }
    return _duanziArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDuanzi];
    [self getCurrentPage];
}



- (void)loadDuanzi {
    
    NSString *urlString = @"http://jandan.net/duan";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *DuanziData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *DuanziParser = [TFHpple hppleWithHTMLData:DuanziData];
    NSString *queryPath = @"//div[@class='text']/p";
    
    NSArray *DuanziNode = [DuanziParser searchWithXPathQuery:queryPath];
    for (TFHppleElement *element in DuanziNode) {
        Duanzi *duanzi = [[Duanzi alloc] init];
        duanzi.text = element.content;
        NSLog(@"%@", element.content);
        [self.duanziArray addObject:duanzi];
    }
}

- (void)getCurrentPage {
    
    NSString *urlString = @"http://jandan.net/duan";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *DuanziData = [NSData dataWithContentsOfURL:url];
    TFHpple *DuanziParser = [TFHpple hppleWithHTMLData:DuanziData];
    NSString *queryPath = @"//div[@class='comments']/div[@class='cp-pagenavi']/a";
    
    NSMutableArray *temp = [NSMutableArray array];
    NSArray *PageNode = [DuanziParser searchWithXPathQuery:queryPath];
    for (TFHppleElement *element in PageNode) {
        NSString *page = element.content;
        [temp addObject:page];
    }
    NSString *tempStr = [temp firstObject];
    _currentpage = [tempStr integerValue] + 1;
    NSLog(@"%d", _currentpage);
    
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.duanziArray.count;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.duanziArray.count;
//}



@end
