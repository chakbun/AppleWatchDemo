//
//  EHRemoteServerManager.h
//  EHHeater
//
//  Created by Jaben on 14-10-27.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


#define kUID @"uid"
#define kToken @"token"
#define kExpireAt @"expire_at"
#define kDid @"did"
#define kPasscode @"passcode"

#define kProductKey @"ca1d686173144ffe99c41091bb568335"

@interface ZKDevice : NSObject
@property (nonatomic, strong) NSString *did;
@property (nonatomic, strong) NSString *passcode;
@property (nonatomic, strong) NSString *remark;

@property (nonatomic, assign) NSInteger GRPS;
@property (nonatomic, assign) NSInteger anion;
@property (nonatomic, assign) NSInteger err1;
@property (nonatomic, assign) NSInteger err2;
@property (nonatomic, assign) NSInteger err3;
@property (nonatomic, assign) NSInteger fanSpeed;
@property (nonatomic, assign) NSInteger humi;
@property (nonatomic, assign) NSInteger irCMD;
@property (nonatomic, assign) NSInteger irKeyID;
@property (nonatomic, assign) NSInteger irStatus;
@property (nonatomic, assign) NSInteger light;
@property (nonatomic, assign) NSInteger pm25H;
@property (nonatomic, assign) NSInteger pm25L;
@property (nonatomic, assign) NSInteger startStop;
@property (nonatomic, assign) NSInteger temp;
@property (nonatomic, assign) NSInteger timing;


@end

#pragma mark - EHRemoteServerManager

/*======================================================
 EHRemoteServerManager
 /======================================================*/

typedef void(^ReusltBlock)(BOOL success, NSDictionary *info, NSError *error);
typedef void(^DeviceStateBlock)(BOOL success, ZKDevice *device, NSError *error);

typedef NS_ENUM(NSInteger, LightState) {
    LightStateNormal    = 0,
    LightStateDim       = 1,
    LightStateOff       = 2,
};

typedef NS_ENUM(NSInteger, WindVelocityState) {
    WindVelocityStateAuto       = 0,
    WindVelocityStateL1         = 1,
    WindVelocityStateL2         = 2,
    WindVelocityStateL3         = 3,
    WindVelocityStateSilence    = 4,
};

typedef NS_ENUM(NSInteger, TimerState) {
    TimerStateOff   = 0,
    TimerStateHour1 = 1,
    TimerStateHour2 = 2,
    TimerStateHour8 = 3,
};

typedef NS_ENUM(NSInteger, CleanerFuc) {
    CleanerFucPower   = 0,
    CleanerFucLight = 1,
    CleanerFucAnion = 2,
    CleanerFucWindVelocity = 3,
    CleanerFucTimer = 4,
};

@interface EHRemoteServerManager : AFHTTPRequestOperationManager



+ (instancetype)shareManager;

- (void)registerUserWithName:(NSString *)name password:(NSString *)password completed:(ReusltBlock)completed;

- (void)loginWithName:(NSString *)name password:(NSString *)password completed:(ReusltBlock)completed;

- (void)getDeviceDidWithMac:(NSString *)macAddress productKey:(NSString *)productKey completed:(ReusltBlock)completed;

- (void)bindDevice:(ZKDevice *)zkDevice userToken:(NSString *)userToken completed:(ReusltBlock)completed;

- (void)controlCommand:(NSArray *)command deviceWithDeviceId:(NSString *)did userToken:(NSString *)userToken completed:(ReusltBlock)completed;

- (void)powerOn:(BOOL)power deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed;

- (void)lightState:(LightState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed;

- (void)anionOn:(NSInteger)on deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed;

- (void)windVelocity:(WindVelocityState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed;

- (void)timerState:(TimerState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed;

- (void)deviceLatestStateWithDid:(NSString *)did completed:(DeviceStateBlock)completed;
@end
