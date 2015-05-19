//
//  BTConnector.m
//  BLETool
//
//  Created by XPG on 15/4/9.
//  Copyright (c) 2015年 XPG. All rights reserved.
//

#import "BTConnector.h"
#import "JRBluetoothManager.h"

#define kNameWriteCharacteristic(periphralName) [NSString stringWithFormat:@"write_%@",periphralName]
#define kNameReadCharacteristic(periphralName) [NSString stringWithFormat:@"read_%@",periphralName]

static Byte const dataProductHead[] = {0x4b,0x5a,0x45,0x01,0x01};
static Byte const dataTempUnitCelsius = 0x0c;
static Byte const dataTempUnitFahrenheit = 0x0f;
static NSInteger const temperatureInUnit[2][14]    =  {
    {17,18,19,20,21,22,23,24,25,26,27,28,29,30},
    {62,64,66,68,70,72,74,76,76,78,80,82,84,86}
};

//static int const celsiusTemp[] = {};

/*======================================================
 BTStateInfo
 /======================================================*/
@implementation BTStateInfo

@end
/*======================================================
 BTConnector
 /======================================================*/

@interface BTConnector ()<JRBluetoothManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *periphralCharacteristicDicionary;

@end

@implementation BTConnector

+ (instancetype)shareManager {
    static BTConnector *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager =[[BTConnector alloc] init];
        
    });
    return shareManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [JRBluetoothManager shareManager].delegate  = self;
        _periphralCharacteristicDicionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Private

- (NSMutableData *)dataWithFuction:(BTFunctionIndex)fuc {
    
    Byte contentSample[] = {fuc,0x00,0x00,0x00}; // func, para, unit, 校验
    
    NSMutableData *sendData = [NSMutableData dataWithBytes:&dataProductHead length:5];
    [sendData appendBytes:&contentSample length:4];
    return sendData;
}

- (NSData *)checkSum:(NSMutableData *)data {
    
    Byte *sendByte = [data mutableBytes];
    Byte sum = 0x00;
    int dataLength = 9;
    for(int i = 0; i < dataLength-1; i++) {
        sum+= sendByte[i];
    }
    
    sendByte[dataLength-1] = sum%256;
    
    return [NSData dataWithBytes:sendByte length:dataLength];
}

- (void)sendDataToPeripheral:(NSData *)data {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendValueToBT object:data];
    
    [[JRBluetoothManager shareManager] writeData:data toPeriperalWithName:kPeriphralBroadcastName characteritic:self.periphralCharacteristicDicionary[kNameWriteCharacteristic(kPeriphralBroadcastName)] type:CBCharacteristicWriteWithoutResponse];
}

- (void)parseReceiveData:(NSData *)data {
    
    if (data.length < 3) {
        return;
    }
    
    Byte *parseData = (Byte *)[data bytes];
    int func = parseData[0];
    int arg = parseData[1];
    int extra = parseData[2];
    int color = parseData[3];
    
    BTStateInfo *stateInfo = [[BTStateInfo alloc] init];
    stateInfo.function = func;
    stateInfo.arg = arg;
    stateInfo.unit = extra;
    
    if ((func == BTFunctionIndexCharcoalColor && arg == 228) || (func == BTFunctionIndexFireColor && arg == 164)) {
        BTColor tempColor;
        switch (color) {
            case 1:
                tempColor = BTColorBlue;
                break;
            case 2:
                tempColor = BTColorPurple;
                break;
            case 3:
                tempColor = BTColorOrange;
                break;
            default:
                tempColor = 0;
                break;
        }
        stateInfo.color = tempColor;
    }
    
    if(_delegate && [_delegate respondsToSelector:@selector(didUpdateState:)]) {
        [_delegate didUpdateState:stateInfo];
    }
}

#pragma mark - Public

- (void)startScanPeripheral:(NSArray *)serviceUUIDs {
    [[JRBluetoothManager shareManager] startScanPeripherals:serviceUUIDs];
}

- (void)stopScanPeripheral {
    [[JRBluetoothManager shareManager] stopScanPeripherals];
}

- (BOOL)connectPeripheral:(CBPeripheral *)jrPeripheral {
    if (!jrPeripheral) {
        return NO;
    }
    [[JRBluetoothManager shareManager] connectPeripheral:jrPeripheral];
    return YES;
}

- (BOOL)cancelConnectPeripheral:(CBPeripheral *)jrPeripheral {
    if (!jrPeripheral) {
        return NO;
    }
    [[JRBluetoothManager shareManager] cancelConnectPeriphral:jrPeripheral];
    return YES;
}

