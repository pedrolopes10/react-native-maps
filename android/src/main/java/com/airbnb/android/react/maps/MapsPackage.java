package com.airbnb.android.react.maps;

import android.util.Log;

import android.app.Activity;

import com.airbnb.android.react.maps.osmdroid.OsmMapCalloutManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapCircleManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapFileTile;
import com.airbnb.android.react.maps.osmdroid.OsmMapFileTileManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapMarkerManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapPolygonManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapPolylineManager;
import com.airbnb.android.react.maps.osmdroid.OsmMapUrlTileManager;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.JavaScriptModule;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class MapsPackage implements ReactPackage {
  public MapsPackage(Activity activity) {
  } // backwards compatibility

  public MapsPackage() {
  }

  @Override
  public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
    return Arrays.<NativeModule>asList(new AirMapModule(reactContext));
  }

  // Deprecated RN 0.47
  public List<Class<? extends JavaScriptModule>> createJSModules() {
    return Collections.emptyList();
  }

  @Override
  public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {

    List<ViewManager> managers = new ArrayList<>();

    if (hasGoogleMapsOnClasspath()) {
Log.d("RBDEBUG", "hasGoogleMapsOnClasspath");
      AirMapCalloutManager calloutManager = new AirMapCalloutManager();
      AirMapMarkerManager annotationManager = new AirMapMarkerManager();
      AirMapPolylineManager polylineManager = new AirMapPolylineManager(reactContext);
      AirMapPolygonManager polygonManager = new AirMapPolygonManager(reactContext);
      AirMapCircleManager circleManager = new AirMapCircleManager(reactContext);
      AirMapManager mapManager = new AirMapManager(reactContext);
      AirMapLiteManager mapLiteManager = new AirMapLiteManager(reactContext);
      AirMapUrlTileManager urlTileManager = new AirMapUrlTileManager(reactContext);
      AirMapLocalTileManager localTileManager = new AirMapLocalTileManager(reactContext);
      AirMapOverlayManager overlayManager = new AirMapOverlayManager(reactContext);

      List<ViewManager> airMapManagers = Arrays.<ViewManager>asList(
              calloutManager,
              annotationManager,
              polylineManager,
              polygonManager,
              circleManager,
              mapManager,
              mapLiteManager,
              urlTileManager,
              localTileManager,
              overlayManager
      );
      managers.addAll(airMapManagers);
    }

    if (hasOsmdroidOnClasspath()) {
Log.d("RBDEBUG", "hasOsmdroidOnClasspath");
      OsmMapCalloutManager osmCalloutManager = new OsmMapCalloutManager();
      OsmMapMarkerManager osmMarkerManager = new OsmMapMarkerManager();
      OsmMapPolylineManager osmPolylineManager = new OsmMapPolylineManager(reactContext);
      OsmMapPolygonManager osmPolygonManager = new OsmMapPolygonManager(reactContext);
      OsmMapCircleManager osmMapCircleManager = new OsmMapCircleManager(reactContext);
      OsmMapManager osmMapManager = new OsmMapManager(reactContext);
      OsmMapUrlTileManager osmUrlTileManager = new OsmMapUrlTileManager();
      OsmMapFileTileManager osmMapFileTileManager = new OsmMapFileTileManager();

      managers.addAll(Arrays.<ViewManager>asList(
          osmCalloutManager,
          osmMarkerManager,
          osmPolylineManager,
          osmPolygonManager,
          osmMapCircleManager,
          osmMapManager,
          osmUrlTileManager,
          osmMapFileTileManager
      ));
    }

    return managers;
  }

  private boolean hasOsmdroidOnClasspath() {
    try {
      Class.forName("org.osmdroid.views.MapView");
      return true;
    } catch (ClassNotFoundException ex) {
      ex.printStackTrace();
    }
    return false;
  }
  private boolean hasGoogleMapsOnClasspath() {
    try {
      Class.forName("com.google.android.gms.maps.MapView");
      return true;
    } catch (ClassNotFoundException ex) {
      ex.printStackTrace();
    }
    return false;
  }
}