/********* PaystackPlugin.h Cordova Plugin Header *******/

#import <Cordova/CDVPlugin.h>
#import <Paystack/Paystack.h>
// #import Paystack.h

@interface PaystackPlugin : CDVPlugin

@property (nonatomic) NSString *errorMsg;
@property (nonatomic) int errorCode;

- (void)pluginInitialize;
- (void)pageDidLoad;
- (BOOL)isCardNumberValid:(NSString *)cardNumber validateCardBrand:(BOOL)validateCardBrand;
- (BOOL)isExpMonthValid:(NSString *)expMonth;
- (BOOL)isExpYearValid:(NSString *)expYear forMonth:(NSString *)expMonth;
- (BOOL)isCvcValid:(NSString *)cvc withNumber:(NSString *)cardNumber;
- (BOOL)isCardValid:(PSTCKCardParams *)card;
- (BOOL)cardParamsAreValid:(NSString *)cardNumber withMonth:(NSString *)expMonth withYear:(NSString *)expYear andWithCvc:(NSString *)cvc;
- (NSMutableDictionary*)setErrorMsg:(NSString *)errorMsg withErrorCode:(int)errorCode;
- (NSMutableDictionary*)setTokenMsg:(NSString *)token withCardLastDigits:(NSString *)last4;
- (void)getToken:(CDVInvokedUrlCommand*)command;

@end