//
//  ViewController.m
//  ARSample
//
//  Created by hirauchi.shinichi on 2016/07/29.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import "ViewController.h"
#import "ARView.h"
#import <CoreMotion/CoreMotion.h>
#import "CoreLocation/CoreLocation.h"

@interface ViewController ()<CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) ARView *arView;
@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CLLocationCoordinate2D sapporoStation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sapporoStation = CLLocationCoordinate2DMake(43.068514, 141.350937); // 札幌駅
}

- (void)viewDidLayoutSubviews
{
    // デバイスの回転の検出
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(didChangedOrientation:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];

    // ARビュー作成
    self.arView = [[ARView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    sleep(2.0); // ARビュの生成に時間がかかるようで、すぐにカメラのビューに載せると認識されない

    // カメラ
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.sourceType = sourceType;
        //cameraPicker.delegate = self;
        cameraPicker.showsCameraControls = NO;

        // スクリーンサイズに調整
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        float heightRatio = 4.0f / 3.0f;
        float cameraHeight = screenSize.width * heightRatio;
        float scale = screenSize.height / cameraHeight;
        cameraPicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenSize.height - cameraHeight) / 2.0);
        cameraPicker.cameraViewTransform = CGAffineTransformScale(cameraPicker.cameraViewTransform, scale, scale);
        cameraPicker.cameraOverlayView = self.arView;

        [self presentViewController:cameraPicker animated:NO completion:nil];
        [_arView startAnimation];
    }

    // コンパスが使用可能かどうかチェックする
    if ([CLLocationManager headingAvailable]) {
        // CLLocationManagerを作る
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;

        // コンパスの使用を開始する
        [_locationManager startUpdatingHeading];
    }

    // 位置情報取得の許可
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // アプリ起動時のみの位置情報を取得の許可を得る
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];

    // ジャイロ情報
    _motionManager = [[CMMotionManager alloc] init];
    if (_motionManager.deviceMotionAvailable) {
        // 更新の間隔を設定する
        _motionManager.deviceMotionUpdateInterval = 0.1f;
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^ (CMDeviceMotion* motion, NSError* error) {
                                                // ARのビューにジャイロ情報を送る
                                                self.arView.gravity = motion.gravity;
                                            }
         ];
    }
}

#pragma mark - Notification

- (void)didChangedOrientation:(NSNotification *)notification
{
    self.arView.orientation = [[notification object] orientation];
}

#pragma mark - LocationManager Delegate

// 方向の取得
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // ARのビューに現在の方向を送る
    self.arView.heading = newHeading.trueHeading;
}

// 位置の取得
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 位置情報を取り出す
    CLLocation *newLocation = [locations lastObject];
    self.location = newLocation.coordinate;
    NSLog(@"緯度：%.6f 軽度：%.6f 標高：%.0f",self.location.latitude,self.location.longitude,newLocation.altitude);
    float azimuth = [self angle:self.location :self.sapporoStation];
    NSLog(@"azimuth：%.2f ",azimuth);
    self.arView.azimuth = azimuth;
}

#pragma mark - Private Method

// 方位角
- (float) angle :(CLLocationCoordinate2D) coordinate: (CLLocationCoordinate2D) coordinate2
{
    float longitudinalDiff = coordinate2.longitude - coordinate.longitude;
    float latitudinalDiff  = coordinate2.latitude - coordinate.latitude;
    float azimuth = (M_PI * .5f) - atan(latitudinalDiff / longitudinalDiff);
    azimuth *= 360 / (M_PI*2);
    if (longitudinalDiff > 0) {
        return( azimuth );
    }
    else if (longitudinalDiff < 0) {
        return azimuth + 180;
    }
    else if (latitudinalDiff < 0) {
        return 180;
    }
    return( 0.0f );
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



