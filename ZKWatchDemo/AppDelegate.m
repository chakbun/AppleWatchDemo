//
//  AppDelegate.m
//  ZKWatchDemo
//
//  Created by Jaben on 15/5/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "AppDelegate.h"
#import "EHRemoteServerManager.h"
#import "AppGloble.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSDictionary *)makeReplyInfo:(ZKDevice *)device {
    return @{
             kPower:@(device.startStop),
             kTimer:@(device.timing),
             kLight:@(device.light),
             kSpeed:@(device.fanSpeed),
             kAnion:@(device.anion),
             kTemp:@(device.temp),
             kHumi:@(device.humi),
             kPM25_In:@(device.pm25L),
             kPM25_Out:@(device.pm25H),
             };
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    
    NSInteger fuc = [userInfo[Message_Func] integerValue];
    
    NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
    
    __weak __typeof(self) weakSelf = self;

    switch (fuc) {
        case Message_Func_Power:{
            [[EHRemoteServerManager shareManager] powerOn:[userInfo[Message_Arg] boolValue] deviceID:deviceID userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        case Message_Func_Light:{
            NSInteger lightState = [userInfo[Message_Arg] integerValue];
            [[EHRemoteServerManager shareManager] lightState:lightState deviceID:deviceID userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        case Message_Func_Anion:{
            BOOL on = [userInfo[Message_Arg] boolValue];
            [[EHRemoteServerManager shareManager] anionOn:on deviceID:deviceID userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        case Message_Func_WindV:{
            NSInteger windState = [userInfo[Message_Arg] integerValue];
            [[EHRemoteServerManager shareManager] windVelocity:windState deviceID:deviceID userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        case Message_Func_Timer:{
            NSInteger timerState = [userInfo[Message_Arg] integerValue];
            [[EHRemoteServerManager shareManager] timerState:timerState deviceID:deviceID userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        case Message_Func_State:{
            [[EHRemoteServerManager shareManager] deviceLatestStateWithDid:deviceID completed:^(BOOL success, ZKDevice *device, NSError *error) {
                if (!error) {
                    NSDictionary *replyInfo = [weakSelf makeReplyInfo:device];
                    reply(replyInfo);
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
