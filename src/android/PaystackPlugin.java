package com.arttitude360.cordova;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.util.Patterns;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.net.Uri;

import co.paystack.android.Paystack;
import co.paystack.android.PaystackSdk;
import co.paystack.android.model.Card;
import co.paystack.android.model.Token;
import co.paystack.android.model.Charge;
import co.paystack.android.model.Transaction;

public class PaystackPlugin extends CordovaPlugin {

	protected Token token;
	protected Card card;
	private Charge charge;
    private Transaction transaction;

	public static final String TAG = "PaystackPlugin";

	/**
     * Cordova callback context
     */
    protected CallbackContext context;

	/**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        
        //initialize sdk
    	PaystackSdk.initialize(this.cordova.getActivity().getApplicationContext());
    }

	@Override
    public boolean execute(String action, JSONArray args,
                           CallbackContext callbackContext) throws JSONException {
        boolean result;
        try {
            if(action.equals("getToken")) {
                context = callbackContext;
                getToken(args);
                result = true;
            } else if (action.equals("chargeCard")) {
            	context = callbackContext;
                chargeCard(args);
                result = true;
            } else {
                handleError("Invalid action", 404);
                result = false;
            }
        } catch(Exception e ) {
            handleError(e.getMessage(), 401);
            result = false;
        }
        return result;
    }

    protected void handleError(String errorMsg, int errorCode){
        try {
            Log.e(TAG, errorMsg);
            JSONObject error = new JSONObject();
            error.put("error", errorMsg);
            error.put("code", errorCode);
            context.error(error);
        } catch (JSONException e) {
            Log.e(TAG, e.toString());
        }
    }

    protected void handleTokenSuccess(String token, String lastDigits) {
        try {
            Log.i(TAG, token);
            JSONObject success = new JSONObject();
            success.put("token", token);
            success.put("last4", lastDigits);
            context.success(success);
        } catch (JSONException e) {
            handleError(e.getMessage(), 401);
        }
    }

    protected void handleChargeSuccess(String reference) {
        try {
            Log.i(TAG, reference);
            JSONObject success = new JSONObject();
            success.put("reference", reference);
            context.success(success);
        } catch (JSONException e) {
            handleError(e.getMessage(), 401);
        }
    }

    private void getToken(JSONArray args) throws JSONException {
    	
		//check card validity
        validateCard(args);
		
		if (card != null && card.isValid()) {
			createToken();
		}
    }

    private void chargeCard(JSONArray args) throws JSONException {
    	
		validateTransaction(args);
		
		if (card != null && card.isValid()) {
			try {
				createTransaction();
			} catch(Exception error) {
    			handleError(error.getMessage(), 427);
    		}			
		}
    }

    protected void validateCard(JSONArray args) throws JSONException {
        
        JSONObject cardParams = args.getJSONObject(0);

        String cardNumber = cardParams.optString("cardNumber");
        int expiryMonth = cardParams.optInt("expiryMonth");
        int expiryYear = cardParams.optInt("expiryYear");
        String cvc = cardParams.optString("cvc");

		if (isEmpty(cardNumber)) {
			handleError("Empty card number.", 420);
			return;
		}

		//build card object with ONLY the number, update the other fields later
		card = new Card.Builder(cardNumber, 0, 0, "").build();

		if (!card.validNumber()) {
			handleError("Invalid card number.", 421);
			return;
		}

		//validate cvc
		if (isEmpty(cvc)) {
			handleError("Empty cvc code.", 422);
			return;
		}
		
		//update the cvc field of the card
		card.setCvc(cvc);

		//check that it's valid
		if (!card.validCVC()) {
			handleError("Invalid cvc code.", 423);
			return;
		}

		//validate expiry month;
        if (expiryMonth < 1) {
			handleError("Invalid expiration month.", 424);
			return;
		}

		//update the expiryMonth field of the card
		card.setExpiryMonth(expiryMonth);

		//validate expiry year;
        if (expiryYear < 1) {
			handleError("Invalid expiration year.", 425);
			return;
		}

		//update the expiryYear field of the card
		card.setExpiryYear(expiryYear);

		//validate expiry
		if (!card.validExpiryDate()) {
			handleError("Invalid expiration date.", 426);
		}
    }

    protected void validateTransaction(JSONArray args) throws JSONException {

        JSONObject chargeParams = args.getJSONObject(0);

        String email = chargeParams.optString("email");
        int amountInKobo = chargeParams.optInt("amountInKobo");
        String currency = chargeParams.optString("currency");
        String plan = chargeParams.optString("plan");
        int transactionCharge = chargeParams.optInt("transactionCharge");
        String subAccount = chargeParams.optString("subAccount");
        String reference = chargeParams.optString("reference");
        String bearer = chargeParams.optString("bearer");
    	
    	validateCard(args);

    	charge = new Charge();
        charge.setCard(card);

        if (isEmpty(email)) {
        	handleError("Email cannot be empty.", 428);
            return;
        }

        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
        	handleError("Invalid email.", 429);
            return;
        }

        charge.setEmail(email);

        if (amountInKobo < 1) {
        	handleError("Invalid amount", 430);
            return;
        }

        charge.setAmount(amountInKobo);

        if (currency != null && !currency.isEmpty()) {
            charge.setCurrency(currency);
        }

        if (plan != null && !plan.isEmpty()) {
            charge.setPlan(plan);
        }

        if (subAccount != null && !subAccount.isEmpty()) {
            charge.setSubaccount(subAccount);

            if (bearer != null && !bearer.isEmpty() && bearer == "subaccount") {
                charge.setBearer(Charge.Bearer.subaccount);
            }

            if (bearer != null && !bearer.isEmpty() && bearer == "account") {
                charge.setBearer(Charge.Bearer.account);
            }

            if (transactionCharge > 0) {
                charge.setTransactionCharge(transactionCharge);
            }
        }

        if (reference != null && !reference.isEmpty()) {
            charge.setReference(reference);
        }

    }

	private void createToken() {
		//then create token using PaystackSdk class
		PaystackSdk.createToken(card, new Paystack.TokenCallback() {
			@Override
			public void onCreate(Token token) {
				//here you retrieve the token, and send to your server for charging.
				handleTokenSuccess(token.token, token.last4);			
			}

			@Override
			public void onError(Throwable error) {
				handleError(error.getMessage(), 427);
			}
		});
	}

	private void createTransaction() {
        
        transaction = null;

        PaystackSdk.chargeCard(this.cordova.getActivity(), charge, new Paystack.TransactionCallback() {
            @Override
            public void onSuccess(Transaction transaction) {
                
                // This is called only after transaction is successful
                PaystackPlugin.this.transaction = transaction;

                handleChargeSuccess(transaction.reference);
            }

            @Override
            public void beforeValidate(Transaction transaction) {
                // This is called only before requesting OTP
                // Save reference so you may send to server if
                // error occurs with OTP
                PaystackPlugin.this.transaction = transaction;
            }

            @Override
            public void onError(Throwable error) {
               
                if (PaystackPlugin.this.transaction == null) {
                	handleError(error.getMessage(), 427);
                } else {
                	handleError(transaction.reference + " concluded with error: " + error.getMessage(), 427);
                }
            }

        });
    }

	private boolean isEmpty(String s) {
		return s == null || s.length() < 1;
	}
}