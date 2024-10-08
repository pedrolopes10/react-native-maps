package com.rnmaps.maps;

import android.content.Context;

import com.google.android.gms.maps.model.TileOverlayOptions;
import com.google.android.gms.maps.model.UrlTileProvider;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.Random;

public class MapWMSTile extends MapUrlTile {
  private static final double[] mapBound = {-20037508.34789244, 20037508.34789244};
  private static final double FULL = 20037508.34789244 * 2;

  class AIRMapGSUrlTileProvider extends MapTileProvider {

    class AIRMapWMSTileProvider extends UrlTileProvider {
      private String urlTemplate;
      private String urlCdn;
      private String urlCdnSuffix;
      private final int tileSize;

      public AIRMapWMSTileProvider(int width, int height, String urlTemplate, String urlCdn, String urlCdnSuffix) {
        super(width, height);
        this.urlTemplate = urlTemplate;
        this.urlCdn = urlCdn;
        this.urlCdnSuffix = urlCdnSuffix;
        this.tileSize = width;
      }

      @Override
      public URL getTileUrl(int x, int y, int zoom) {
        if(MapWMSTile.this.maximumZ > 0 && zoom > maximumZ) {
          return null;
        }

        if(MapWMSTile.this.minimumZ > 0 && zoom < minimumZ) {
          return null;
        }

        double[] bb = getBoundingBox(x, y, zoom);
        String s = this.urlTemplate
                .replace("{minX}", Double.toString(bb[0]))
                .replace("{minY}", Double.toString(bb[1]))
                .replace("{maxX}", Double.toString(bb[2]))
                .replace("{maxY}", Double.toString(bb[3]))
                .replace("{width}", Integer.toString(this.tileSize))
                .replace("{height}", Integer.toString(this.tileSize));

        if (this.urlCdn != null && this.urlCdnSuffix != null) {
          String[] cdn = this.urlCdn.split(",");
          String[] cdnSuffix = this.urlCdnSuffix.split(",");
          int rnd = new Random().nextInt(cdnSuffix.length);
          String cdnString = cdn[1].replace("{cdn}", cdnSuffix[rnd]);
          s = s.replace(cdn[0], cdnString);
        }

        URL url = null;

        try {
          url = new URL(s);
        } catch (MalformedURLException e) {
          throw new AssertionError(e);
        }
        return url;
      }

      private double[] getBoundingBox(int x, int y, int zoom) {
        double tile = FULL / Math.pow(2, zoom);
        return new double[]{
                mapBound[0] + x * tile,
                mapBound[1] - (y + 1) * tile,
                mapBound[0] + (x + 1) * tile,
                mapBound[1] - y * tile
        };
      }

      public void setUrlTemplate(String urlTemplate) {
        this.urlTemplate = urlTemplate;
      }

      public void setUrlCdn(String urlCdn) {
        this.urlCdn = urlCdn;
      }

      public void setUrlCdnSuffix(String urlCdnSuffix) {
        this.urlCdnSuffix = urlCdnSuffix;
      }
    }

  public AIRMapGSUrlTileProvider(int tileSizet, String urlTemplate,
    int maximumZ, int maximumNativeZ, int minimumZ, String tileCachePath,
    int tileCacheMaxAge, boolean offlineMode, Context context, boolean customMode, String urlCdn, String urlCdnSuffix) {
      super(tileSizet, false, urlTemplate, maximumZ, maximumNativeZ, minimumZ, false,
        tileCachePath, tileCacheMaxAge, offlineMode, context, customMode, urlCdn, urlCdnSuffix);
      this.tileProvider = new AIRMapWMSTileProvider(tileSizet, tileSizet, urlTemplate, urlCdn, urlCdnSuffix);
    }
  }

  public MapWMSTile(Context context) {
    super(context);
  }

  @Override
  protected TileOverlayOptions createTileOverlayOptions() {
    TileOverlayOptions options = new TileOverlayOptions();
    options.zIndex(zIndex);
    options.transparency(1 - this.opacity);
    AIRMapGSUrlTileProvider tileProvider = new AIRMapGSUrlTileProvider((int) this.tileSize, this.urlTemplate,
      (int) this.maximumZ, (int) this.maximumNativeZ, (int) this.minimumZ, this.tileCachePath,
      (int) this.tileCacheMaxAge, this.offlineMode, this.context, this.customTileProviderNeeded, this.urlCdn, this.urlCdnSuffix);
    options.tileProvider(tileProvider);
    return options;
  }
}
