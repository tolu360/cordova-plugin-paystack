package com.arttitude360.cordova;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;
import android.net.Uri;

import co.paystack.android.Paystack;
import co.paystack.android.PaystackSdk;
import co.paystack.android.model.Card;
import co.paystack.android.model.Token;

public class PaystackPlugin extends CordovaPlugin {

	protected Token token;
	protected Card card;

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

    protected void handleSuccess(String token, String lastDigits){
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

    private void getToken(JSONArray args) throws JSONException {
    	
		//check card validity
        validateCard(args);
		
		if (card.isValid()) {
			createToken(card);
		}
    }

    protected void validateCard(JSONArray args) throws JSONException {
		String cardNum = args.getString(0).trim();

		if (isEmpty(cardNum)) {
			handleError("Empty card number", 420);
			return;
		}

		//build card object with ONLY the number, update the other fields later
		card = new Card.Builder(cardNum, 0, 0, "").build();

		if (!card.validNumber()) {
			handleError("Invalid card number", 421);
			return;
		}

		//validate cvc
		String cvc = args.getString(3).trim();
		if (isEmpty(cvc)) {
			handleError("Empty cvc code", 422);
			return;
		}
		
		//update the cvc field of the card
		card.setCvc(cvc);

		//check that it's valid
		if (!card.validCVC()) {
			handleError("Invalid cvc code", 423);
			return;
		}

		//validate expiry month;
		Integer expiryMonth = args.getInt(1);
		
		if (expiryMonth < 1) {
			handleError("Invalid expiration month", 424);
			return;
		}

		//update the expiryMonth field of the card
		card.setExpiryMonth(expiryMonth);

		//validate expiry year;
		Integer expiryYear = args.getInt(2);
		
		if (expiryYear < 1) {
			handleError("Invalid expiration year", 425);
			return;
		}

		//update the expiryYear field of the card
		card.setExpiryYear(expiryYear);

		//validate expiry
		if (!card.validExpiryDate()) {
			handleError("Invalid expiration date", 426);
		}
    }

	private void createToken(Card card) {
		//then create token using PaystackSdk class
		PaystackSdk.createToken(card, new Paystack.TokenCallback() {
			@Override
			public void onCreate(Token token) {
				//here you retrieve the token, and send to your server for charging.
				handleSuccess(token.token, token.last4);
			
			}

			@Override
			public void onError(Exception error) {
				handleError(error.getMessage(), 427);
			}
		});
	}

	private boolean isEmpty(String s) {
		return s == null || s.length() < 1;
	}
}