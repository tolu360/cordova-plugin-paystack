/********* PaystackPlugin.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>
@import Paystack;

@interface PaystackPlugin : CDVPlugin

- (void)pluginInitialize;
- (void)getToken:(CDVInvokedUrlCommand*)command;

@end