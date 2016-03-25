/********* PaystackPlugin.m Cordova Plugin Implementation *******/

#import "PaystackPlugin.h"
#import <Cordova/CDVPlugin.h>



@implementation PaystackPlugin

- (void)pluginInitialize
{
    NSLog(@"- PaystackPlugin pluginInitialize");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad) name:CDVPageDidLoadNotification object:nil];
    
}

- (void)pageDidLoad
{
    NSLog(@"- PaystackPlugin pageDidLoad");

    NSString* paystackPublishableKey = [self.commandDelegate.settings objectForKey:[@"publishableKey" lowercaseString]];
    [Paystack setDefaultPublishableKey:paystackPublishableKey];

    NSLog(@"publishableKey: %@", [self.commandDelegate.settings objectForKey:[@"publishableKey" lowercaseString]]);
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

- (BOOL)cardParamsAreValid:(NSString *)cardNumber withMonth:(NSString *)expMonth withYear:(NSString *)expYear andWithCvc:(NSString *)cvc
{
    if (! [self isCardNumberValid:cardNumber validateCardBrand:YES]) {
        self.errorMsg = @"Invalid card number.";
        self.errorCode = 421;
        return NO;
    }

    if (! [self isExpMonthValid:expMonth]) {
        self.errorMsg = @"Invalid expiration month.";
        self.errorCode = 424;
        return NO;
    }

    if (! [self isExpYearValid:expYear forMonth:expMonth]) {
        self.errorMsg = @"Invalid expiration year.";
        self.errorCode = 425;
        return NO;
    }

    if (! [self isCvcValid:cvc withNumber:cardNumber]) {
        self.errorMsg = @"Invalid cvc code.";
        self.errorCode = 423;
        return NO;
    }

    return YES;

}

- (void)getToken:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- PaystackPlugin getToken");
    
    // Check command.arguments here.
    NSString* rawNumber = [command.arguments objectAtIndex:0];
    NSString* rawExpMonth = [command.arguments objectAtIndex:1];
    NSString* rawExpYear = [command.arguments objectAtIndex:2];
    NSString* rawCvc = [command.arguments objectAtIndex:3];

    [self.commandDelegate runInBackground:^{
        // Build a resultset for javascript callback.
        __block CDVPluginResult* pluginResult = nil;

        if (! [self cardParamsAreValid:rawNumber withMonth:rawExpMonth withYear:rawExpYear andWithCvc:rawCvc]) {

            NSMutableDictionary *returnInfo = [self setErrorMsg:self.errorMsg withErrorCode:self.errorCode];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

        } else {
            PSTCKCardParams *cardParam = [[PSTCKCardParams alloc] init];
            cardParam.number = rawNumber;
            cardParam.expMonth = [rawExpMonth integerValue];
            cardParam.expYear = [rawExpYear integerValue];
            cardParam.cvc = rawCvc;

            if ([self isCardValid:cardParam]) {
                [[PSTCKAPIClient sharedClient] createTokenWithCard:cardParam completion:^(PSTCKToken *token, NSError *error) {
                    if (token) {
                        NSLog(@"- PaystackPlugin Token is set");
                        
                        NSMutableDictionary *returnInfo = [self setTokenMsg:token.tokenId withCardLastDigits:token.last4];
                        NSLog(@"token is set: %@", token.tokenId);
                        NSLog(@"token result: %@", returnInfo);

                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
                        NSLog(@"- PaystackPlugin pluginResult is set");
                    }

                    if (error) {
                        NSLog(@"- PaystackPlugin TokenError is set");
                        NSMutableDictionary *returnInfo = [self setErrorMsg:@"Error retrieving token for card." withErrorCode:401];

                        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
                    }
                }];
            } else {
                NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid Card." withErrorCode:404];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
            }

        
        }
        // The sendPluginResult method is thread-safe.
        if (pluginResult !== nil) {
            NSLog(@"- PaystackPlugin sendPluginResult");
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
       
    }];
}
@end