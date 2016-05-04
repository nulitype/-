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
#import "MeiziPages.h"
#import "MeiziUrl.h"
#import "MeiziCell.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "MJExtension.h"
#import "MJRefresh.h"

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
    
    
//    [self loadMeizi];
//    [self loadMore];
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
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableArray *addArray = [self requestPhotosWithUrl:url];
    
    [self.MeiziUrl addObjectsFromArray:addArray];
    [self.collectionView reloadData];
    
    [self.collectionView.mj_footer endRefreshing];
    
}

#pragma mark - CollectionView DataSource

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}

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
    
    NSLog(@"%ld",(long)_currentPage);
    
    NSURL *MeiziPhotosUrl = [NSURL URLWithString:@"http://jandan.net/ooxx"];
    NSMutableArray *MeiziUrlArray = [self requestPhotosWithUrl:MeiziPhotosUrl];
    
    [self.MeiziUrl addObjectsFromArray:MeiziUrlArray];
    
    [self.collectionView reloadData];
    
    [self.collectionView.mj_header endRefreshing];
}

#pragma mark - 请求方法

- (NSMutableArray *)requestPhotosWithUrl:(NSURL *)url {
    NSData *MeiziPhotosData = [NSData dataWithContentsOfURL:url];

    NSLog(@"data:---%@",MeiziPhotosData);
    TFHpple *MeiziParser = [TFHpple hppleWithHTMLData:MeiziPhotosData];
    
    NSString *MeiziUrlQuery = @"//div[@class='text']/p";
    NSArray *MeiziUrlNode = [MeiziParser searchWithXPathQuery:MeiziUrlQuery];
    NSLog(@"MeizuUrlNode------%@", MeiziUrlNode);
    if (MeiziUrlNode.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请求失败" message:@"你不是被选中的蛋友" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好吧" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }

    
    NSMutableArray *MeiziUrlArray = [NSMutableArray array];
    
    
    for (TFHppleElement *element in MeiziUrlNode) {
        
        for (TFHppleElement *child in element.children) {
            if ([child.tagName isEqualToString:@"a"]) {
                MeiziUrl *meiziUrl = [[MeiziUrl alloc] init];
                [MeiziUrlArray addObject:meiziUrl];
                //meiziUrl.MeiziLargeUrl = [child objectForKey:@"href"];
                meiziUrl.src = [child objectForKey:@"href"];
                //[URLArray addObject:LargeSizeUrl];
                NSLog(@"%@", meiziUrl.src);
            }
        }
    }
    return MeiziUrlArray;
}

- (void)getCurrentPage {
    
    NSURL *MeiziPhotosUrl = [NSURL URLWithString:@"http://jandan.net/ooxx"];
    NSData *MeiziPhotosData = [NSData dataWithContentsOfURL:MeiziPhotosUrl];
    
    
    TFHpple *MeiziParser = [TFHpple hppleWithHTMLData:MeiziPhotosData];
    
    NSString *currentPageQueryString = @"//div[@class='comments']/div[@class='cp-pagenavi']/a";
    NSArray *currentPageNode = [MeiziParser searchWithXPathQuery:currentPageQueryString];
    
    NSMutableArray *Pages = [NSMutableArray array];
    for (TFHppleElement *element in currentPageNode) {
        MeiziPages *MeiziPage = [[MeiziPages alloc] init];
        
        MeiziPage.page = [element.content integerValue];
        [Pages addObject:MeiziPage];
        
    }
    
    MeiziPages *page = [Pages firstObject];
    _currentPage = page.page;
    

}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *photoArray = [NSMutableArray array];
    for (MeiziUrl *meizi in self.MeiziUrl) {
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:meizi.src]];
        [photoArray addObject:photo];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photoArray];
    browser.alwaysShowControls = YES;
    [browser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:browser animated:YES];
    
}

@end
