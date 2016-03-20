/********* PaystackPlugin.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>
#import <Paystack/Paystack.h>

@interface PaystackPlugin : CDVPlugin

- (void)pluginInitialize;
+ (BOOL)isCardNumberValid:(nonnull NSString *)cardNumber validateCardBrand:(BOOL)validateCardBrand;
+ (BOOL)isExpMonthValid:(nonnull NSString *)expMonth;
+ (BOOL)isExpYearValid:(nonnull NSString *)expYear forMonth:(NSString *)expMonth;
+ (BOOL)isCvcValid:(nonnull NSString *)cvc withNumber:(NSString *)cardNumber;
+ (BOOL)isCardValid:(nonnull PSTCKCardParams *)card;
- (NSMutableDictionary*)setErrorMsg:(NSString *)errorMsg withErrorCode:(NSNumber *)errorCode;
- (NSMutableDictionary*)setTokenMsg:(NSString *)token withCardLastDigits:(NSString *)last4;
- (void)getToken:(CDVInvokedUrlCommand*)command;

@end