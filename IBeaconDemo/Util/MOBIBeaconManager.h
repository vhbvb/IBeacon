//
//  MOBIBeaconManager.h
//  IBeaconDemo
//
//  Created by Max on 2018/8/14.
//  Copyright © 2018年 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, MOBIBErrorState) {
    MOBIBErrorStateBluetooth,
    MOBIBErrorStateLocation
};


@protocol MOBIBeaconManagerDelegate <NSObject>

/**
 创建监听错误
 */
- (void)beaconRegion:(CLBeaconRegion *)beacon didFailMonitorWithError:(NSError *)error;

/**
 监听到附近beacons信息
 */
- (void)beaconRegion:(CLBeaconRegion *)beacon didRangeBeacons:(NSArray<CLBeacon *> *)beacons;

/**
 发送Beacon信息失败
 */
- (void)beaconRegion:(CLBeaconRegion *)beacon didFailAdvertisingWithError:(NSError *)error;

/**
 发现有iBeacon设备进入扫描范围回调
 */
- (void)didEnterRegion:(CLRegion *)region;

@end


@interface MOBIBeaconManager : NSObject

/**
 单例对象
 */
+ (instancetype)shareManager;

/**
 回调代理
 */
@property (weak, nonatomic) id<MOBIBeaconManagerDelegate> delegate;

/**
 发送Beacon信息
 
 @param beaconRegions 需要发送的Beacon
 */
- (void)advertisingWithBeacons:(NSArray <CLBeaconRegion *>*)beaconRegions;

/**
 监听的Beacon
 
 @param beaconRegions 需要监听的Beacon数组
 */
- (void)monitorBeacons:(NSArray <CLBeaconRegion *>*)beaconRegions;

@end
