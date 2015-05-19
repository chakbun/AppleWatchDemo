//
//  BoilerController.m
//  ZKWatchDemo
//
//  Created by Jaben on 15/5/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "BoilerController.h"
#import "BTConnector.h"

@interface BoilerController ()<BTConnectorDelegate>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (nonatomic, strong) CBPeripheral *targetPeripheral;

@end

@implementation BoilerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Button Action

- (IBAction)connectAction:(id)sender {
    [[BTConnector shareManager] connectPeripheral:self.targetPeripheral];

}

- (IBAction)disconnectAction:(id)sender {
    
}

- (IBAction)powerAction:(id)sender {
    [[BTConnector shareManager] powerAction];

}

- (IBAction)fireBrightnessAction:(id)sender {
    [[BTConnector shareManager] fireBrightnessAction];

}

- (IBAction)heatingAction:(id)sender {
    [[BTConnector shareManager] heatingAction];

}

- (IBAction)temperAction:(id)sender {
    BTTempUnit unit = BTTempUnitCelsius;
    [[BTConnector shareManager] temperatureAction:unit];
}

- (IBAction)fireColorAction:(id)sender {
    [[BTConnector shareManager] fireColorAction];

}

- (IBAction)pairAction:(id)sender {
    [[BTConnector shareManager] sendPairingAction:YES];

}

- (IBAction)charColorAction:(id)sender {
    [[BTConnector shareManager] charcoalColorAction];

}

- (IBAction)clearLogAction:(id)sender {
    self.logTextView.text = @"";
}

#pragma mark - BtConnector Delegate

- (void)didBLEUpdateState:(CBCentralManagerState)state {
    if (state == CBCentralManagerStatePoweredOn) {
        [[BTConnector shareManager] startScanPeripheral:nil];
    }
}

- (void)didFoundPeripheral:(CBPeripheral *)jrPeripheral {
    NSLog(@"name: %@",jrPeripheral.name);
    if ([jrPeripheral.name containsString:kPeriphralBroadcastName]) {
        [[BTConnector shareManager] stopScanPeripheral];
        self.targetPeripheral = jrPeripheral;
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)didFailToConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)didUpdateState:(BTStateInfo *)stateInfo {
    
}

@end
