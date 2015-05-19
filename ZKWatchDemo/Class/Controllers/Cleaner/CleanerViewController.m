//
//  CleanerViewController.m
//  ZKWatchDemo
//
//  Created by Jaben on 15/5/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "CleanerViewController.h"
#import "EHRemoteServerManager.h"
#import "CDZQRScanningViewController.h"

#define kUserName @"touch002"
#define kUserPassword @"123456"
#define kDeviceMac @"040006706196"

@interface CleanerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (nonatomic, strong) NSString *gUID;
@property (nonatomic, strong) NSString *gToken;
@property (nonatomic, strong) NSString *gExpireAt;
@property (nonatomic, strong) NSString *gDid;
@property (nonatomic, strong) NSString *gPasscode;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;

@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UILabel *didLabel;
@property (weak, nonatomic) IBOutlet UILabel *macLabel;
@property (weak, nonatomic) IBOutlet UILabel *passcodeLabel;

@property (weak, nonatomic) IBOutlet UILabel *powerLabel;
@property (weak, nonatomic) IBOutlet UILabel *lightLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *anionLabel;


@end

@implementation CleanerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.macLabel.text = [NSString stringWithFormat:@"Mac:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"kMAC"]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveResponse:) name:@"kNotifyLog" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Misc 

- (void)didReceiveResponse:(NSNotification *)notify {
    [self appendTextToLog:notify.object];
}

- (void)appendTextToLog:(id)text {
    self.logTextView.text = [NSString stringWithFormat:@"%@ \n%@",text,self.logTextView.text];
}

- (UIAlertController *)actionSheetConroller:(NSString *)title {
    UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    return actionSheetController;
}

- (void)updateDeviceState:(ZKDevice *)device {

    self.powerLabel.text = [NSString stringWithFormat:@"Power:%@",device.startStop==1?@"On":@"Off"]; // 0开，1关
    self.anionLabel.text = [NSString stringWithFormat:@"Anion:%@",device.anion==0?@"On":@"Off"]; //on: off:

    NSString *lightState[]={@"Nor",@"Off",@"Dim"};
    self.lightLabel.text = [NSString stringWithFormat:@"Light:%@",lightState[device.light]]; //nor:0 off:1 dim:2
    
    NSString *windState[]={@"Auto",@"level 1",@"level 2",@"level 3",@"Silence"};
    self.windLabel.text = [NSString stringWithFormat:@"Wind:%@",windState[device.fanSpeed]]; //auto:0 1: 2: 3: silence:
    
    NSString *timerState[]={@"H1",@"H2",@"H8",@"Off"};
    self.timerLabel.text = [NSString stringWithFormat:@"Timer:%@",timerState[device.timing]]; //1: 2: 8: off:
}


#pragma mark - Button Action

- (IBAction)registerUserAction:(id)sender {
    [[EHRemoteServerManager shareManager] registerUserWithName:kUserName password:kUserPassword completed:^(BOOL success, NSDictionary *info, NSError *error) {
        
        NSLog(@"============ registerUserWithName %@ ============",info);

        if (success) {
            [self appendTextToLog:@"-----> regist sucessful !"];
        }else {
            [self appendTextToLog:@"-----> regist fail !"];
        }
        [self appendTextToLog:info?:@"no error message"];
    }];
}

- (IBAction)loginUserAction:(id)sender {
    [[EHRemoteServerManager shareManager] loginWithName:kUserName password:kUserPassword completed:^(BOOL success, NSDictionary *info, NSError *error) {
        
        NSLog(@"============ loginUserAction %@============",info);

        if (success) {
            [self appendTextToLog:@"-----> login successful !"];
            self.gUID = info[kUID];
            self.gToken = info[kToken];
            self.gExpireAt = info[kExpireAt];
            
            self.nameLabel.text = [NSString stringWithFormat:@"name:%@",kUserName];
            self.uidLabel.text = [NSString stringWithFormat:@"UID:%@",self.gUID];
            self.tokenLabel.text = [NSString stringWithFormat:@"token:%@",self.gToken];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.gToken forKey:@"gToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }else {
            [self appendTextToLog:@"-----> login fail !"];
        }
        [self appendTextToLog:info?:@"no error message"];
    }];
}

- (IBAction)getDidAction:(id)sender {
    NSString *mac = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMAC"];
    if (mac) {
        [[EHRemoteServerManager shareManager] getDeviceDidWithMac:mac productKey:kProductKey completed:^(BOOL success, NSDictionary *info, NSError *error) {
            
            NSLog(@"============ getDidAction %@============",info);
            if (!error) {
                [self appendTextToLog:@"-----> getDid successful !"];
                self.gDid = info[kDid];
                self.gPasscode = info[kPasscode];
                
                self.didLabel.text = [NSString stringWithFormat:@"DID:%@",self.gDid];
                self.passcodeLabel.text = [NSString stringWithFormat:@"passCode:%@",self.gPasscode];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.gDid forKey:@"gDeviceID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
            }else {
                [self appendTextToLog:@"-----> getDid fail !"];
            }
            [self appendTextToLog:info?:@"no error message"];
        }];
    }

}

- (IBAction)bindDeviceAction:(id)sender {
    
    if (!self.gDid || !self.gPasscode) {
        return;
    }
    
    ZKDevice *zkDevice = [[ZKDevice alloc] init];
    
    zkDevice.did = self.gDid;
    zkDevice.passcode = self.gPasscode;

    [[EHRemoteServerManager shareManager] bindDevice:zkDevice userToken:self.gToken completed:^(BOOL success, NSDictionary *info, NSError *error) {
        
        NSLog(@"============ bindDeviceAction %@============",info);
        if (!error) {
            [self appendTextToLog:@"-----> bindDevice successful !"];
        }else {
            [self appendTextToLog:@"-----> bindDevice fail !"];
        }
        [self appendTextToLog:info?:@"no error message"];
    }];
}


- (IBAction)clearLogAction:(id)sender {
    self.logTextView.text = @"";
}

- (IBAction)powerAction:(id)sender {
    UIAlertController *actionSheetController = [self actionSheetConroller:@"Power"];
    
    __weak __typeof(self) weakSelf = self;

    UIAlertAction *onAction = [UIAlertAction actionWithTitle:@"On" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] powerOn:YES deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            if (!error) {
                [weakSelf updateDeviceState:device];
            }
        }];
    }];
    
    UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] powerOn:NO deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            if (!error) {
                [weakSelf updateDeviceState:device];
            }
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actionSheetController addAction:onAction];
    [actionSheetController addAction:offAction];
    [actionSheetController addAction:cancelAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
    
}

