package com.airbnb.android.react.maps;

import android.content.Context;
import android.graphics.Color;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;
import java.util.List;

public class AirMapPolyline extends AirMapFeature {

  private List<Polyline> polylineArray;
  private Polyline polyline;

  private GoogleMap map;

  private List<LatLng> coordinates;
  private List<String> strokeColors;
  private int color;
  private float width;
  private boolean geodesic;
  private float zIndex;

  public AirMapPolyline(Context context) {
    super(context);
  }

  public void setStrokeColors(ReadableArray strokeColors) {
    if(strokeColors != null){
        this.strokeColors = new ArrayList<>(strokeColors.size());
        for (int i = 0; i < strokeColors.size(); i++) {
          String strokeColor = strokeColors.getString(i);
          this.strokeColors.add(i, strokeColor);
        }
    }
  }

  public void setCoordinates(ReadableArray coordinates) {
    this.coordinates = new ArrayList<>(coordinates.size());
    for (int i = 0; i < coordinates.size(); i++) {
      ReadableMap coordinate = coordinates.getMap(i);
      this.coordinates.add(i,
          new LatLng(coordinate.getDouble("latitude"), coordinate.getDouble("longitude")));
    }

    if (polylineArray != null) {
        if(this.polylineArray.size() == 1){
            polyline.setPoints(this.coordinates);
        } else {
            PolylineOptions options = new PolylineOptions();

            if(polylineArray.size() > coordinates.size()){
                removeFromMap(this.map);
                createPolyline();
            } else {
                if(coordinates.size() > 1){
                   ReadableMap coordinate2 = coordinates.getMap(coordinates.size()-2);
                   options.add(new LatLng(coordinate2.getDouble("latitude"), coordinate2.getDouble("longitude")));
                }

                ReadableMap coordinate = coordinates.getMap(coordinates.size()-1);
                options.add(new LatLng(coordinate.getDouble("latitude"), coordinate.getDouble("longitude")));

                Integer colorToUse;

                if(this.strokeColors != null){
                    colorToUse = Color.parseColor(this.strokeColors.get(this.strokeColors.size()-1));
                } else {
                    colorToUse = color;
                }

                options.color(colorToUse);
                options.width(width);
                options.geodesic(geodesic);
                options.zIndex(zIndex);

                polyline = this.map.addPolyline(options);
                polyline.setClickable(true);

                this.polylineArray.add(polyline);
          }
        }
    }
  }

  public void setColor(int color) {
    this.color = color;
  }

  public void setWidth(float width) {
    this.width = width;
  }

  public void setZIndex(float zIndex) {
    this.zIndex = zIndex;
  }

  public void setGeodesic(boolean geodesic) {
    this.geodesic = geodesic;
  }

  private void createPolyline() {
    this.polylineArray = new ArrayList<>(coordinates.size());
    for (int i = 0; i < coordinates.size()-1; i++) {
        PolylineOptions options = new PolylineOptions();

        LatLng coordinate = coordinates.get(i);
        options.add(coordinate);

        LatLng coordinate2 = coordinates.get(i+1);
        options.add(coordinate2);

        Integer colorToUse;

        if((strokeColors != null) && (coordinates.size() == strokeColors.size())){
            colorToUse = Color.parseColor(strokeColors.get(i));
        } else {
            colorToUse = color;
        }

        options.color(colorToUse);
        options.width(width);
        options.geodesic(geodesic);
        options.zIndex(zIndex);

        polyline = this.map.addPolyline(options);
        polyline.setClickable(true);
        this.polylineArray.add(i, polyline);
    }
  }

  @Override
  public Object getFeature() {
    return polyline;
  }

  @Override
  public void addToMap(GoogleMap map) {
    this.map = map;
    createPolyline();
  }

  @Override
  public void removeFromMap(GoogleMap map) {
    for (int i = 0; i < this.polylineArray.size(); i++) {
        Polyline polyline = this.polylineArray.get(i);
        polyline.remove();
    }
    this.polylineArray.clear();
  }
}
