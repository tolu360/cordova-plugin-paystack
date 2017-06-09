# Cordova/PhoneGap Wrapper for Paystack SDK

for Android & iOS by [Arttitude 360](http://www.arttitude360.com)

## Index

1. [Description](#1-description)
2. [Installation](#3-installation)
	3. [Automatically (CLI / Plugman)](#automatically-cli--plugman)
	3. [Manually](#manually)
	3. [PhoneGap Build](#phonegap-build)
3. [Usage](#3-usage)
4. [Credits](#4-credits)
5. [Changelog](#5-changelog)
6. [License](#6-license)

## 1. Description

This plugin allows to add Paystack Payments to your application using the [Paystack Mobile Android SDK](https://github.com/PaystackHQ/paystack-android) and the [Paystack Mobile iOS SDK](https://github.com/PaystackHQ/paystack-ios) libraries. 
While there are a million ways to build mobile applications these days, there are only very few ways to stay secure. The native Paystack SDK uses your pulishable/public key to generate a one-time token to be used to charge a card (on your backend/server) - this plugin allows you to do all that in your Cordova/PhoneGap app without worrying about your secret key being compromised. Your secret keys do not belong in version control and you should never use them in client-side code or in a Cordova/PhoneGap application.
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman).
* Officially supported by [PhoneGap Build](https://build.phonegap.com/plugins).

## 2. Installation

### Automatically (CLI / Plugman)
PaystackPlugin is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman), compatible with [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

Using the Cordova CLI and the [Cordova Plugin Registry](http://plugins.cordova.io)
```
$ cordova plugin add cordova-plugin-paystack
```

Or directly from the repo (most especially if you run into any issues building for IOS with the command above)
```
$ cordova plugin add https://github.com/tolu360/cordova-plugin-paystack
```


### << --- Fixing Build Errors [iOS]

****Installing this plugin directly from Cordova Registry results in Xcode using a broken `Paystack.framework`, this may be because the current publish procedure to NPM breaks symlinks [CB-6092](https://issues.apache.org/jira/browse/CB-6092). Please install the plugin with `$ cordova plugin add https://github.com/tolu360/cordova-plugin-paystack` OR through a locally cloned copy OR replace the `Paystack.framework` file found at `~PROJECT_FOLDER/platforms/ios/PROJECT_ID/Plugins/cordova-plugin-paystack` with the clean copy you should download and extract from their [releases page on Github](https://github.com/PaystackHQ/paystack-ios/releases/) after installation.****

****For Android Builds, have the following on your local build environment:
Android SDK Tools: 25+
Android SDK Platform-tools: 25+
Android SDK Build-tools: 25+
SDK Platform: 25+
Android Support Repository: 39+

### ------------------------------------------ >>

Or using the phonegap CLI
```
$ phonegap local plugin add cordova-plugin-paystack
```

PaystackPlugin.js is brought in automatically. There is no need to change or add anything in your html.

To build for Android, add ` xmlns:android="http://schemas.android.com/apk/res/android"` to the `widget` tag of the `config.xml` file in the root of your project, while at it, include the following lines within a `platform` `(<platform name="android">)`tag in your `config.xml`:

```xml
<platform name="android">
    ...
    <preference name="android-minSdkVersion" value="16" />
    <config-file target="AndroidManifest.xml" parent="application">
      	<meta-data android:name="co.paystack.android.PublicKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
    </config-file>
</platform>
```

To build for iOS, add the `publicKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<platform name="ios">
    ...
    <preference name="publicKey" value="INSERT-PUBLIC-KEY-HERE" />
</platform>
```
You must not forget to build your project again - each time you edit native code. Run `cordova build ios/android` or similar variants.

### Manually
You'd better use the CLI, but here goes:

1\. Add the following xml to your `config.xml` in the root directory of your application:

```xml
<!-- for Android -->
<feature name="PaystackPlugin">
  <param name="android-package" value="com.arttitude360.cordova.PaystackPlugin" />
</feature>
```


2\. Grab a copy of PaystackPlugin.js, add it to your project and reference it in `index.html`:
```html
<script type="text/javascript" src="js/PaystackPlugin.js"></script>
```

3\. Download the source files and copy them to your project.

Android: Copy `PaystackPlugin.java` to `platforms/android/src/com/arttitude360/cordova` (create the folders)

To build for Android, add ` xmlns:android="http://schemas.android.com/apk/res/android"` to the `widget` tag of the `config.xml` file in the root of your project, while at it, include the following lines within a `platform` `(<platform name="android">)`tag in your `config.xml`:

```xml
<platform name="android">
	<preference name="android-minSdkVersion" value="16" />
    <config-file target="AndroidManifest.xml" parent="application">
      	<meta-data android:name="co.paystack.android.PublicKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
    </config-file>
</platform>
```

To build for iOS, add the `publicKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<platform name="ios">
    ...
    <preference name="publicKey" value="INSERT-PUBLIC-KEY-HERE" />
</platform>
```


### PhoneGap Build

PaystackPlugin works with PhoneGap build too, but only with PhoneGap 3.0 and up.

Just add the following xml to your `config.xml` to always use the latest version of this plugin:
```xml
<gap:plugin name="cordova-plugin-paystack" source="npm" />
```

PaystackPlugin.js is brought in automatically. There is no need to change or add anything in your html.

To build for Android, add ` xmlns:android="http://schemas.android.com/apk/res/android"` to the `widget` tag of the `config.xml` file in the root of your project, while at it, include the following lines within a `platform` `(<platform name="android">)`tag in your `config.xml`:

```xml
<platform name="android">
    <config-file target="AndroidManifest.xml" parent="application">
      	<meta-data android:name="co.paystack.android.PublicKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
    </config-file>
</platform>
```

To build for iOS, add the `publicKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<preference name="publicKey" value="INSERT-PUBLIC-KEY-HERE" />
```

## 3. Usage

### Charging a Card with Access Code (iOS & Android)
- Note: If you are working with XCode 8+, to allow encryptions work properly with the Paystack SDK, you may need to enable `Keychain Sharing` for your app. In the Capabilities pane, if Keychain Sharing isn’t enabled, toggle ON the switch in the Keychain Sharing section.

<img width=400 title="XCode files tree" src="./4_enablekeychain_2x.png">

It's a cinch to charge a card with the Paystack SDKs using the PaystackPlugin. This is the recommended or the most-preferred workflow favored by the folks at Paystack. Initiate a new transaction on your server side using the appropriate [Paystack endpoint](https://developers.paystack.co/reference#initialize-a-transaction) - obtain an `access_code` and complete the charge on your mobile application. Like most Cordova/PhoneGap plugins, use the PaystackPlugin after the `deviceready` event is fired:

```js
window.PaystackPlugin.chargeCardWithAccessCode(successCallbackfn, failureCallbackfn, cardParams);
```
To be more elaborate, `cardParams` is a Javascript `Object` representing the card to be tokenized.

```js
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
    // Now safe to use device APIs
    window.PaystackPlugin.chargeCardWithAccessCode(
      function(resp) {
        // A valid one-timme-use token is obtained, do your thang!
        console.log('charge successful: ', resp);
      },
      function(resp) {
        // Something went wrong, oops - perhaps an invalid card.
        console.log('charge failed: ', resp);
      },
      {
        cardNumber: '4123450131001381', 
        expiryMonth: '10', 
        expiryYear: '17', 
        cvc: '883',
        accessCode: '2p3j42th639duy4'
    });
}
```

You must not forget to build your project again - each time you edit native code. Run `cordova build ios/android` or similar variants.

Explaining the arguments to `window.PaystackPlugin.chargeCardWithAccessCode`:

| Argument        | Type           | Description  |
| ------------- |:-------------:| :-----|
| cardNumber          | string | the card number as a String without any seperator e.g 5555555555554444 |
| expiryMonth      | string      | the card expiry month as a double-digit ranging from 1-12 e.g 10 (October) |
| expiryYear | string      | the card expiry year as a double-digit e.g 15 |
| cvc | string | the card 3/4 digit security code as a String e.g 123 |
| accessCode | string | the access_code obtained for the charge |

#### Response Object

An object of the form is returned from a successful token request

```javascript
{
  reference: "trx_1k2o600w"
}
```

### Charging a Card (iOS & Android)
You can start and complete a transaction using just the Paystack Mobile SDKs. With this option, you pass both your charge and card properties to the SDK - with this worklow, you initiate and complete a transaction on your mobile app. Like most Cordova/PhoneGap plugins, use the PaystackPlugin after the `deviceready` event is fired:

```js
window.PaystackPlugin.chargeCard(successCallbackfn, failureCallbackfn, chargeParams);
```
To be more elaborate, `chargeParams` is a Javascript `Object` representing the parameters of the charge to be initiated.

```js
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
    // Now safe to use device APIs
    window.PaystackPlugin.chargeCard(
      function(resp) {
        // charge successful, grab transaction reference - do your thang!
        console.log('charge successful: ', resp);
      },
      function(resp) {
        // Something went wrong, oops - perhaps an invalid card.
        console.log('charge failed: ', resp);
      },
      {
        cardNumber: '4123450131001381', 
        expiryMonth: '10', 
        expiryYear: '17', 
        cvc: '883',
        email: 'chargeIOS@master.dev',
        amountInKobo: 150000,
        subAccount: 'ACCT_pz61jjjsslnx1d9',
    });
}
```

You must not forget to build your project again - each time you edit native code. Run `cordova build ios/android` or similar variants to refresh your cached html/js views.

#### Request Signature

| Argument        | Type           | Description  |
| ------------- |:-------------:| :-----|
| cardNumber          | string | the card number as a String without any seperator e.g 5555555555554444 |
| expiryMonth      | string      | the card expiry month as a double-digit ranging from 1-12 e.g 10 (October) |
| expiryYear | string      | the card expiry year as a double-digit e.g 15 |
| cvc | string | the card 3/4 digit security code as e.g 123 |
| email | string | email of the user to be charged |
| amountInKobo | integer | the transaction amount in kobo |
| currency (optional) | string | sets the currency for the transaction e.g. USD |
| plan (optional) | string | sets the plan ID if the transaction is to create a subscription e.g. PLN_n0p196bg73y4jcx |
| subAccount (optional) | string | sets the subaccount ID for split-payment transactions e.g. ACCT_pz61jjjsslnx1d9 |
| transactionCharge (optional) | integer | the amount to be charged on a split-payment, use only when `subAccount` is set |
| bearer (optional) | string | sets which party bears paystack fees on a split-payment e.g. 'subaccount', use only when `subAccount` is set |
| reference (optional) | string | sets the transaction reference which must be unique per transaction |

#### Response Object

An object of the form is returned from a successful charge

```javascript
{
  reference: "trx_1k2o600w"
}
```

### Verifying a Charge
Verify a charge by calling Paystack's [REST API](https://api.paystack.co/transaction/verify) with the `reference` obtained above. An `authorization_code` will be returned once the card has been charged successfully. Learn more about that [here](https://developers.paystack.co/docs/verify-transaction).

 **Parameter:** 

 - reference  - the transaction reference (required)

 **Example**

 ```bash
 $ curl https://api.paystack.co/transaction/verify/trx_1k2o600w \
    -H "Authorization: Bearer SECRET_KEY" \
    -H "Content-Type: application/json" \
    -X GET
 ```


## 4. CREDITS

This plugin uses the [cordova-custom-config plugin](https://github.com/dpa99c/cordova-custom-config) to achieve easy and reversible changes to your application's `AndroidManifest.xml` file.
Perhaps needless to say, this plugin leverages the [Paystack Android SDK](https://github.com/PaystackHQ/paystack-android) and the [Paystack iOS SDK](https://github.com/PaystackHQ/paystack-ios) for all the heavy liftings.

## 5. CHANGELOG

- 1.0.1: Initial version supporting Android.
- 1.0.3: Code clean up and addition of arbitrary error codes.
- 1.1.0: Added iOS support and bumped up Paystack Android library to v1.2, making 16 the min sdk you should target.
- 2.0.0: No breaking changes at this time. Added `android-minSdkVersion=16` condition to Android builds. Added `chargeCard` method to Android APIs. Upgrade to v2.* of the Paystack Android SDK.
- 2.1.0: Breaking Changes: Major changes to the public API.
- 2.1.0: Upgraded to v2.1+ of both the Paystack iOS and Android SDKs.
- 2.1.0: Added support for `chargeCard` on both platforms.
- 2.1.0: Added support for `subscriptions` and `split-payments`.
- 2.1.0: For v2-specific usage, see [v2 Docs](./v2-Docs.md).
- 3.1.0: Retired support for `getToken` on both platforms.
- 3.1.0: Added support for `chargeCardWithAccessCode` on both platforms.
- 3.1.0: Upgraded to v3.*+ of both the Paystack iOS and Android SDKs.

## 6. License

 This should be [The MIT License (MIT)](http://www.opensource.org/licenses/mit-license.html). I would have to get back to you on that!

