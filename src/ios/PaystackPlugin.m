/********* PaystackPlugin.m Cordova Plugin Implementation *******/

#import "PaystackPlugin.h"
#import <Cordova/CDVPlugin.h>



@implementation PaystackPlugin

- (void)pluginInitialize
{
    NSString* paystackPublishableKey = [self.commandDelegate.settings objectForKey:@"publishableKey"];
    [Paystack setDefaultPublishableKey:paystackPublishableKey];
}

- (BOOL)isCardNumberValid:(NSString *)cardNumber validateCardBrand:(BOOL)validateCardBrand
{
    BOOL isValid = ([PSTCKCardValidator validationStateForNumber:cardNumber validatingCardBrand:validateCardBrand] == PSTCKCardValidationStateValid);
    return isValid;
}

- (BOOL)isExpMonthValid:(NSString *)expMonth
{
    BOOL isValid = ([PSTCKCardValidator validationStateForExpirationMonth:expMonth] == PSTCKCardValidationStateValid);
    return isValid;
}

- (BOOL)isExpYearValid:(NSString *)expYear forMonth:(NSString *)expMonth
{
    BOOL isValid = ([PSTCKCardValidator validationStateForExpirationYear:expYear inMonth:expMonth] == PSTCKCardValidationStateValid);
    return isValid;
}

- (BOOL)isCvcValid:(NSString *)cvc withNumber:(NSString *)cardNumber
{
    BOOL isValid = ([PSTCKCardValidator validationStateForCVC:cvc cardBrand:[PSTCKCardValidator brandForNumber:cardNumber]] == PSTCKCardValidationStateValid);
    return isValid;
}

- (BOOL)isCardValid:(PSTCKCardParams *)card
{
    BOOL isValid = ([PSTCKCardValidator validationStateForCard:card] == PSTCKCardValidationStateValid);
    return isValid;
}

- (NSMutableDictionary*)setErrorMsg:(NSString *)errorMsg withErrorCode:(int)errorCode
{
    NSMutableDictionary *returnInfo;
    returnInfo = [NSMutableDictionary dictionaryWithCapacity:2];

    [returnInfo setObject:errorMsg forKey:@"error"];
    [returnInfo setObject:[NSNumber numberWithInt:errorCode] forKey:@"code"];

    return returnInfo;
}

- (NSMutableDictionary*)setTokenMsg:(NSString *)token withCardLastDigits:(NSString *)last4
{
    NSMutableDictionary *returnInfo;
    returnInfo = [NSMutableDictionary dictionaryWithCapacity:2];

    [returnInfo setObject:token forKey:@"token"];
    [returnInfo setObject:last4 forKey:@"last4"];

    return returnInfo;
}

- (void)getToken:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- PaystackPlugin getToken");

    // Build a resultset for javascript callback.
    CDVPluginResult* pluginResult = nil;
    
    // Check command.arguments here.
    NSString* rawNumber = [command.arguments objectAtIndex:0];
    NSString* rawExpMonth = [command.arguments objectAtIndex:1];
    NSString* rawExpYear = [command.arguments objectAtIndex:2];
    NSString* rawCvc = [command.arguments objectAtIndex:3];

    if (! [self isCardNumberValid:rawNumber validateCardBrand:YES]) {
        NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid card number" withErrorCode:421];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

    } else if (! [self isExpMonthValid:rawExpMonth]) {

        NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid expiration month." withErrorCode:424];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

    } else if (! [self isExpYearValid:rawExpYear forMonth:rawExpMonth]) {

        NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid expiration year." withErrorCode:425];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

    } else if (! [self isCvcValid:rawCvc withNumber:rawNumber]) {

        NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid cvc code." withErrorCode:423];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

    } else {
        PSTCKCardParams *cardParam = [[PSTCKCardParams alloc] init];
        cardParam.number = rawNumber;
        cardParam.expMonth = rawExpMonth;
        cardParam.expYear = rawExpYear;
        cardParam.cvc = rawCvc;

        if ([self isCardValid:cardParam]) {
            [[PSTCKAPIClient sharedClient] createTokenWithCard:cardParam completion:^(PSTCKToken *token, NSError *error) {
                if (token) {
                    NSMutableDictionary *returnInfo = [self setTokenMsg:token.tokenId withCardLastDigits:token.last4];

                    __block CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
                }

                if (error) {
                    NSMutableDictionary *returnInfo = [self setErrorMsg:@"Error retrieving token for card." withErrorCode:401];

                    __block CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
                }
            }];
        } else {
            NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid Card." withErrorCode:404];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
        }

        
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end