- (void)noneButtonAction {
    
}

- (void)powerAction {
    NSData *powerData =  [self checkSum:[self dataWithFuction:BTFunctionIndexPower]];
    NSLog(@"powerAction %@",powerData);
    [self sendDataToPeripheral:powerData];
}

- (void)fireBrightnessAction {
    NSData *brightnessData = [self checkSum:[self dataWithFuction:BTFunctionIndexBrightness]];
    NSLog(@"fireBrightnessAction %@",brightnessData);
    [self sendDataToPeripheral:brightnessData];
}

- (void)heatingAction {
    NSData *heatingData = [self checkSum:[self dataWithFuction:BTFunctionIndexHeating]];
    NSLog(@"heatingAction %@",heatingData);
    [self sendDataToPeripheral:heatingData];
}

- (void)temperatureAction:(BTTempUnit)unit {
    NSMutableData *tempData = [self dataWithFuction:BTFunctionIndexTemp];
    
    NSData *sendTempData = [self checkSum:tempData];
    NSLog(@"temperatureAction %@",sendTempData);
    [self sendDataToPeripheral:sendTempData];
}

- (void)setTemperatureInCelsius:(NSInteger)temp {
    temp = MIN(30, temp);
    temp = MAX(17, temp);
    NSMutableData *tempData = [self dataWithFuction:BTFunctionIndexTemp];
    Byte tempValue = temp;
    Byte tempUnit = dataTempUnitCelsius;
    [tempData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&tempValue length:1];
    [tempData replaceBytesInRange:NSMakeRange(7, 1) withBytes:&tempUnit length:1];
    
    NSData *sendTempData = [self checkSum:tempData];
    NSLog(@"setTemperatureInCelsius %@",sendTempData);
    [self sendDataToPeripheral:sendTempData];
}

- (void)setTemperatureInFahrenheit:(NSInteger)temp {
    temp = MIN(86, temp);
    temp = MAX(62, temp);
    NSMutableData *tempData = [self dataWithFuction:BTFunctionIndexTemp];
    Byte tempValue = temp;
    Byte tempUnit = dataTempUnitFahrenheit;
    [tempData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&tempValue length:1];
    [tempData replaceBytesInRange:NSMakeRange(7, 1) withBytes:&tempUnit length:1];
    
    NSData *sendTempData = [self checkSum:tempData];
    NSLog(@"setTemperatureInCelsius %@",sendTempData);
    [self sendDataToPeripheral:sendTempData];
}

- (void)changeUnitWithImageIndex:(NSInteger)imageIndex toUnit:(BTTempUnit)unit {
   
    imageIndex = MIN(13, imageIndex);
    
    if (unit == BTTempUnitCelsius) {
        
        NSInteger targetTemp = temperatureInUnit[0][imageIndex];
        [self setTemperatureInCelsius:targetTemp];
    }else if(unit == BTTempUnitFahrenheit) {
        
        NSInteger targetTemp = temperatureInUnit[1][imageIndex];
        [self setTemperatureInFahrenheit:targetTemp];
    }
}

- (void)setWorkingTime:(NSInteger)time {
    time = MIN(8, time);
    time = MAX(0, time);
    NSMutableData *timeData = [self dataWithFuction:BTFunctionIndexTime];
    Byte workingTime = time;
    [timeData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&workingTime length:1];

    NSData *sendTimeData = [self checkSum:timeData];
    NSLog(@"setWorkingTime %@",sendTimeData);
    [self sendDataToPeripheral:sendTimeData];
}

- (void)workingTimeAction {
    NSMutableData *timeData = [self dataWithFuction:BTFunctionIndexTime];
    Byte workingTime = 0x64;
    [timeData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&workingTime length:1];

    NSData *sendTimeData = [self checkSum:timeData];
    NSLog(@"workingTimeAction %@",sendTimeData);
    [self sendDataToPeripheral:sendTimeData];
}

- (void)charcoalColorAction {
    NSData *charcoalColorData = [self checkSum:[self dataWithFuction:BTFunctionIndexCharcoalColor]];
    NSLog(@"charcoalColorAction %@",charcoalColorData);
    [self sendDataToPeripheral:charcoalColorData];
}

- (void)fireColorAction {
    NSData *fireColorData = [self checkSum:[self dataWithFuction:BTFunctionIndexFireColor]];
    NSLog(@"fireColorAction %@",fireColorData);
    [self sendDataToPeripheral:fireColorData];
}

