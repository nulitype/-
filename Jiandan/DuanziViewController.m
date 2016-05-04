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
#import "MJRefresh.h"
#import "DuanziCell.h"
#import "NSString+Extension.h"



@interface DuanziViewController ()

@property (nonatomic, strong) NSMutableArray *duanziArray;
@property (nonatomic, strong) DuanziCell *prototypeCell;

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
    
    self.prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"DuanziCell"];
    
    //[self loadDuanzi];
    //[self getCurrentPage];
    
    [self setupRefresh];
}

- (void)setupRefresh {
        
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadDuanzi)];
    [self.tableView.mj_header beginRefreshing];
        
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDuanzi)];
    self.tableView.mj_footer.hidden = YES;
        
}


- (void)loadMoreDuanzi {
    
    _currentpage--;
    NSString *urlString = [NSString stringWithFormat:@"http://jandan.net/duan/page-%ld#comments",(long)_currentpage];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableArray *moreDuanzi = [self requestDuanziWithUrl:url];
    
    [self.duanziArray addObjectsFromArray:moreDuanzi];
    [self.tableView reloadData];
    [self.tableView.mj_footer endRefreshing];
    

}


- (void)loadDuanzi {
    
    [self.duanziArray removeAllObjects];
    [self getCurrentPage];
    
    NSString *urlString = @"http://jandan.net/duan";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableArray *duanziAr = [self requestDuanziWithUrl:url];
    [self.duanziArray addObjectsFromArray:duanziAr];
    
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    //[self.tableView reloadData];
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
    NSLog(@"%ld", (long)_currentpage);
    
    
}

#pragma mark - 请求方法

- (NSMutableArray *)requestDuanziWithUrl:(NSURL *)url {

    NSData *data = [NSData dataWithContentsOfURL:url];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:data];
    
    NSString *queryPath = @"//div[@class='text']/p";
    NSArray *DuanziNode = [parser searchWithXPathQuery:queryPath];
    
    if (DuanziNode.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请求失败" message:@"你不是被选中的蛋友" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

    
    NSMutableArray *temp = [NSMutableArray array];
    
    for (TFHppleElement *element in DuanziNode) {
        Duanzi *duanzi = [[Duanzi alloc] init];
        duanzi.text = element.content;
        NSLog(@"%@", element.content);
        [temp addObject:duanzi];
    }
    return temp;
}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = self.duanziArray.count == 0;
    return self.duanziArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"show %zd", indexPath.row);
    DuanziCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DuanziCell"];
//    if (!cell) {
//        cell = [[DuanziCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DuanziCell"];
//    }
    Duanzi *duanzi = self.duanziArray[indexPath.row];
    cell.label.text = duanzi.text;
    //cell.label.text = @"11111";
    [cell.label sizeToFit];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DuanziCell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DuanziCell"];
//    }
//    Duanzi *duanzi = self.duanziArray[indexPath.row];
//    
//    cell.textLabel.text = duanzi.text;
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    DuanziCell *cell = (DuanziCell *)self.prototypeCell;
//    Duanzi *duanzi = [self.duanziArray objectAtIndex:indexPath.row];
//    cell.label.text = duanzi.text;
//    CGSize s = [duanzi.text calculateSize:CGSizeMake(cell.label.frame.size.width, FLT_MAX) font:cell.label.font];
//    CGFloat defaultHeight = cell.contentView.frame.size.height;
//    CGFloat height = s.height > defaultHeight ? s.height : defaultHeight;
//    NSLog(@"h=%f", height);
//    return 1  + height;
    //return 88;
    NSLog(@"heightforrow %zd",indexPath.row);
    DuanziCell *cell = (DuanziCell *)self.prototypeCell;
    Duanzi *duanzi = [self.duanziArray objectAtIndex:indexPath.row];
    cell.label.text = duanzi.text;
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    NSLog(@"h=%f", size.height + 1);

    return 1  + size.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"estimate");
    return 88;
}

@end
