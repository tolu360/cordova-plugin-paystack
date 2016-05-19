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

Or using the phonegap CLI
```
$ phonegap local plugin add cordova-plugin-paystack
```

PaystackPlugin.js is brought in automatically. There is no need to change or add anything in your html.

To build for Android, add ` xmlns:android="http://schemas.android.com/apk/res/android"` to the `widget` tag of the `config.xml` file in the root of your project, while at it, include the following lines within a `platform` `(<platform name="android">)`tag in your `config.xml`:

```xml
<config-file target="AndroidManifest.xml" parent="application">
    <meta-data android:name="co.paystack.android.PublishableKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
</config-file>
```

To build for iOS, add the `publishableKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<preference name="publishableKey" value="INSERT-PUBLIC-KEY-HERE" />
```



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
<config-file target="AndroidManifest.xml" parent="application">
    <meta-data android:name="co.paystack.android.PublishableKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
</config-file>
```

To build for iOS, add the `publishableKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<preference name="publishableKey" value="INSERT-PUBLIC-KEY-HERE" />
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
<config-file target="AndroidManifest.xml" parent="application">
    <meta-data android:name="co.paystack.android.PublishableKey" android:value="INSERT-PUBLIC-KEY-HERE"/>
</config-file>
```

To build for iOS, add the `publishableKey` preference tag to the `config.xml` file in the root of your project (very bad things can happen without it):

```xml
<preference name="publishableKey" value="INSERT-PUBLIC-KEY-HERE" />
```
###Build the your app
Before you try to run your app, you should build it first to install all native dependencies in android
```
cordova build ios|android
```

## 3. Usage

### Getting a Token
It's a cinch to obtain a single-use token with the PaystackSdk using the PaystackPlugin. Like most Cordova/PhoneGap plugins, use the PaystackPlugin after the `deviceready` event is fired:

```js
window.PaystackPlugin.getToken(successCallbackfn, failureCallbackfn, cardNumber, expiryMonth, expiryYear, cvc);
```
To be more elaborate:

```js
document.addEventListener("deviceready", onDeviceReady, false);

function onDeviceReady() {
    // Now safe to use device APIs
    window.PaystackPlugin.getToken(
      function(resp) {
        // A valid one-timme-use token is obtained, do your thang!
        console.log('success: ', resp);
      },
      function(resp) {
        // Something went wrong, oops - perhaps an invalid card.
        console.log('failure: ', resp);
      },
      4123450131001381,
      05,
      16,
      883);
}
```

Explaining the arguments to `window.PaystackPlugin.getToken`:

+ {Function} successCallback - callback to be invoked on successfully acquiring a token.
 * A single object argument will be passed which has 2 keys: "token" is a string containing the returned token, while "last4" is a string containing the last 4 digits of the card the token belongs to.
+ {Function} errorCallback - callback to be invoked on failure to acquire a valid token.
 * A single object argument will be passed which has 2 keys: "error" is a string containing a description of the error, "code" is an arbitrary error code.
+ cardNumber: the card number as a String without any seperator e.g 5555555555554444
+ expiryMonth: the expiry month as an integer ranging from 1-12 e.g 10 (October) (2 digits: very !important for iOS)
+ expiryYear: the expiry year as an integer e.g 15 (2 digits: very !important for iOS)
+ cvc: the card security code as a String e.g 123

### Charging the tokens. 
Send the token to your server and create a charge by calling the Paystack REST API. An authorization_code will be returned once the single-use token has been charged successfully. You can learn more about the Paystack API [here](https://developers.paystack.co/docs/getting-started).
 
 **Endpoint:** https://api.paystack.co/transaction/charge_token

 **Parameters:** 

 - email  - customer's email address (required)
 - reference - unique reference  (required)
 - amount - Amount in Kobo (required) 

**Example**

```bash
    curl https://api.paystack.co/transaction/charge_token \
    -H "Authorization: Bearer SECRET_KEY" \
    -H "Content-Type: application/json" \
    -d '{"token": "PSTK_r4ec2m75mrgsd8n9", "email": "customer@email.com", "amount": 10000, "reference": "amutaJHSYGWakinlade256"}' \
    -X POST

```


## 4. CREDITS

This plugin uses the [cordova-custom-config plugin](https://github.com/dpa99c/cordova-custom-config) to achieve easy and reversible changes to your application's `AndroidManifest.xml` file.
Perhaps needless to say, this plugin leverages the [Paystack Android SDK](https://github.com/PaystackHQ/paystack-android) and the [Paystack iOS SDK](https://github.com/PaystackHQ/paystack-ios) for all the heavy liftings.

## 5. CHANGELOG

- 1.0.1: Initial version supporting Android.
- 1.0.3: Code clean up and addition of arbitrary error codes.
- 1.1.0: Added iOS support and bumped up paystack android library to v1.2 - making 16 the min sdk you should target.

## 6. License

 This should be [The MIT License (MIT)](http://www.opensource.org/licenses/mit-license.html). I would have to get back to you on that!

