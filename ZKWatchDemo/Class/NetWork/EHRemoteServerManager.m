//
//  EHRemoteServerManager.m
//  EHHeater
//
//  Created by Jaben on 14-10-27.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#import "EHRemoteServerManager.h"


#define kAppId @"24de853461474d439d081342e68a3062"

NSString * const urlRegister = @"http://api.gizwits.com/app/users";
NSString * const urlLogin = @"http://api.gizwits.com/app/login";
NSString * const urlBindDevice = @"http://api.gizwits.com/app/bindings";
NSString * const urlControlDevice = @"http://api.gizwits.com/app/control/";
NSString * const urlGetDeviceDid = @"http://api.gizwits.com/app/devices";
NSString * const urlDeviceState = @"http://api.gizwits.com/app/devdata/";
@implementation ZKDevice

@end

/*======================================================
 EHRemoteServerManager
 /======================================================*/
#pragma mark - EHRemoteServerManager

@interface EHRemoteServerManager ()

@end

@implementation EHRemoteServerManager

+ (instancetype)shareManager {
    static EHRemoteServerManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[EHRemoteServerManager manager];
        [shareManager.requestSerializer setValue:kAppId forHTTPHeaderField:@"X-Gizwits-Application-Id"];
        [shareManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        shareManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
    });
    return shareManager;
}

- (void)registerUserWithName:(NSString *)name password:(NSString *)password completed:(ReusltBlock)completed {

    NSMutableURLRequest *request = [self createPostRequestWithURL:urlRegister];
    if (!request) {
        completed(NO,nil,nil);
        return;
    }
    
    NSDictionary *registerParameters = @{
                                         @"username":name,
                                         @"password":password,
                                         };
    
    NSString *parametersJson = [self dictionary2JsonString:registerParameters];
    request.HTTPBody = [parametersJson dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completed(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorjson = [self parseGizwitsError:error];
        completed(NO, errorjson, error);
    }];
    
    [self.operationQueue addOperation:operation];

}

- (void)loginWithName:(NSString *)name password:(NSString *)password completed:(ReusltBlock)completed {
    
    NSMutableURLRequest *request = [self createPostRequestWithURL:urlLogin];
    if (!request) {
        completed(NO,nil,nil);
        return;
    }
    
    NSDictionary *loginPrameters = @{
                                         @"username":name,
                                         @"password":password,
                                         };
    
    NSString *parametersJson = [self dictionary2JsonString:loginPrameters];
    request.HTTPBody = [parametersJson dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completed(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorjson = [self parseGizwitsError:error];
        completed(NO, errorjson, error);
    }];
    
    [self.operationQueue addOperation:operation];
    
}

- (void)getDeviceDidWithMac:(NSString *)macAddress productKey:(NSString *)productKey completed:(ReusltBlock)completed {
    NSDictionary *deviceParameters = @{
                                       @"product_key":productKey,
                                       @"mac":macAddress,
                                       };
    
    [self GET:urlGetDeviceDid parameters:deviceParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completed(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorjson = [self parseGizwitsError:error];
        completed(NO, errorjson, error);
    }];
}

