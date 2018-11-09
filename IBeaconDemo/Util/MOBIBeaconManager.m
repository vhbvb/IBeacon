//
//  MOBIBeaconManager.m
//  IBeaconDemo
//
//  Created by Max on 2018/8/14.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "MOBIBeaconManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MOBIBeacon.h"

@interface MOBIBeaconManager()<CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray *advertsings;

@end

@implementation MOBIBeaconManager

+ (instancetype)shareManager
{
    static MOBIBeaconManager *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[MOBIBeaconManager alloc] init];
        singleton.advertsings = [NSMutableArray array];
    });
    
    return singleton;
}

- (void)advertisingWithBeacons:(NSArray <CLBeaconRegion *>*)beaconRegions;
{
    for (CLBeaconRegion *br in beaconRegions)
    {
        CBPeripheralManager *peripheraManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        MOBIBeacon *beacon = [[MOBIBeacon alloc] init];
        beacon.beaconRegion = br;
        beacon.peripheral = peripheraManager;
        [self.advertsings addObject:beacon];
    }
}

- (void)monitorBeacons:(NSArray <CLBeaconRegion *>*)beaconRegions
{
    for (CLBeaconRegion *br in beaconRegions)
    {
        br.notifyEntryStateOnDisplay = YES;//会激活app
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
        MOBIBeacon *beacon = [[MOBIBeacon alloc] init];
        beacon.beaconRegion = br;
        beacon.locationManager = manager;
        [self.advertsings addObject:beacon];

        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            [manager requestAlwaysAuthorization];
        }
        else
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
            {
                [beacon.locationManager startRangingBeaconsInRegion:br];
            }
            else
            {
                for (CLBeaconRegion *br in beaconRegions)
                {
                    NSError *error = [NSError errorWithDomain:@"MOBIBeacon" code:MOBIBErrorStateLocation userInfo:@{@"message":@"Location authorization"}];
                    [self.delegate beaconRegion:br didFailMonitorWithError:error];
                }
            }
        }
    }
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        for (MOBIBeacon *beacon in self.advertsings)
        {
            if (beacon.peripheral == peripheral)
            {
                NSDictionary *data = [beacon.beaconRegion peripheralDataWithMeasuredPower:nil];
                [peripheral startAdvertising:data];
            }
        }
    }
    else
    {
        for (MOBIBeacon *beacon in self.advertsings)
        {
            if (beacon.peripheral == peripheral)
            {
                NSError *error = [NSError errorWithDomain:@"MOBIBeacon" code:MOBIBErrorStateBluetooth userInfo:@{@"message":@"Bluetooth state"}];
                [self.delegate beaconRegion:beacon.beaconRegion didFailAdvertisingWithError:error];
            }
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(nonnull CLRegion *)region
{
    [self.delegate didEnterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    [self.delegate beaconRegion:region didRangeBeacons:beacons];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        for (MOBIBeacon *beacon in self.advertsings)
        {
            if (beacon.locationManager == manager)
            {
                [manager startRangingBeaconsInRegion:beacon.beaconRegion];
            }
        }
    }
    else
    {
        for (MOBIBeacon *beacon in self.advertsings)
        {
            if (beacon.locationManager == manager)
            {
                NSError *error = [NSError errorWithDomain:@"MOBIBeacon" code:MOBIBErrorStateLocation userInfo:@{@"message":@"Location authorization"}];
                [self.delegate beaconRegion:beacon.beaconRegion didFailMonitorWithError:error];
            }
        }
    }
}

@end
