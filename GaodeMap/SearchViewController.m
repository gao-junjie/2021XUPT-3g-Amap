//
//  SearchViewController.m
//  GaodeMap
//
//  Created by mac on 2021/12/6.
//

#import "SearchViewController.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _listArray = [[NSMutableArray alloc] init];
    _listNameArray = [[NSMutableArray alloc] init];
    
    _searchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _searchTableView.backgroundColor = [UIColor whiteColor];
    _searchTableView.bounces = NO;
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    [_searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"normal"];
    [self.view addSubview:_searchTableView];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchTableView.tableHeaderView = _searchController.searchBar;
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.placeholder = @"搜索";
    _searchController.searchBar.barTintColor = [UIColor colorWithWhite:0.93 alpha:1];
    
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearch");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearch");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"didDismissSearch");
}

//界面跳转的时候键盘就跳出来
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0];
}

- (void)showKeyboard {
    [self.searchController.searchBar becomeFirstResponder];
}
 
//视图消失回收键盘
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 回收键盘
    [self.searchController.searchBar resignFirstResponder];
}

//点击取消时的响应
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchController.searchBar resignFirstResponder];
}

//时刻更改搜索的string
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _searchString = searchText;
}

//保存更改的string
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _searchController.searchBar.text = _searchString;
}

//设置搜索后的listArray视图
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT * 0.08;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* normalCell = [_searchTableView dequeueReusableCellWithIdentifier:@"normal" forIndexPath:indexPath];
    normalCell.textLabel.text = _listNameArray[indexPath.row];
    normalCell.textLabel.textColor = [UIColor colorWithRed:0 green:0.4 blue:0.8 alpha:1];
    normalCell.textLabel.font = [UIFont systemFontOfSize:21];
    return normalCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *searchArray = [[NSArray alloc] init];
    searchArray = [NSArray arrayWithObjects:_searchAPI, _listArray[indexPath.row], nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"tongzhi" object:searchArray userInfo:nil];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//搜索框激活时，使用提示搜索
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    //发起输入提示搜索
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    //关键字
    tipsRequest.keywords = _searchController.searchBar.text;
    //城市
    tipsRequest.city = @"西安";
    //执行搜索
    [_searchAPI AMapInputTipsSearch: tipsRequest];
}

//实现输入提示的回调函数
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response {
    if(response.tips.count == 0) {
        return;
    }
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    //先清空数组
    [_listArray removeAllObjects];
    [_listNameArray removeAllObjects];
    for (AMapTip *obj in response.tips) {
        //把搜索结果存在数组
        [_listArray addObject:obj];
        [_listNameArray addObject:obj.name];
    }
    //_isSelected = NO;
    //刷新表视图
    [_searchTableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tongzhi" object:self];
}

@end