- (void)sendPairingAction:(BOOL)firstTime {
    NSMutableData *pairingData = [self dataWithFuction:BTFunctionIndexPairing];
    Byte firstFlag = firstTime? 0x00 : 0x01;
    [pairingData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&firstFlag length:1];
    NSData *addCheckSumData = [self checkSum:pairingData];
    NSLog(@"sendPairingAction %@",addCheckSumData);
    [self sendDataToPeripheral:addCheckSumData];
}

- (void)heatingWithLock:(BOOL)lock {
    NSMutableData *lockData = [self dataWithFuction:BTFunctionIndexLock];
    Byte lockFlag = lock ? 0x01 : 0x00;
    [lockData replaceBytesInRange:NSMakeRange(6, 1) withBytes:&lockFlag length:1];
    NSData *addCheckSumData = [self checkSum:lockData];
    NSLog(@"lockAction %@",addCheckSumData);
    [self sendDataToPeripheral:addCheckSumData];
}

#pragma mark - JRBluetoothManagerDelegate

- (void)didUpdateState:(CBCentralManagerState)state {
    
    if (_delegate && [_delegate respondsToSelector:@selector(didBLEUpdateState:)]) {
        [_delegate didBLEUpdateState:state];
    }
    
}

- (void)didFoundPeripheral:(CBPeripheral *)peripheral {
    if (_delegate && [_delegate respondsToSelector:@selector(didFoundPeripheral:)]) {
        [_delegate didFoundPeripheral:peripheral];
    }
}

- (void)didConnectPeriphral:(CBPeripheral *)periphral {
//    if (_delegate && [_delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
//        
//        [_delegate didConnectPeripheral:periphral];
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetValueFromBT object:@"连接成功"];
}

- (void)didFailToConnectPeriphral:(CBPeripheral *)periphral {
    if (_delegate && [_delegate respondsToSelector:@selector(didFailToConnectPeripheral:)]) {
        [_delegate didFailToConnectPeripheral:periphral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetValueFromBT object:@"连接失败"];
}

- (void)didDisconnectPeriphral:(CBPeripheral *)periphral {
    if (_delegate && [_delegate respondsToSelector:@selector(didDisconnectPeripheral:)]) {
        [_delegate didDisconnectPeripheral:periphral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetValueFromBT object:@"连接断开"];
}

- (void)didDiscoverCharacteristicOfService:(CBService *)service fromPeriperal:(CBPeripheral *)periphral {
    
    NSLog(@"============ service ============");
    NSLog(@"servie: %@", [service.UUID UUIDString]);
    
    if ([[service.UUID UUIDString] isEqualToString:kUUIDService]) {

        for(CBCharacteristic *characteristic in service.characteristics) {
            
            if ([[characteristic.UUID UUIDString] isEqualToString:kUUIDCharacteristicNotify]) {
                NSLog(@"get notify characteristic");
                [periphral setNotifyValue:YES forCharacteristic:characteristic];
                [self.periphralCharacteristicDicionary setObject:characteristic forKey:kNameReadCharacteristic(kPeriphralBroadcastName)];
                
            }else if([[characteristic.UUID UUIDString] isEqualToString:kUUIDCharacteristicWrite]) {
                NSLog(@"get write characteristic");
                [self.periphralCharacteristicDicionary setObject:characteristic forKey:kNameWriteCharacteristic(kPeriphralBroadcastName)];
            }
        }
        
        if (self.periphralCharacteristicDicionary.count == 2) {
            if (_delegate && [_delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
                [_delegate didConnectPeripheral:periphral];
            }
        }
    }
}

- (void)didUpdateValue:(NSData *)data fromPeripheral:(CBPeripheral *)peripheral characteritic:(CBCharacteristic *)characteristic {
    
//    NSLog(@"============ didUpdateValue ============");
    NSLog(@"data length:%d",[data length]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGetValueFromBT object:data];

    if ([[characteristic.UUID UUIDString] isEqualToString:kUUIDCharacteristicNotify]) {
        
        if (data.length < 9) {
            return;
        }
        
        NSData *headData = [NSData dataWithBytes:&dataProductHead length:5];
        NSData *receiveDataHead = [data subdataWithRange:NSMakeRange(0, 5)];
        
        if ([headData isEqualToData:receiveDataHead]) {
            NSData *contentData = [data subdataWithRange:NSMakeRange(5, 3)];
            [self parseReceiveData:contentData];
        }
    }
    
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic inPeripheral:(CBPeripheral *)peripheral {

}



@end
