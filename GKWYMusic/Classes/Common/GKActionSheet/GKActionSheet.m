//
//  GKActionSheet.m
//  GKAudioPlayerDemo
//
//  Created by gaokun on 2018/4/13.
//  Copyright © 2018年 高坤. All rights reserved.
//

#import "GKActionSheet.h"
#import "GKActionSheetViewCell.h"

#define kMaxH  840.0f / 750.0f * KScreenW

#define kItemH 100.0f / 750.0f * KScreenW

#define kTopH  90.0f / 750.0f * kScreenW

static GKActionSheet *currentActionSheet;

@implementation GKActionSheetItem

@end

@interface GKActionSheet()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSArray<GKActionSheetItem *> *itemInfos;

@property (nonatomic, copy) void(^selectedBlock)(NSInteger index);

@end

@implementation GKActionSheet

+ (void)showActionSheetWithTitle:(NSString *)title itemInfos:(NSArray<GKActionSheetItem *> *)itemInfos selectedBlock:(void (^)(NSInteger))selectedIndexBlock {
    GKActionSheet *actionSheet = [[GKActionSheet alloc] initWithTitle:title itemInfos:itemInfos selectedBlock:selectedIndexBlock];
    currentActionSheet = actionSheet;
    [actionSheet show];
}

+ (void)updateActionSheetItemWithIndex:(NSInteger)index item:(GKActionSheetItem *)item {
    [currentActionSheet updateItemWithIndex:index item:item];
}

+ (BOOL)hasShow {
    return [GKCover hasCover];
}

- (instancetype)initWithTitle:(NSString *)title itemInfos:(NSArray<GKActionSheetItem *> *)itemInfos selectedBlock:(void (^)(NSInteger))selectedIndexBlcok {
    if (self = [super init]) {
        [self addSubview:self.topView];
        [self.topView addSubview:self.titleLabel];
        [self addSubview:self.tableView];
        
        self.titleLabel.text    = title;
        self.itemInfos          = itemInfos;
        self.selectedBlock      = selectedIndexBlcok;
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(kTopH);
        }];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = GKColorRGB(191, 187, 185);
        [self.topView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.topView);
            make.height.mas_equalTo(0.5f);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.left.equalTo(self.topView).offset(10);
            make.right.equalTo(self.topView).offset(-10);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
        }];
        
        [self.tableView reloadData];
    }
    return self;
}

- (void)show {
    UIView *bgView = [UIView new];
    bgView.frame = CGRectMake(0, 0, KScreenW, KScreenH);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.5f;
    
    [bgView addSubview:self];
    
    CGFloat relaityH = self.itemInfos.count * kItemH + kTopH;
    
    CGFloat height = relaityH > kMaxH ? kMaxH : relaityH;
    
    self.frame = CGRectMake(0, KScreenH, KScreenW, height);
    
    [GKCover coverFrom:[UIApplication sharedApplication].keyWindow
           contentView:self
                 style:GKCoverStyleTranslucent
             showStyle:GKCoverShowStyleBottom
         showAnimStyle:GKCoverShowAnimStyleBottom
         hideAnimStyle:GKCoverHideAnimStyleBottom
              notClick:NO
             showBlock:nil
             hideBlock:^{
                 currentActionSheet = nil;
              }];
}

- (void)updateItemWithIndex:(NSInteger)index item:(GKActionSheetItem *)item {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.itemInfos];
    
    [items replaceObjectAtIndex:index withObject:item];
    
    self.itemInfos = items;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKActionSheetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKActionSheetViewCellID" forIndexPath:indexPath];
    cell.item = self.itemInfos[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [GKCover hideCover];
    
    !self.selectedBlock ? : self.selectedBlock(indexPath.row);
}

#pragma mark - 懒加载
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _titleLabel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GKActionSheetViewCell class] forCellReuseIdentifier:@"GKActionSheetViewCellID"];
        _tableView.rowHeight = kItemH;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

@end
