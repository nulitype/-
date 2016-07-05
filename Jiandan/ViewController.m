//
//  ViewController.m
//  Jiandan
//
//  Created by WongEric on 16/4/6.
//  Copyright © 2016年 WongEric. All rights reserved.
//


#define kScreenWidth    CGRectGetWidth([UIApplication   sharedApplication].keyWindow.bounds)
#define kScreenHeight    CGRectGetHeight([UIApplication sharedApplication].keyWindow.bounds)

#import "ViewController.h"
#import "TFHpple.h"
#import "MeiziUrl.h"
#import "MeiziCell.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "RequestController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *MeiziUrl;

@end

@implementation ViewController {
    NSInteger _currentPage;
}

- (NSMutableArray *)MeiziUrl {
    if (!_MeiziUrl) {
        _MeiziUrl = [NSMutableArray array];
    }
    return _MeiziUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    [self setupRefresh];
}

- (void)setupRefresh {

    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMeizi)];
    [self.collectionView.mj_header beginRefreshing];
    
    self.collectionView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    self.collectionView.mj_footer.hidden = YES;

}

#pragma mark - Refresh Methods


- (void)loadMore {
    _currentPage--;
    NSString *urlString = [NSString stringWithFormat:@"http://jandan.net/ooxx/page-%ld#comments",(long)_currentPage];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableArray *addArray = [self requestPhotosWithUrl:url];
    
    [self.MeiziUrl addObjectsFromArray:addArray];
    [self.collectionView reloadData];
    
    [self.collectionView.mj_footer endRefreshing];
    
}

#pragma mark - CollectionView DataSource


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.collectionView.mj_footer.hidden = self.MeiziUrl.count == 0;
    return self.MeiziUrl.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSInteger perLine = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? 3 : 5;
    return CGSizeMake(kScreenWidth / perLine - 1, kScreenWidth/perLine - 1);
    //return CGSizeMake(100, 100+arc4random() %140);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MeiziCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MeiziCell" forIndexPath:indexPath];
    [cell setMeizi:self.MeiziUrl[indexPath.row]];
    return cell;
}


#pragma mark - 请求

- (void)loadMeizi {
    
    [self.MeiziUrl removeAllObjects];
    
    [self getCurrentPage];
    
    NSLog(@"current page------%ld",(long)_currentPage);
    
    NSURL *MeiziPhotosUrl = [NSURL URLWithString:@"http://jandan.net/ooxx"];
    NSMutableArray *MeiziUrlArray = [self requestPhotosWithUrl:MeiziPhotosUrl];
    
    [self.MeiziUrl addObjectsFromArray:MeiziUrlArray];
    
    [self.collectionView reloadData];
    
    [self.collectionView.mj_header endRefreshing];
}

#pragma mark - 请求方法

- (NSMutableArray *)requestPhotosWithUrl:(NSURL *)url {
    
    NSString *MeiziUrlQuery = @"//div[@class='text']/p";

    NSArray *node = [[RequestController alloc] requestWithURL:url searchPath:MeiziUrlQuery];
    if (node.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请求失败" message:@"你不是被选中的蛋友" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

    
    NSMutableArray *MeiziUrlArray = [NSMutableArray array];
    
    
    for (TFHppleElement *element in node) {
        
        for (TFHppleElement *child in element.children) {
            if ([child.tagName isEqualToString:@"a"]) {
                MeiziUrl *meiziUrl = [[MeiziUrl alloc] init];
                [MeiziUrlArray addObject:meiziUrl];
                meiziUrl.src = [child objectForKey:@"href"];
                //NSLog(@"%@", meiziUrl.src);
            }
        }
    }
    return MeiziUrlArray;
}

- (void)getCurrentPage {
    
    NSURL *MeiziPhotosUrl = [NSURL URLWithString:@"http://jandan.net/ooxx"];
    
    NSString *currentPageQueryString = @"//div[@class='comments']/div[@class='cp-pagenavi']/span";
    NSArray *node = [[RequestController alloc] requestWithURL:MeiziPhotosUrl searchPath:currentPageQueryString];
    
    NSMutableArray *Pages = [NSMutableArray array];
    for (TFHppleElement *element in node) {
        NSString *page = element.content;
        page = [page substringFromIndex:1];
        page = [page substringToIndex:page.length - 1];
        [Pages addObject:page];
        NSLog(@"get page == %@", page);
    }
    
    _currentPage = [[Pages firstObject] integerValue];
    

}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoArray = [NSMutableArray array];
    for (MeiziUrl *meizi in self.MeiziUrl) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:meizi.src]];
        [photoArray addObject:photo];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photoArray];
    browser.alwaysShowControls = NO;
    browser.enableGrid = NO;
    
    
    [browser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:browser animated:YES];
    
}

@end
