package com.brightcove.player;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;

import android.content.Context;
import android.content.Intent;

import com.brightcove.player.edge.Catalog;
import com.brightcove.player.edge.VideoListener;
import com.brightcove.player.event.Event;
import com.brightcove.player.event.EventEmitter;
import com.brightcove.player.event.EventListener;
import com.brightcove.player.model.Video;

import java.net.URI;
import java.util.Map;

public class BrightcovePlayer extends CordovaPlugin {

    private String brightcovePolicyKey = null;
    private String brightcoveAccountId = null;
    private CordovaWebView appView;
    private EventEmitter eventEmitter;
    private Catalog catalog;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        appView = webView;

        this.eventEmitter = new EventEmitter() {
            @Override
            public int on(String s, EventListener eventListener) {
                return 0;
            }

            @Override
            public int once(String s, EventListener eventListener) {
                return 0;
            }

            @Override
            public void off() {

            }

            @Override
            public void off(String s, int i) {

            }

            @Override
            public void emit(String s) {

            }

            @Override
            public void emit(String s, Map<String, Object> map) {

            }

            @Override
            public void request(String s, EventListener eventListener) {

            }

            @Override
            public void request(String s, Map<String, Object> map, EventListener eventListener) {

            }

            @Override
            public void respond(Map<String, Object> map) {

            }

            @Override
            public void respond(Event event) {

            }

            @Override
            public void enable() {

            }

            @Override
            public void disable() {

            }
        };
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("play")) {
            String id = args.getString(0);
            this.play(id, callbackContext);
            return true;
        } else if(action.equals("initAccount")) {
            String policyKey = args.getString(0);
            String accountId = args.getString(1);
            this.initAccount(policyKey, accountId, callbackContext);
            return true;
        } else if (action.equals("getPoster")){
            String id = args.getString(0);
            this.getPoster(id, callbackContext);
            return true;
        }

        return false;
    }

    private void getPoster(String id, CallbackContext callbackContext){
        if (this.brightcovePolicyKey == null || this.brightcoveAccountId == null) {
            callbackContext.error("Please init your account first");
            return;
        }

        if (id != null && id.length() > 0) {

            this.catalog.findVideoByID(id, new VideoListener() {
                @Override
                public void onVideo(Video video) {
                    URI poster = video.getPosterImage();
                    String url = poster.toString();
                    callbackContext.success(url);
                }
                @Override
                public void onError(String error) {
                    callbackContext.error(error);
                }

            });


        } else {
            callbackContext.error("Empty video ID!");
        }


    }

    private void play(String id, CallbackContext callbackContext) {
        if (this.brightcovePolicyKey == null || this.brightcoveAccountId == null) {
            callbackContext.error("Please init your account first");
            return;
        }

        if (id != null && id.length() > 0) {
            Context context = this.cordova.getActivity().getApplicationContext();
            Intent intent = new Intent(context, BrightcoveActivity.class);
            intent.putExtra("video-id", id);
            intent.putExtra("brightcove-policy-key", this.brightcovePolicyKey);
            intent.putExtra("brightcove-account-id", this.brightcoveAccountId);
            // intent.putExtra("video-object", )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

            context.startActivity(intent);

            callbackContext.success("Playing now with Brightcove ID: " + id);
        } else {
            callbackContext.error("Empty video ID!");
        }
    }

    private void initAccount(String policyKey, String accountId, CallbackContext callbackContext) {
        if (policyKey != null && policyKey.length() > 0 && accountId != null && accountId.length() > 0 ) {
            this.brightcovePolicyKey = policyKey;
            this.brightcoveAccountId = accountId;
            if ( this.catalog instanceof Catalog ){
                this.catalog.removeListeners();
            }
            this.catalog = new Catalog(eventEmitter, this.brightcoveAccountId, this.brightcovePolicyKey);
            callbackContext.success("Inited");
        } else {
            callbackContext.error("Failed, please check your policyKey and accountId");
        }
    }
}
