//
//  ViewController.m
//  TaobaoWebView
//
//  Created by 郑亚伟 on 2017/1/24.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ViewController.h"
#define ScrollDistance 80
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)UILabel *headLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    UILabel *hv = self.headLabel;
    // headLab
    [self.webView addSubview:hv];
    [self.headLabel bringSubviewToFront:self.view];
    [self.view addSubview:self.webView];
    
}

#pragma mark-tableView代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
#pragma mark-webView代理
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

#pragma mark-scrollView代理
//松手的时候执行的动画
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGFloat offsetY = scrollView.contentOffset.y;
    if ([scrollView isKindOfClass:[UITableView class]]) {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本身的高度
        CGFloat valueNum = self.tableView.contentSize.height -self.view.frame.size.height;
        if ((offsetY - valueNum) > ScrollDistance)
        {
            [self goToDetail]; // 进入图文详情的动画
        }
    }else{// webView页面上的滚动
        if(offsetY<0 && -offsetY > ScrollDistance)
        {
            [self backToFirstPage]; // 返回基本详情界面的动画
        }
    }
}


/**进入到webView*/
- (void)goToDetail{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20);
        _tableView.frame = CGRectMake(0, -self.tableView.bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.tableView.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

/**返回到tableView*/
-(void)backToFirstPage{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, [UIScreen mainScreen].bounds.size.width, self.tableView.bounds.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        UILabel *tabFootLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        tabFootLab.text = @"继续拖动，查看图文详情";
        tabFootLab.font =[UIFont systemFontOfSize:13];
        tabFootLab.textAlignment = NSTextAlignmentCenter;
        tabFootLab.backgroundColor = [UIColor orangeColor];
        _tableView.tableFooterView = tabFootLab;
    }
    return _tableView;
}
- (UIWebView *)webView{
    if (_webView == nil) {
        _webView = [[UIWebView alloc]initWithFrame:self.view.frame];
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        //注意webView的frame设置
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
        NSLog(@"加载webView");
        //监听webView.scrollView的contentOffset属性   主要是让tableView和webView在滚动过中形成连接
        [_webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return _webView;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
//        NSLog(@"----old:%@----new:%@",change[@"old"],change[@"new"]);
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}
// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    self.headLabel.alpha = -offsetY/60;
    self.headLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY> ScrollDistance){
//        self.headLabel.textColor = [UIColor redColor];
        self.headLabel.text = @"释放，返回详情";
    }else{
//        self.headLabel.textColor = [UIColor lightGrayColor];
        self.headLabel.text = @"下拉，返回详情";
    }
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

-(UILabel *)headLabel{
    if (_headLabel == nil) {
        _headLabel = [[UILabel alloc]init];
        _headLabel.text=@"headLabel";
        _headLabel.textColor = [UIColor whiteColor];
        _headLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40.f);
    }
    return _headLabel;
}



@end
