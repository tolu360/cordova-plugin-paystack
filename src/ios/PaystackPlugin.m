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

    NSString* paystackPublicKey = [self.commandDelegate.settings objectForKey:[@"publicKey" lowercaseString]];
    [Paystack setDefaultPublicKey:paystackPublicKey];

    NSLog(@"publicKey: %@", [self.commandDelegate.settings objectForKey:[@"publicKey" lowercaseString]]);
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

- (NSMutableDictionary*)setReferenceMsg:(NSString *)reference
{
    NSMutableDictionary *returnInfo;
    returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];

    [returnInfo setObject:reference forKey:@"reference"];

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

- (void)chargeCard:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- PaystackPlugin chargeCard");
    
    // Check command.arguments here.
    NSDictionary* params = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
        // Build a resultset for javascript callback.
        __block CDVPluginResult* pluginResult = nil;

        if (! [self cardParamsAreValid:params[@"cardNumber"] withMonth:params[@"expiryMonth"] withYear:params[@"expiryYear"] andWithCvc:params[@"cvc"]]) {

            NSMutableDictionary *returnInfo = [self setErrorMsg:self.errorMsg withErrorCode:self.errorCode];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

        } else {
            UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController]; 

            PSTCKCardParams *cardParams = [[PSTCKCardParams alloc] init];
            cardParams.number = params[@"cardNumber"];
            cardParams.expMonth = [params[@"expiryMonth"] integerValue];
            cardParams.expYear = [params[@"expiryYear"] integerValue];
            cardParams.cvc = params[@"cvc"];

            PSTCKTransactionParams *transactionParams = [[PSTCKTransactionParams alloc] init];
            transactionParams.amount = [params[@"amountInKobo"] integerValue];
            transactionParams.email = params[@"email"];

            if (params[@"currency"] != nil) {
                transactionParams.currency = params[@"currency"];
            }

            if (params[@"plan"] != nil) {
                transactionParams.plan = params[@"plan"];
            }            

            if (params[@"subAccount"] != nil) {
                transactionParams.subaccount = params[@"subAccount"];

                if (params[@"bearer"] != nil) {
                    transactionParams.bearer = params[@"bearer"];
                }

                if (params[@"transactionCharge"] != nil) {
                    transactionParams.transaction_charge = [params[@"transactionCharge"] integerValue];
                }
            }

            if (params[@"reference"] != nil) {
                transactionParams.reference = params[@"reference"];
            }

            if ([self isCardValid:cardParams]) {

                [[PSTCKAPIClient sharedClient] chargeCard:cardParams
                               forTransaction:transactionParams
                            onViewController:rootViewController
                              didEndWithError:^(NSError *error, NSString *reference){
                                                NSLog(@"- PaystackPlugin ChargeError is set");
                                                NSMutableDictionary *returnInfo = [self setErrorMsg:@"Error charging card." withErrorCode:401];

                                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

                                                if (pluginResult != nil) {
                                                    NSLog(@"- PaystackPlugin sendPluginResult");
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                                            }
                         didRequestValidation: ^(NSString *reference){
                                                // an OTP was requested, transaction has not yet succeeded
                                                NSLog(@"- PaystackPlugin: an OTP was requested, transaction has not yet succeeded");
                                            }
                        didTransactionSuccess: ^(NSString *reference){
                                                // transaction may have succeeded, please verify on server
                                                NSLog(@"- PaystackPlugin: transaction may have succeeded, please verify on server");
                                                NSMutableDictionary *returnInfo = [self setReferenceMsg:reference];

                                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];

                                                if (pluginResult != nil) {
                                                    NSLog(@"- PaystackPlugin sendPluginResult");
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                }];
            } else {
                NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid Card." withErrorCode:404];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
            }

        
        }
        // The sendPluginResult method is thread-safe.
        if (pluginResult != nil) {
            NSLog(@"- PaystackPlugin sendPluginResult");
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
       
    }];
}

- (void)chargeCardWithAccessCode:(CDVInvokedUrlCommand*)command
{
    NSLog(@"- PaystackPlugin chargeCardWithAccessCode");
    
    // Check command.arguments here.
    NSDictionary* params = [command.arguments objectAtIndex:0];

    [self.commandDelegate runInBackground:^{
        // Build a resultset for javascript callback.
        __block CDVPluginResult* pluginResult = nil;

        if (! [self cardParamsAreValid:params[@"cardNumber"] withMonth:params[@"expiryMonth"] withYear:params[@"expiryYear"] andWithCvc:params[@"cvc"]]) {

            NSMutableDictionary *returnInfo = [self setErrorMsg:self.errorMsg withErrorCode:self.errorCode];

            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

        } else {
            UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController]; 

            PSTCKCardParams *cardParams = [[PSTCKCardParams alloc] init];
            cardParams.number = params[@"cardNumber"];
            cardParams.expMonth = [params[@"expiryMonth"] integerValue];
            cardParams.expYear = [params[@"expiryYear"] integerValue];
            cardParams.cvc = params[@"cvc"];

            PSTCKTransactionParams *transactionParams = [[PSTCKTransactionParams alloc] init];
            transactionParams.access_code = params[@"accessCode"];

            if ([self isCardValid:cardParams]) {

                [[PSTCKAPIClient sharedClient] chargeCard:cardParams
                               forTransaction:transactionParams
                            onViewController:rootViewController
                              didEndWithError:^(NSError *error, NSString *reference){
                                                NSLog(@"- PaystackPlugin ChargeError is set");
                                                NSMutableDictionary *returnInfo = [self setErrorMsg:@"Error charging card." withErrorCode:401];

                                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];

                                                if (pluginResult != nil) {
                                                    NSLog(@"- PaystackPlugin sendPluginResult");
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                                            }
                         didRequestValidation: ^(NSString *reference){
                                                // an OTP was requested, transaction has not yet succeeded
                                                NSLog(@"- PaystackPlugin: an OTP was requested, transaction has not yet succeeded");
                                            }
                        didTransactionSuccess: ^(NSString *reference){
                                                // transaction may have succeeded, please verify on server
                                                NSLog(@"- PaystackPlugin: transaction may have succeeded, please verify on server");
                                                NSMutableDictionary *returnInfo = [self setReferenceMsg:reference];

                                                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];

                                                if (pluginResult != nil) {
                                                    NSLog(@"- PaystackPlugin sendPluginResult");
                                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                                }
                }];
            } else {
                NSMutableDictionary *returnInfo = [self setErrorMsg:@"Invalid Card." withErrorCode:404];

                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
            }

        
        }
        // The sendPluginResult method is thread-safe.
        if (pluginResult != nil) {
            NSLog(@"- PaystackPlugin sendPluginResult");
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
       
    }];
}

@end