//
//  JRCBPeriperal.h
//  BLETool
//
//  Created by XPG on 14-12-23.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>

@interface JRCBPeripheral : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary *advertisementData;
@property (nonatomic, strong) NSNumber *periphalRSSI;
@end
