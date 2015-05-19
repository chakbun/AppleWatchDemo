//
//  ZKCleanerController.m
//  ZKWatchDemo
//
//  Created by Jaben on 15/5/18.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "ZKCleanerController.h"
#import "AppGloble.h"

@interface ZKCleanerController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *tempLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *humiLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pm25OutdoorLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pm25IndoorLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *pm25IndoorLevelLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceButton *powerButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *anionButton;

@property (weak, nonatomic) IBOutlet WKInterfaceSlider *speedSlider;

@property (nonatomic, strong) NSTimer *deviceStateTimer;

@property (nonatomic, assign) NSInteger powerState;
@property (nonatomic, assign) NSInteger timerState;
@property (nonatomic, assign) NSInteger lightState;
@property (nonatomic, assign) NSInteger anionState;
@property (nonatomic, assign) NSInteger speedState;

@property (nonatomic, assign) CGFloat temp;
@property (nonatomic, assign) CGFloat humi;
@property (nonatomic, assign) CGFloat pm25Outdoor;
@property (nonatomic, assign) CGFloat pm25Indoor;

@end

@implementation ZKCleanerController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.speedSlider setNumberOfSteps:4]; // 0 - 0.75 - 1.5 - 2.25 - 3
    [self.speedSlider setValue:4];
    
    self.deviceStateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestState) userInfo:nil repeats:YES];
}

- (void)willActivate {

    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma mark - Misc

- (NSString *)pm25Level:(CGFloat)pm25 {
    if (pm25 < 35) {
        return @"优秀";
    }else if(pm25 < 75) {
        return @"良";
    }else if(pm25 < 115) {
        return @"轻度污染";
    }else if(pm25 < 150) {
        return @"中度污染";
    }else if(pm25 < 250) {
        return @"重度污染";
    }else if(pm25 < 500) {
        return @"严重污染";
    }else{
        return @"";
    }
}

- (UIColor *)pm25LevelColor:(CGFloat)pm25 {
    if (pm25 < 35) {
        return [UIColor colorWithRed:1/255.0 green:149/255.0 blue:219/255.0 alpha:1];
    }else if(pm25 < 75) {
        return [UIColor colorWithRed:1/255.0 green:221/255.0 blue:161/255.0 alpha:1];
    }else if(pm25 < 115) {
        return [UIColor colorWithRed:32/255.0 green:240/255.0 blue:0/255.0 alpha:1];
    }else if(pm25 < 150) {
        return [UIColor colorWithRed:168/255.0 green:214/255.0 blue:19/255.0 alpha:1];
    }else if(pm25 < 250) {
        return [UIColor colorWithRed:219/255.0 green:201/255.0 blue:28/255.0 alpha:1];
    }else if(pm25 < 500) {
        return [UIColor colorWithRed:239/255.0 green:194/255.0 blue:0/255.0 alpha:1];
    }else{
        return [UIColor colorWithRed:1/255.0 green:149/255.0 blue:219/255.0 alpha:1];
    }
}

- (void)requestState {
    
    NSDictionary *stateUserInfo = [self controlUserInfo:Message_Func_State arg:1];

    __weak __typeof(self) weakSelf = self;

    [WKInterfaceController openParentApplication:stateUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!error) {
            [weakSelf updateDeviceState:replyInfo];
        }
    }];
}

