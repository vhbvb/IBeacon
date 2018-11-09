//
//  ViewController.m
//  IBeaconDemo
//
//  Created by Max on 2018/8/14.
//  Copyright © 2018年 Max. All rights reserved.
//

#import "ViewController.h"
#import "MOBIBeaconManager.h"
#import <MOBFoundation/MOBFoundation.h>

@interface ViewController ()<MOBIBeaconManagerDelegate>
{
    NSArray *_uuids;
    NSMutableArray *infos;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MOBIBeaconManager shareManager].delegate = self;
    _uuids = @[@"4B41F7C1-007C-40F9-B402-3999176ED9B1",@"F2BFC2C5-DC94-4920-93FD-0BAC139B977D",@"1C702ECB-09A9-457E-8C7E-709FA68455F4"];
    infos = [NSMutableArray array];
//    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"^_^");
//    }];

}

- (IBAction)sender:(id)sender
{
    static NSInteger i = 0;
    static uint16_t major = 1000;
    static uint16_t minor = 100;
    
    NSString *uuid = _uuids[i++];
    CLBeaconRegion *br = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major++ minor:minor++ identifier:uuid];
    [[MOBIBeaconManager shareManager] advertisingWithBeacons:@[br]];
}


- (IBAction)receive:(id)sender
{
    for (NSString *uuid in _uuids)
    {
        CLBeaconRegion *br = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:uuid];
        [[MOBIBeaconManager shareManager] monitorBeacons:@[br]];
    }
}

- (IBAction)cache:(id)sender
{
    NSArray *tmp = [[MOBFDataService sharedInstance] cacheDataForKey:@"test" domain:@"main"];
    
    NSLog(@"+++++++++++++++++++++++++++\n%@",tmp);
}

#pragma mark - MOBIBeaconManagerDelegate

- (void)beaconRegion:(CLBeaconRegion *)beacon didFailAdvertisingWithError:(NSError *)error
{
    NSLog(@"------------------------\n%s\n%@",__func__,error.userInfo);
}

- (void)beaconRegion:(CLBeaconRegion *)beacon didFailMonitorWithError:(NSError *)error
{
     NSLog(@"------------------------\n%s\n%@",__func__,error.userInfo);
}

- (void)beaconRegion:(CLBeaconRegion *)beacon didRangeBeacons:(NSArray<CLBeacon *> *)beacons
{
    for (CLBeacon *beacon in beacons)
    {
        NSDictionary *info = @{
                               @"uuid":beacon.proximityUUID?:@"",
                               @"major":beacon.major,
                               @"minor":beacon.minor,
                               @"proximity":@(beacon.proximity),
                               @"rssi":@(beacon.rssi)
                               };
        
        NSLog(@"-----------------------------------\n%@",info);
        [infos addObject:info];
        
        NSArray *arr = [[MOBFDataService sharedInstance] cacheDataForKey:@"test" domain:@"main"];
        if ([arr isKindOfClass:NSArray.class])
        {
            NSMutableArray *tmp = arr.mutableCopy;
            [tmp addObject:info];
            [[MOBFDataService sharedInstance] setCacheData:tmp forKey:@"test" domain:@"main"];
        }
        else
        {
            [[MOBFDataService sharedInstance] setCacheData:@[info].mutableCopy forKey:@"test" domain:@"main"];
        }
    }
}

- (void)didEnterRegion:(CLRegion *)region
{
    [[[UIAlertView alloc] initWithTitle:@"text" message:@"test" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"sure", nil] show];
    NSLog(@"------------------------\n%s\n%@",__func__,region);
}

@end
