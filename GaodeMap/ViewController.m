//
//  ViewController.m
//  GaodeMap
//
//  Created by mac on 2021/12/6.
//

#import "ViewController.h"
#import "SearchViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi:)name:@"tongzhi" object:nil];
    _pathPolylines = [[NSArray alloc] init];
    _pointAnnotation = [[MAPointAnnotation alloc] init];
    
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    
    //加入搜索框
    _searchLabel = [[UILabel alloc] init];
    _searchLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.06, [UIScreen mainScreen].bounds.size.height * 0.04, [UIScreen mainScreen].bounds.size.width * 0.88, [UIScreen mainScreen].bounds.size.height * 0.06);
    _searchLabel.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
    _searchLabel.font = [UIFont systemFontOfSize:20];
    _searchLabel.layer.masksToBounds = YES;
    [_searchLabel.layer setCornerRadius:10];
    _searchLabel.textColor = [UIColor blackColor];
    _searchLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *searchLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchLabelTouchUpInside:)];
    [_searchLabel addGestureRecognizer:searchLabelTapGestureRecognizer];
    _searchLabel.text = @"请输入位置";
    [self.view addSubview:_searchLabel];
    
    //把地图添加至view
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.12, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.88)];
    _mapView.showsIndoorMap = YES;    //设置显示室内地图
    _mapView.zoomLevel = 18;    //设置缩放比例
    _mapView.zoomEnabled = YES;    //NO表示禁用缩放手势，YES表示开启
    _mapView.rotateEnabled = NO;    //NO表示禁用旋转手势，YES表示开启
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    //如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    [self initLocation];
}

- (void)searchLabelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    NSLog(@"被点击了");
    SearchViewController* _searchViewController = [[SearchViewController alloc] init];
    //_searchViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:_searchViewController animated:YES completion:nil];
}

//初始化定位
- (void)initLocation {
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 10;
    [self.locationManager setLocatingWithReGeocode:YES];
    [self.locationManager startUpdatingLocation];
}

//添加大头针
- (void)addAnnotation {
    _pointAnnotation.coordinate = _mapView.userLocation.coordinate;
    _pointAnnotation.coordinate = CLLocationCoordinate2DMake(_tipTemp.location.latitude, _tipTemp.location.longitude);
    _pointAnnotation.title = _tipTemp.name;
    _pointAnnotation.subtitle = _tipTemp.address;
    [_mapView addAnnotation:_pointAnnotation];
    [_mapView selectAnnotation:_pointAnnotation animated:YES];
}

//在回调函数中，获取定位坐标，进行业务处理。
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    NSLog(@"location:{纬度:%f; 经度:%f;}", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
}

- (void)tongzhi:(NSNotification *)text {
    _tipTemp = text.object[1];
    _searchLabel.text = _tipTemp.name;
    NSLog(@"－－－－－接收到通知------");
    [self addAnnotation];
    [self pathPlan];
}

//解析经纬度
- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string
                            coordinateCount:(NSUInteger *)coordinateCount
                                parseToken:(NSString *)token {
    if (string == nil) {
        return NULL;
    }
    if (token == nil) {
        token = @",";
    }
    NSString *str = @"";
    if (![token isEqualToString:@","]) {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    else {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL) {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:2 * i] doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    return coordinates;
}

//路线解析
- (NSArray *)polylinesForPath:(AMapPath *)path {
    if (path == nil || path.steps.count == 0) {
        return nil;
    }
    NSMutableArray *polylines = [NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline
                                                         coordinateCount:&count
                                                              parseToken:@";"];
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
        (void)((free(coordinates))), coordinates = NULL;
    }];
    return polylines;
}

//路径规划
- (void)pathPlan {
    AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
    /* 出发点. */
    navi.origin = [AMapGeoPoint locationWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
    /* 目的地. */
    navi.destination = [AMapGeoPoint locationWithLatitude:_tipTemp.location.latitude longitude:_tipTemp.location.longitude];
    //发起路线规划
    [_searchAPI AMapWalkingRouteSearch:navi];
}

//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    if (response.route == nil) {
        return;
    }
 
    //通过AMapNavigationSearchResponse对象处理搜索结果
    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
    NSLog(@"%@", route);
    AMapPath *path = response.route.paths[0]; //选择一条路径
    AMapStep *step = path.steps[0]; //这个路径上的导航路段数组
    NSLog(@"%@",step.polyline);   //此路段坐标点字符串
    NSLog(@"%@",response.route.paths[0]);
    
    if (response.count > 0) {
        //移除地图原本的遮盖
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines = nil;
 
        // 只显示第⼀条 规划的路径
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        NSLog(@"%@",response.route.paths[0]);
        //添加新的遮盖，然后会触发代理方法进行绘制
        [_mapView addOverlays:_pathPolylines];
    }
}

//绘制遮盖时执行的代理方法
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    /* 自定义定位精度对应的MACircleView. */
 
    //画路线
    if ([overlay isKindOfClass:[MAPolyline class]]) {
       //初始化一个路线类型的view
        MAPolylineRenderer *polygonView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        //设置线宽颜色等
        polygonView.lineWidth = 8.f;
        polygonView.strokeColor = [UIColor colorWithRed:0.015 green:0.658 blue:0.986 alpha:1.000];
        polygonView.fillColor = [UIColor colorWithRed:0.940 green:0.771 blue:0.143 alpha:0.800];
        polygonView.lineJoinType = kMALineJoinRound;//连接类型
        //返回view，就进行了添加
        return polygonView;
    }
    return nil;
}
@end
