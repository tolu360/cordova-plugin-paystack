/********* PaystackPlugin.m Cordova Plugin Implementation *******/

#import "PaystackPlugin.h"
#import <Cordova/CDVPlugin.h>


@implementation PaystackPlugin

- (void)pluginInitialize
{
    NSString* paystackPublishableKey = [self.commandDelegate.settings objectForKey:@"publishableKey"];
    [Paystack setDefaultPublishableKey:paystackPublishableKey];
}

- (void)getToken:(CDVInvokedUrlCommand*)command
{
    // [cardNumber, expiryMonth, expiryYear, cvc]
    
    // Check command.arguments here.
    [self.commandDelegate runInBackground:^{
        NSString* rawNumber = [command.arguments objectAtIndex:0];
        NSString* rawExpMonth = [command.arguments objectAtIndex:1];
        NSString* rawExpYear = [command.arguments objectAtIndex:2];
        NSString* rawCvc = [command.arguments objectAtIndex:3];
        NSError* outError = nil;

        NSLog(@"cardNumber passed: %@", rawNumber);

        PSTCKCardParams *cardParam = [[PSTCKCardParams alloc] init];
        PSTCKCard *card = [[PSTCKCard alloc] init];
        // card.number = nil;
        // card.cvc = nil;
        // card.expMonth = nil;
        // card.expYear =

        if (! [cardParam validateNumber:rawNumber:outError]) {
            // Create an object that will be serialized into a JSON object.
            // This object contains the date String contents and a success property.
            NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         @"Invalid card number", @"error",
                                         421, @"code",
                                         nil
                                    ];
            
            // Create an instance of CDVPluginResult, with an OK status code.
            // Set the return message as the Dictionary object (jsonObj)...
            // ... to be serialized as JSON in the browser
            CDVPluginResult *pluginResult = [ CDVPluginResult
                                              resultWithStatus    : CDVCommandStatus_ERROR
                                              messageAsDictionary : jsonObj
                                            ];
        }

        // number, cvc, expMonth, expYear
        card.number = rawNumber;

        if (! [cardParam validateCvc:rawCvc:outError]) {
            NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         @"Invalid cvc", @"error",
                                         423, @"code",
                                         nil
                                    ];
            
            CDVPluginResult *pluginResult = [ CDVPluginResult
                                              resultWithStatus    : CDVCommandStatus_ERROR
                                              messageAsDictionary : jsonObj
                                            ];
        }

        card.cvc = rawCvc;

        if (! [cardParam validateExpMonth:rawCvc:outError]) {
            NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         @"Invalid expiry month", @"error",
                                         424, @"code",
                                         nil
                                    ];
            
            CDVPluginResult *pluginResult = [ CDVPluginResult
                                              resultWithStatus    : CDVCommandStatus_ERROR
                                              messageAsDictionary : jsonObj
                                            ];
        }

        card.expMonth = rawExpMonth;

        if (! [cardParam validateExpYear:rawCvc:outError]) {
            NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         @"Invalid expiry year", @"error",
                                         425, @"code",
                                         nil
                                    ];
            
            CDVPluginResult *pluginResult = [ CDVPluginResult
                                              resultWithStatus    : CDVCommandStatus_ERROR
                                              messageAsDictionary : jsonObj
                                            ];
        }

        card.expYear = rawExpYear;

        [[PSTCKAPIClient sharedClient] createTokenWithCard:card resultHandler:^(token, error) {
            if (token) {
                NSLog(@"Token obtained successfully: %@", token);

                NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         token.token, @"token",
                                         token.last4, @"last4",
                                         nil
                                    ];
            
                CDVPluginResult *pluginResult = [ CDVPluginResult
                                                  resultWithStatus    : CDVCommandStatus_OK
                                                  messageAsDictionary : jsonObj
                                                ];
            }

            if (error) {
                NSLog(@"Token not obtained successfully: %@", error);

                NSDictionary *jsonObj = [ [NSDictionary alloc]
                                       initWithObjectsAndKeys :
                                         error.description, @"error",
                                        401, @"code",
                                         nil
                                    ];
            
                CDVPluginResult *pluginResult = [ CDVPluginResult
                                                  resultWithStatus    : CDVCommandStatus_ERROR
                                                  messageAsDictionary : jsonObj
                                                ];
            }
        }];

        
        // The sendPluginResult method is thread-safe.
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end