- (void)updateDeviceState:(NSDictionary *)info {
    
    self.powerState = [info[kPower] integerValue];
    self.timerState = [info[kTimer] integerValue];
    self.lightState = [info[kLight] integerValue];
    self.anionState = [info[kAnion] integerValue];
    self.speedState = [info[kSpeed] integerValue];
    
    self.temp = [info[kTemp] floatValue];
    self.humi = [info[kHumi] floatValue];
    self.pm25Indoor = [info[kPM25_In] floatValue];
    self.pm25Outdoor = [info[kPM25_Out] floatValue];
    
    [self.tempLabel setText:[NSString stringWithFormat:@"温度:%ld ℃",(NSInteger)self.temp]];
    [self.humiLabel setText:[NSString stringWithFormat:@"湿度:%ld %%",(NSInteger)self.humi]];
    [self.pm25OutdoorLabel setText:[NSString stringWithFormat:@"室外PM2.5:%ld",(NSInteger)self.pm25Outdoor]];
    
    UIColor *pm25Color = [self pm25LevelColor:self.pm25Indoor];
    NSString *pm25Level = [self pm25Level:self.pm25Indoor];
    
    [self.pm25IndoorLabel setTextColor:pm25Color];
    [self.pm25IndoorLabel setText:[NSString stringWithFormat:@"%ld",(NSInteger)self.pm25Indoor]];
    
    [self.pm25IndoorLevelLabel setTextColor:pm25Color];
    [self.pm25IndoorLevelLabel setText:pm25Level];

    NSString *powerTitle = self.powerState == 0?@"开机":@"关机";
    [self.powerButton setTitle:powerTitle];
    
    NSString *anionTitle = self.anionState == 0?@"负离子开":@"负离子关";
    [self.anionButton setTitle:anionTitle];
    
    CGFloat slideValue = 0;
    
    if (self.speedState == 0) {
        slideValue = 3; // auto
    }else if(self.speedState == 3) {
        slideValue = 2.25; // 3
    }else if(self.speedState == 2) {
        slideValue = 1.5; // 2
        
    }else if(self.speedState == 1) {
        slideValue = 0.75; // 1
        
    }else if(self.speedState == 4) {
        slideValue = 0; // silent
    }
    [self.speedSlider setValue:slideValue];
    
}

- (NSDictionary *)controlUserInfo:(NSInteger)fuc arg:(NSInteger)arg {
    return @{
             Message_Func : @(fuc),
             Message_Arg : @(arg),
             };
}

#pragma mark - Button Action

- (IBAction)h1MenuAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:1];
    
    __weak __typeof(self) weakSelf = self;
    
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!error) {
            [weakSelf updateDeviceState:replyInfo];
        }
    }];

}

- (IBAction)h4MenuAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:2];
    
    __weak __typeof(self) weakSelf = self;
    
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!error) {
            [weakSelf updateDeviceState:replyInfo];
        }
    }];
}

- (IBAction)h8MenuAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:3];
    
    __weak __typeof(self) weakSelf = self;
    
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!error) {
            [weakSelf updateDeviceState:replyInfo];
        }
    }];
}

- (IBAction)timerOffMenuAction {
    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_Timer arg:0];
    
    __weak __typeof(self) weakSelf = self;
    
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        if (!error) {
            [weakSelf updateDeviceState:replyInfo];
        }
    }];
}

- (IBAction)anionButtonAction {
    NSInteger anionValue = self.anionState == 0?1:0;
    NSDictionary *anionUserInfo = [self controlUserInfo:Message_Func_Anion arg:anionValue];
    
    __weak __typeof(self) weakSelf = self;
    
    [WKInterfaceController openParentApplication:anionUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
        [weakSelf updateDeviceState:replyInfo];
        
    }];
}

- (IBAction)powerButtonAction {
    NSInteger powerValue = self.powerState == 0?1:0;
    NSDictionary *powerOnUserInfo = [self controlUserInfo:Message_Func_Power arg:powerValue];

    __weak __typeof(self) weakSelf = self;

    [WKInterfaceController openParentApplication:powerOnUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        
        [weakSelf updateDeviceState:replyInfo];
        
    }];
}

- (IBAction)valueChangeAction:(float)value {
    
    __weak __typeof(self) weakSelf = self;

    NSInteger speedValue = 0;
    
    if (value == 3) {
        speedValue = 0; // auto
    }else if(value == 2.25) {
        speedValue = 3; // 3
    }else if(value == 1.5) {
        speedValue = 2; // 2

    }else if(value == 0.75) {
        speedValue = 1; // 1

    }else if(value == 0) {
        speedValue = 4; // silent

    }

    NSDictionary *powerOffUserInfo = [self controlUserInfo:Message_Func_WindV arg:speedValue];
    [WKInterfaceController openParentApplication:powerOffUserInfo reply:^(NSDictionary *replyInfo, NSError *error) {
        [weakSelf updateDeviceState:replyInfo];
    }];
}

@end



