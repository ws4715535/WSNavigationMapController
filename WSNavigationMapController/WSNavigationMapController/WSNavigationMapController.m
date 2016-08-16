//
//  WSNavigationMapController.m
//  WSNavigationMapController
//
//  Created by ws on 16/8/16.
//  Copyright © 2016年 ws. All rights reserved.
//

#import "WSNavigationMapController.h"

@interface WSNavigationMapController ()<CLLocationManagerDelegate, MKMapViewDelegate>


// mapView
@property (weak, nonatomic) MKMapView *m_mapView;
// location manager
@property (strong, nonatomic) CLLocationManager *m_locationManager;
// destination annotation
@property (weak, nonatomic) MKPointAnnotation *m_pontAnnotation;
// user location
@property (strong, nonatomic) CLLocation *m_location;
@end

@implementation WSNavigationMapController

static NSString *appName = @"appName";      // app的显示名字
static NSString *urlScheme = @"urlScheme";  // 用于导航地图到本app的跳转


- (void)viewDidLoad {
    [super viewDidLoad];
    // ***这里假设一对经纬坐标进行导航,实际场景经纬坐标应该作为参数传进来
    // "longitude": 34.159168,  latitude108.894027
    self.longitude = 108.894027;
    self.latitude = 34.159168;
    
    [self initMapView];
    [self initLocationManager];
    [self initNavigationItems];
    
   
}


- (void)initMapView {
    // init mapView
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.showsUserLocation = YES;   // show UserLocation Point in the map
    mapView.showsCompass = YES;        // show Compass in the map
    mapView.showsScale = YES;          // show scale rule in the map
    self.m_mapView = mapView;
    [self.view addSubview:mapView];
}

- (void)initLocationManager {
    // init location manager
    
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    manager.distanceFilter = kCLLocationAccuracyHundredMeters;
    [manager requestAlwaysAuthorization];
    [manager requestWhenInUseAuthorization];
    
    self.m_locationManager = manager;
    if ([CLLocationManager locationServicesEnabled]) {
        [manager startUpdatingLocation];
    } else {
        // 提示用户打开设置-> 定位服务
    }
    
    
}

- (void)initNavigationItems {
    // navigate action
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"导航" style:UIBarButtonItemStylePlain target:self action:@selector(navigate)];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // 进入地图的缩放比例
    double latDelta = 0.01;
    double longDelta = 0.01;
    self.m_location = locations.lastObject;
    
    
    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, longDelta);
    
    
    [self.m_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.latitude, self.longitude), span) animated:YES];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        CLPlacemark *mark = placemarks.lastObject;
        
        NSString *locality = mark.locality;
        NSString *subLocality = mark.subLocality;
        NSString *throughfare = mark.thoroughfare;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        annotation.coordinate = CLLocationCoordinate2DMake(self.latitude,self.longitude);
        annotation.title = [NSString stringWithFormat:@"%@%@", locality,subLocality];
        
        annotation.subtitle = [NSString stringWithFormat:@"%@", throughfare];
        
        [self.m_mapView addAnnotation:annotation];
        
        [self.m_mapView selectAnnotation:annotation animated:YES];
        
    }];
    
    [manager stopUpdatingLocation];
}


#pragma mark - navigateTheRoad
- (void)navigate {
    
    UIAlertController *naviRoad = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    CLLocation *golaLocation = [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
    
    UIAlertAction *appleMap = [UIAlertAction actionWithTitle:@"苹果自带地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:golaLocation.coordinate addressDictionary:nil]];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }];
    
    UIAlertAction *baiduMap = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",golaLocation.coordinate.latitude,golaLocation.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
        
    }];
    UIAlertAction *gaodeMap = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",appName,urlScheme,golaLocation.coordinate.latitude,golaLocation.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
    }];
    
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    
    // 判断手机是否有百度地图,如果有的话会显示在AlertSheet
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [naviRoad addAction:baiduMap];
    }
    // 判断手机是否有高德地图,如果有的话会显示在AlertSheet
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [naviRoad addAction:gaodeMap];
    }
    [naviRoad addAction:appleMap];
    [naviRoad addAction:cancle];
    [self presentViewController:naviRoad animated:YES completion:nil];
    
}



@end