- (IBAction)lightAction:(id)sender {
    UIAlertController *actionSheetController = [self actionSheetConroller:@"Light"];
    
    __weak __typeof(self) weakSelf = self;

    UIAlertAction *norAction = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] lightState:LightStateNormal deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *dimAction = [UIAlertAction actionWithTitle:@"Dim" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] lightState:LightStateDim deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] lightState:LightStateOff deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actionSheetController addAction:norAction];
    [actionSheetController addAction:dimAction];
    [actionSheetController addAction:offAction];
    [actionSheetController addAction:cancelAction];
    
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)timerAction:(id)sender {
    UIAlertController *actionSheetController = [self actionSheetConroller:@"Timer"];
    
    __weak __typeof(self) weakSelf = self;

    UIAlertAction *h1Action = [UIAlertAction actionWithTitle:@"1 hour" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] timerState:TimerStateHour1 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *h2Action = [UIAlertAction actionWithTitle:@"2 hours" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] timerState:TimerStateHour2 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *h8Action = [UIAlertAction actionWithTitle:@"8 hours" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] timerState:TimerStateHour8 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] timerState:TimerStateOff deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actionSheetController addAction:h1Action];
    [actionSheetController addAction:h2Action];
    [actionSheetController addAction:h8Action];
    [actionSheetController addAction:offAction];
    [actionSheetController addAction:cancelAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)windAction:(id)sender {
    UIAlertController *actionSheetController = [self actionSheetConroller:@"Wind"];
    
    __weak __typeof(self) weakSelf = self;

    UIAlertAction *autoAction = [UIAlertAction actionWithTitle:@"Auto" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] windVelocity:WindVelocityStateAuto deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *l1Action = [UIAlertAction actionWithTitle:@"Level1" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] windVelocity:WindVelocityStateL1 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *l2Action = [UIAlertAction actionWithTitle:@"Level2" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] windVelocity:WindVelocityStateL2 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *l3Action = [UIAlertAction actionWithTitle:@"Level3" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] windVelocity:WindVelocityStateL3 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Silence" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] windVelocity:WindVelocityStateSilence deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actionSheetController addAction:autoAction];
    [actionSheetController addAction:l1Action];
    [actionSheetController addAction:l2Action];
    [actionSheetController addAction:l3Action];
    [actionSheetController addAction:offAction];
    [actionSheetController addAction:cancelAction];

    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)anionAction:(id)sender {
    UIAlertController *actionSheetController = [self actionSheetConroller:@"Anion"];
    
    __weak __typeof(self) weakSelf = self;

    UIAlertAction *onAction = [UIAlertAction actionWithTitle:@"On" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] anionOn:1 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        NSString *did = [[NSUserDefaults standardUserDefaults] objectForKey:@"gDeviceID"];
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"gToken"];
        
        [[EHRemoteServerManager shareManager] anionOn:0 deviceID:did userToken:token completed:^(BOOL success, ZKDevice *device, NSError *error) {
            [weakSelf updateDeviceState:device];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [actionSheetController addAction:onAction];
    [actionSheetController addAction:offAction];
    [actionSheetController addAction:cancelAction];
    
    [self presentViewController:actionSheetController animated:YES completion:nil];
}

- (IBAction)qrButtonAction:(id)sender {
    
    CDZQRScanningViewController *scanningVC = [CDZQRScanningViewController new];
    UINavigationController *scanningNavVC = [[UINavigationController alloc] initWithRootViewController:scanningVC];
    
    __weak __typeof(self) weakSelf = self;

    scanningVC.resultBlock = ^(NSString *result) {
        
        weakSelf.macLabel.text = [NSString stringWithFormat:@"Mac:%@",result];
        
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"kMAC"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.cancelBlock = ^() {
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    scanningVC.errorBlock = ^(NSError *error) {
        [scanningNavVC dismissViewControllerAnimated:YES completion:nil];
    };
    
    scanningNavVC.modalPresentationStyle = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? UIModalPresentationFullScreen : UIModalPresentationFormSheet;
    [self presentViewController:scanningNavVC animated:YES completion:nil];
}

@end
