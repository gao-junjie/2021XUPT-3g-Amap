//
//  ViewController.h
//  GaodeMap
//
//  Created by mac on 2021/12/6.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "SearchViewController.h"

@interface ViewController : UIViewController <AMapLocationManagerDelegate, MAMapViewDelegate, AMapSearchDelegate>

//@property (strong, nonatomic) SearchViewController* searchViewController;
@property (strong, nonatomic) MAMapView* mapView;
@property (strong, nonatomic) UILabel* searchLabel;
@property (strong, nonatomic) AMapLocationManager* locationManager;
@property (strong, nonatomic) AMapSearchAPI* searchAPI;
@property (strong, nonatomic) AMapTip* tipTemp;
@property (strong, nonatomic) MAPointAnnotation *pointAnnotation;
@property (nonatomic, retain) NSArray *pathPolylines;
@property (nonatomic, assign) BOOL locatingWithReGeocode;


@end

