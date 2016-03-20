/********* PaystackPlugin.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>
#import <Paystack/Paystack.h>
// #import Paystack.h

@interface PaystackPlugin : CDVPlugin

- (void)pluginInitialize;
- (BOOL)isCardNumberValid:(NSString *)cardNumber validateCardBrand:(BOOL)validateCardBrand;
- (BOOL)isExpMonthValid:(NSString *)expMonth;
- (BOOL)isExpYearValid:(NSString *)expYear forMonth:(NSString *)expMonth;
- (BOOL)isCvcValid:(NSString *)cvc withNumber:(NSString *)cardNumber;
- (BOOL)isCardValid:(PSTCKCardParams *)card;
- (NSMutableDictionary*)setErrorMsg:(NSString *)errorMsg withErrorCode:(int)errorCode;
- (NSMutableDictionary*)setTokenMsg:(NSString *)token withCardLastDigits:(NSString *)last4;
- (void)getToken:(CDVInvokedUrlCommand*)command;

@end