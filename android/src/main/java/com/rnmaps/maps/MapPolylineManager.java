package com.rnmaps.maps;

import android.content.Context;
import android.graphics.Color;
import android.util.DisplayMetrics;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.Map;

public class MapPolylineManager extends ViewGroupManager<MapPolyline> {
  private final DisplayMetrics metrics;

  public MapPolylineManager(ReactApplicationContext reactContext) {
    super();
    metrics = new DisplayMetrics();
    ((WindowManager) reactContext.getSystemService(Context.WINDOW_SERVICE))
        .getDefaultDisplay()
        .getRealMetrics(metrics);
  }

  @Override
  public String getName() {
    return "AIRMapPolyline";
  }

  @Override
  public MapPolyline createViewInstance(ThemedReactContext context) {
    return new MapPolyline(context);
  }

  @ReactProp(name = "type")
  public void setType(MapPolyline view, String type) {
    view.setType(type);
  }

  @ReactProp(name = "syncedCoordsColors")
  public void setSyncedCoordsColors(MapPolyline view, ReadableArray syncedCoordsColors) {
    view.setSyncedCoordsColors(syncedCoordsColors);
  }

  @ReactProp(name = "strokeWidth", defaultFloat = 1f)
  public void setStrokeWidth(MapPolyline view, float widthInPoints) {
    float widthInScreenPx = metrics.density * widthInPoints; // done for parity with iOS
    view.setWidth(widthInScreenPx);
  }

  @ReactProp(name = "strokeColor", defaultInt = Color.RED, customType = "Color")
  public void setStrokeColor(MapPolyline view, int color) {
    view.setColor(color);
  }

  @ReactProp(name = "geodesic", defaultBoolean = false)
  public void setGeodesic(MapPolyline view, boolean geodesic) {
    view.setGeodesic(geodesic);
  }

  @ReactProp(name = "zIndex", defaultFloat = 1.0f)
  public void setZIndex(MapPolyline view, float zIndex) {
    view.setZIndex(zIndex);
  }

  @ReactProp(name = "lineDashPattern")
  public void setLineDashPattern(MapPolyline view, ReadableArray lineDashPattern) {
      view.setLineDashPattern(lineDashPattern);
  }

  @Override
  @Nullable
  public Map getExportedCustomDirectEventTypeConstants() {
    return MapBuilder.of(
        "onPress", MapBuilder.of("registrationName", "onPress")
    );
  }
}
