//
//  MOBIBeacon.h
//  IBeaconDemo
//
//  Created by Max on 2018/8/14.
//  Copyright © 2018年 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CBPeripheralManager;
@class CLBeaconRegion;
@class CLLocationManager;

@interface MOBIBeacon : NSObject

@property (strong, nonatomic) CBPeripheralManager *peripheral;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@end
