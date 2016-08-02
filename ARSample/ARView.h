//
//  ARView.h
//  ARSample
//
//  Created by hirauchi.shinichi on 2016/07/31.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h> // CMAccelerationを使用するのであれば

@interface ARView : UIView
@property (nonatomic) CMAcceleration gravity;
@property (nonatomic) float heading;
@property (nonatomic) UIDeviceOrientation orientation;
@property (nonatomic) float azimuth;

- (void)startAnimation;
- (void)stopAnimation;


@end
