//
//  BTConnector.h
//  BLETool
//
//  Created by XPG on 15/4/9.
//  Copyright (c) 2015年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

#define kPeriphralBroadcastName @"BLE Device-"

#define kUUIDService @"FF12"
#define kUUIDCharacteristicNotify @"FF02"
#define kUUIDCharacteristicWrite @"FF01"

#define kNotificationGetValueFromBT @"kNotificationGetValueFromBT"
#define kNotificationSendValueToBT @"kNotificationSendValueToBT"

typedef NS_ENUM(Byte, BTFunctionIndex) {
    BTFunctionIndexBlanking = 0x0a, // 消隐状态
    BTFunctionIndexPower = 0x01,
    BTFunctionIndexBrightness = 0x02,
    BTFunctionIndexHeating = 0x03,
    BTFunctionIndexTemp = 0x04,
    BTFunctionIndexTime = 0x05,
    BTFunctionIndexCharcoalColor = 0x06,
    BTFunctionIndexFireColor = 0x07,
    BTFunctionIndexLock = 0x08,
    BTFunctionIndexPairing = 0xfa,
    BTFunctionIndexError = 0xf9,
};


typedef NS_ENUM(NSInteger, BTFireBrightnessLevel) {
    BTFireBrightnessLevelNone = 0,
    BTFireBrightnessLevelLow,
    BTFireBrightnessLevelMid,
    BTFireBrightnessLevelHigh,
};

typedef NS_ENUM(NSInteger, BTFireHeatingLevel) {
    BTFireHeatingLevelNone = 0,
    BTFireHeatingLevelLow,
    BTFireHeatingLevelHigh,
};

typedef NS_ENUM(NSInteger, BTColor) {
    BTColorNone = 0,
    BTColorOrange,
    BTColorBlue,
    BTColorPurple,
    BTColorCycle // 三种顏色，每5秒三色循環狀態.
};

typedef NS_ENUM(NSInteger, BTTempUnit) {
    BTTempUnitCelsius = 12,
    BTTempUnitFahrenheit = 15,
};

typedef NS_ENUM(NSInteger, BTError) {
    BTErrorNTC = 1, //电壁炉NTC故障
    BTErrorT_FUSE = 2, //T-FUSE故障
    BTErrorDoorClose = 3, //检测到闭门
};

/*======================================================
 BTStateInfo
 /======================================================*/

@interface BTStateInfo : NSObject
@property (nonatomic, assign) Byte function;
@property (nonatomic, assign) NSInteger arg;
@property (nonatomic, assign) BTTempUnit unit;
@property (nonatomic, assign) BTColor color;
@end

/*======================================================
 BTConnectorDelegate
 /======================================================*/

@protocol BTConnectorDelegate <NSObject>

@required
- (void)didBLEUpdateState:(CBCentralManagerState)state;

@optional
- (void)didFoundPeripheral:(CBPeripheral *)jrPeripheral;
- (void)didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)didFailToConnectPeripheral:(CBPeripheral *)peripheral;
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral;
- (void)didUpdateState:(BTStateInfo *)stateInfo;
@end

/*======================================================
 BTConnector
 /======================================================*/

@interface BTConnector : NSObject

@property (nonatomic, strong) id<BTConnectorDelegate> delegate;

+ (instancetype)shareManager;

- (void)startScanPeripheral:(NSArray *)serviceUUIDs;

- (void)stopScanPeripheral;

- (BOOL)connectPeripheral:(CBPeripheral *)jrPeripheral;

- (BOOL)cancelConnectPeripheral:(CBPeripheral *)jrPeripheral;

- (void)sendPairingAction:(BOOL)firstTime; // 连接成功后，配对的命令。

- (void)powerAction; //1：开关机键

- (void)fireBrightnessAction; //2：火焰亮度键

- (void)heatingAction; //3：加热键

- (void)temperatureAction:(BTTempUnit)unit; // 轻触碰温度事件

- (void)setTemperatureInCelsius:(NSInteger)temp; //设定摄氏温度 （17-30）

- (void)setTemperatureInFahrenheit:(NSInteger)temp; // 设定华氏温度 (62-86)

- (void)changeUnitWithImageIndex:(NSInteger)imageIndex toUnit:(BTTempUnit)unit; // imageIndex(0-13)

- (void)setWorkingTime:(NSInteger)time; // 定时停止工作时间(0~9h)

- (void)workingTimeAction; // 定时点操作

- (void)charcoalColorAction;

- (void)fireColorAction;

- (void)heatingWithLock:(BOOL)lock; //锁定命令, yes:锁定， no: 解除锁定
@end