- (void)bindDevice:(ZKDevice *)zkDevice userToken:(NSString *)userToken completed:(ReusltBlock)completed {
    
    [self.requestSerializer setValue:userToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    
    NSDictionary *deviceParameters = @{
                                       @"devices":@[@{
                                                        @"did":zkDevice.did,
                                                        @"passcode":zkDevice.passcode,
                                                        @"remark":@"",
                                                        }],
                                       };
    
    NSString *parametersJson = [self dictionary2JsonString:deviceParameters];
    
    NSMutableURLRequest *request = [self createPostRequestWithURL:urlBindDevice];
    if (!request) {
        completed(NO,nil,nil);
        return;
    }
    
    request.HTTPBody = [parametersJson dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completed(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorjson = [self parseGizwitsError:error];
        completed(NO, errorjson, error);
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)controlCommand:(NSArray *)command deviceWithDeviceId:(NSString *)did userToken:(NSString *)userToken completed:(ReusltBlock)completed {
    
    [self.requestSerializer setValue:userToken forHTTPHeaderField:@"X-Gizwits-User-token"];
    
    NSDictionary *commandParameters = @{
                                       @"raw":command,
                                       };
    
    NSLog(@"============ controlCommand ============");
//    NSLog(@"commandParameters %@",commandParameters);

    NSString *parametersJson = [self dictionary2JsonString:commandParameters];
    
    NSMutableURLRequest *request = [self createPostRequestWithURL:[NSString stringWithFormat:@"%@%@",urlControlDevice,did]];
    if (!request) {
        completed(NO,nil,nil);
        return;
    }
    
    request.HTTPBody = [parametersJson dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completed(YES, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorjson = [self parseGizwitsError:error];
        completed(NO, errorjson, error);
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)powerOn:(BOOL)power deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed {

    /*
     Start("1,1,1,0,0,0,0,0,0"),
     
     Close("1,1,0,0,0,0,0,0,0"),
     
     //    NSArray *powerCommand = power?@[@1,@1,@1,@0,@0,@0,@0,@0,@0]:@[@1,@1,@0,@0,@0,@0,@0,@0,@0];

     */
    
//    NSArray *powerCommand = @[@1,@1,@(power),@0,@0,@0,@0,@0,@0];
    if (!did || !token) {
        return;
    }
    NSArray *powerCommand = power?@[@1,@1,@1,@0,@0,@0,@0,@0,@0]:@[@1,@1,@0,@0,@0,@0,@0,@0,@0];

    __weak __typeof(self) weakSelf = self;

    [self controlCommand:powerCommand deviceWithDeviceId:did userToken:token completed:^(BOOL success, NSDictionary *info, NSError *error) {
        [weakSelf deviceLatestStateWithDid:did completed:^(BOOL success, ZKDevice *device, NSError *error) {
            completed(success,device,error);
        }];
    }];
}

- (void)lightState:(LightState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed {
    /*
     Lightnor   ("1,2,0,0,0,0,0,0,0"),
     Lightdark  ("1,2,0,1,0,0,0,0,0"),
     Lightcolse ("1,2,0,2,0,0,0,0,0"),
     */
    
    if (!did || !token) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;

    NSArray *lightCommand = @[@1,@2,@0,@(state),@0,@0,@0,@0,@0];
    [self controlCommand:lightCommand deviceWithDeviceId:did userToken:token completed:^(BOOL success, NSDictionary *info, NSError *error) {
        [weakSelf deviceLatestStateWithDid:did completed:^(BOOL success, ZKDevice *device, NSError *error) {
            completed(success,device,error);
        }];
    }];
}

- (void)anionOn:(NSInteger)on deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed {

    /*
     NegativeionOff ("1,16,0,0,0,0,0,0,0"),
     NegativeionOn  ("1,16,0,0,0,0,1,0,0"),
     */
    
    if (!did || !token) {
        return;
    }
    
    NSArray *anionCommand = @[@1,@16,@0,@0,@0,@0,@(on),@0,@0];
    
    __weak __typeof(self) weakSelf = self;

    [self controlCommand:anionCommand deviceWithDeviceId:did userToken:token completed:^(BOOL success, NSDictionary *info, NSError *error) {
        [weakSelf deviceLatestStateWithDid:did completed:^(BOOL success, ZKDevice *device, NSError *error) {
            completed(success,device,error);
        }];
    }];
}

- (void)windVelocity:(WindVelocityState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed {

    /*
     WindAuto   ("1,4,0,0,0,0,0,0,0"),
     WindLV1    ("1,4,0,0,1,0,0,0,0"),
     WindLV2    ("1,4,0,0,2,0,0,0,0"),
     WindLV3    ("1,4,0,0,3,0,0,0,0"),
     Windclose  ("1,4,0,0,4,0,0,0,0"),
     */
    if (!did || !token) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;

    NSArray *windVelocityCommand = @[@1,@4,@0,@0,@(state),@0,@0,@0,@0];
    [self controlCommand:windVelocityCommand deviceWithDeviceId:did userToken:token completed:^(BOOL success, NSDictionary *info, NSError *error) {
        [weakSelf deviceLatestStateWithDid:did completed:^(BOOL success, ZKDevice *device, NSError *error) {
            completed(success,device,error);
        }];
    }];
}

- (void)timerState:(TimerState)state deviceID:(NSString *)did userToken:(NSString *)token completed:(DeviceStateBlock)completed {
    /*
     Timeoff    ("1,8,0,0,0,0,0,0,0"),
     Time1      ("1,8,0,0,0,1,0,0,0"),
     Time2      ("1,8,0,0,0,2,0,0,0"),
     Time8      ("1,8,0,0,0,3,0,0,0"),
     */
    if (!did || !token) {
        return;
    }
    __weak __typeof(self) weakSelf = self;

    NSArray *timerCommand = @[@1,@8,@0,@0,@0,@(state),@0,@0,@0];
    [self controlCommand:timerCommand deviceWithDeviceId:did userToken:token completed:^(BOOL success, NSDictionary *info, NSError *error) {
        [weakSelf deviceLatestStateWithDid:did completed:^(BOOL success, ZKDevice *device, NSError *error) {
            completed(success,device,error);
        }];
    }];
}

- (void)deviceLatestStateWithDid:(NSString *)did completed:(DeviceStateBlock)completed {
    
    if (!did) {
        return;
    }
    
    NSString *stateURL = [NSString stringWithFormat:@"%@%@/latest",urlDeviceState,did];

    __weak __typeof(self) weakSelf = self;

    [self GET:stateURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"============ deviceLatestStateWithDid ============");
        NSLog(@"responseObject %@",responseObject);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotifyLog" object:responseObject];
        
        ZKDevice *device = [weakSelf deviceStateFromJson:responseObject];
        completed(YES,device,nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSDictionary *errorjson = [self parseGizwitsError:error];
        
        completed(NO,nil,error);
        
    }];
}

#pragma mark - Misc

- (NSMutableURLRequest *)createPostRequestWithURL:(NSString *)urlString {
    
    NSError *serializationError = nil;

    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:nil error:&serializationError];
    if (!serializationError) {
        return request;
    }
    return nil;
}

- (NSString *)dictionary2JsonString:(NSDictionary *)targetDic {
    NSError *parseError;
    NSData *parseData = [NSJSONSerialization dataWithJSONObject:targetDic options:NSJSONWritingPrettyPrinted error:&parseError];
    if (!parseError) {
        return [[NSString alloc] initWithData:parseData encoding:NSUTF8StringEncoding];

    }
    return @"";
}

- (NSDictionary *)parseGizwitsError:(NSError *)error {
    NSDictionary *errorDic = error.userInfo;
    NSData *errorData = errorDic[@"com.alamofire.serialization.response.error.data"];
    return [self parseDataToDictionary:errorData];
}

- (NSDictionary *)parseDataToDictionary:(NSData *)data {
    NSError *parseError;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
    if (!parseError) {
        return jsonDict;
    }
    return nil;
}

- (ZKDevice *)deviceStateFromJson:(NSDictionary *)jsonDic {
    ZKDevice *device = [[ZKDevice alloc] init];
    
    NSDictionary *info = jsonDic[@"attr"];
    
    device.GRPS         = [info[@"GPRS"] integerValue];
    device.anion        = [info[@"anion"] integerValue];
    device.err1         = [info[@"err1"] integerValue];
    device.err2         = [info[@"err2"] integerValue];
    device.err3         = [info[@"err3"] integerValue];
    device.fanSpeed     = [info[@"fan_speed"] integerValue];
    device.humi         = [info[@"humi"] integerValue];
    device.irCMD        = [info[@"ir_cmd"] integerValue];
    device.irKeyID      = [info[@"ir_key_id"] integerValue];
    device.irStatus     = [info[@"ir_status"] integerValue];
    device.light        = [info[@"light"] integerValue];
    device.pm25H        = [info[@"pm25_H"] integerValue];
    device.pm25L        = [info[@"pm25_L"] integerValue];
    device.startStop    = [info[@"start_stop"] integerValue];
    device.temp         = [info[@"temp"] integerValue];
    device.timing       = [info[@"timing"] integerValue];
    
    device.did          = jsonDic[@"did"];

    return device;
}

@end
