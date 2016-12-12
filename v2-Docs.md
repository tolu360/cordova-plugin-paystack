## 3. Usage

### Getting a Token (iOS & Android)
- Note: If you are working with XCode 8+, to allow encryptions work properly with the Paystack SDK, you may need to enable `Keychain Sharing` for your app. In the Capabilities pane, if Keychain Sharing isn’t enabled, toggle ON the switch in the Keychain Sharing section.

<img width=400 title="XCode files tree" src="./4_enablekeychain_2x.png">

It's a cinch to obtain a single-use token with the Paystack SDKs using the PaystackPlugin. Like most Cordova/PhoneGap plugins, use the PaystackPlugin after the `deviceready` event is fired:

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
        console.log('getting token successful: ', resp);
      },
      function(resp) {
        // Something went wrong, oops - perhaps an invalid card.
        console.log('getting token failed: ', resp);
      },
      '4123450131001381',
      '05',
      '16',
      '883');
}
```

You must not forget to build your project again - each time you edit native code. Run `cordova build ios/android` or similar variants.

Explaining the arguments to `window.PaystackPlugin.getToken`:

| Argument        | Type           | Description  |
| ------------- |:-------------:| :-----|
| cardNumber          | string | the card number as a String without any seperator e.g 5555555555554444 |
| expiryMonth      | string      | the card expiry month as a double-digit ranging from 1-12 e.g 10 (October) |
| expiryYear | string      | the card expiry year as a double-digit e.g 15 |
| cvc | string | the card 3/4 digit security code as a String e.g 123 |

#### Response Object

An object of the form is returned from a successful token request

```javascript
{
  token: "PSTK_4aw6i0yizwvyzjx",
  last4: "1381"
}
```

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

### Charging a Card (Android Only)
You can complete a transaction using the Paystack Android SDK. This method is, however, only available on the Android pltform at this time. Like most Cordova/PhoneGap plugins, use the PaystackPlugin after the `deviceready` event is fired:

```js
window.PaystackPlugin.chargeCard(successCallbackfn, failureCallbackfn, cardNumber, expiryMonth, expiryYear, cvc, email, amountInKobo);
```
To be more elaborate:

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
      '4123450131001381',
      '05',
      '16',
      '883',
      'dev@cordova.io',
      10000);
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

#### Response Object

An object of the form is returned from a successful charge

```javascript
{
  reference: "trx_1k2o600w"
}
```