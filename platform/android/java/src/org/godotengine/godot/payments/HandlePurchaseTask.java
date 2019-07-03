/*************************************************************************/
/*  HandlePurchaseTask.java                                              */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                      https://godotengine.org                          */
/*************************************************************************/
/* Copyright (c) 2007-2019 Juan Linietsky, Ariel Manzur.                 */
/* Copyright (c) 2014-2019 Godot Engine contributors (cf. AUTHORS.md)    */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/

package org.godotengine.godot.payments;

import org.json.JSONException;
import org.json.JSONObject;

import org.godotengine.godot.GodotLib;
import org.godotengine.godot.utils.Crypt;
import com.android.vending.billing.IInAppBillingService;

import android.app.Activity;
import android.app.PendingIntent;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender.SendIntentException;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.RemoteException;
import android.util.Log;

abstract public class HandlePurchaseTask {

	public static final int BILLING_RESPONSE_RESULT_OK 					= 0; // Success
	public static final int BILLING_RESPONSE_RESULT_USER_CANCELED		= 1; // User pressed back or canceled a dialog
	public static final int BILLING_RESPONSE_RESULT_SERVICE_UNAVAILABLE	= 2; // Network connection is down
	public static final int BILLING_RESPONSE_RESULT_BILLING_UNAVAILABLE	= 3; // The Google Play Billing AIDL version is not supported for the type requested
	public static final int BILLING_RESPONSE_RESULT_ITEM_UNAVAILABLE	= 4; // Requested product is not available for purchase
	public static final int BILLING_RESPONSE_RESULT_DEVELOPER_ERROR		= 5; // Invalid arguments provided to the API. This error can also indicate that the application was not correctly signed or properly set up for Google Play Billing, or does not have the necessary permissions in its manifest
	public static final int BILLING_RESPONSE_RESULT_ERROR				= 6; // Fatal error during the API action
	public static final int BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED	= 7; // Failure to purchase since item is already owned
	public static final int BILLING_RESPONSE_RESULT_ITEM_NOT_OWNED		= 8; // "Failure to consume since item is not owned

	private Activity context;

	public HandlePurchaseTask(Activity context) {
		this.context = context;
	}

	public void handlePurchaseRequest(int resultCode, Intent data) {
		//Log.d("XXX", "Handling purchase response");
		if (resultCode == Activity.RESULT_OK) {
			try {
				int responseCode = data.getIntExtra("RESPONSE_CODE", 0);
				if (responseCode == BILLING_RESPONSE_RESULT_USER_CANCELED) {
					canceled();
					return;
				}

				PaymentsCache pc = new PaymentsCache(context);

				String purchaseData = data.getStringExtra("INAPP_PURCHASE_DATA");
				//Log.d("XXX", "Purchase data:" + purchaseData);
				String dataSignature = data.getStringExtra("INAPP_DATA_SIGNATURE");
				//Log.d("XXX", "Purchase signature:" + dataSignature);
				//Log.d("SARLANGA", purchaseData);

				JSONObject jo = new JSONObject(purchaseData);
				//String sku = jo.getString("productId");
				//alert("You have bought the " + sku + ". Excellent choice, aventurer!");
				//String orderId = jo.getString("orderId");
				//String packageName = jo.getString("packageName");
				String productId = jo.getString("productId");
				//Long purchaseTime = jo.getLong("purchaseTime");
				//Integer state = jo.getInt("purchaseState");
				String developerPayload = jo.getString("developerPayload");
				String purchaseToken = jo.getString("purchaseToken");

				if (!pc.getConsumableValue("validation_hash", productId).equals(developerPayload)) {
					error("Untrusted callback");
					return;
				}

				if (responseCode == BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED) {
					alreadyOwned(productId);
					return;
				}

				//Log.d("XXX", "Este es el product ID:" + productId);
				pc.setConsumableValue("ticket_signautre", productId, dataSignature);
				pc.setConsumableValue("ticket", productId, purchaseData);
				pc.setConsumableFlag("block", productId, true);
				pc.setConsumableValue("token", productId, purchaseToken);

				success(productId, dataSignature, purchaseData);
				return;
			} catch (JSONException e) {
				error(e.getMessage());
			}
		} else if (resultCode == Activity.RESULT_CANCELED) {
			canceled();
		}
	}

	abstract protected void success(String sku, String signature, String ticket);
	abstract protected void error(String message);
	abstract protected void canceled();
	abstract protected void alreadyOwned(String sku);
}
