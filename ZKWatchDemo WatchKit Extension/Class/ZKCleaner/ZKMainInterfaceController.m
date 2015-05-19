//
//  ZKMainInterfaceController.m
//  ZKWatchDemo
//
//  Created by Jaben on 15/5/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "ZKMainInterfaceController.h"
#import "AppGloble.h"

@interface ZKMainInterfaceController ()

@end

@implementation ZKMainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - ButtonAction

- (IBAction)PowerButtonAction {
    NSDictionary *powerOnUserInfo = [self controlUserInfo:Message_Func_Power arg:1];
    [WKInterfaceController openParentApplication:powerOnUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)PowerOffAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Power arg:0];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)lightNormalAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Light arg:0];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)lightDimAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Light arg:1];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)lightOffAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Light arg:2];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)speedAutoAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:0];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)speedSilentAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:4];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)speedL1Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:1];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)speedL2Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:2];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)speedL3Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:3];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)timer1Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:1];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)timer4Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:2];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)timer8Action {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:3];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)timerOffAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:0];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)anionOnAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Anion arg:1];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

- (IBAction)anionOffAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Anion arg:0];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

#pragma mark - Misc 

- (NSDictionary *)controlUserInfo:(NSInteger)fuc arg:(NSInteger)arg {
    return @{
             Message_Func : @(fuc),
             Message_Arg : @(arg),
             };
}

@end



