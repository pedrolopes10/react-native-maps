// ANSY: many trails as ONE overlay, drawn by one renderer (AIRMapTrailsRenderer).
//
// A line per trail costs the map a remove and an add of that overlay on the main
// thread every time it changes (MapKit lines are immutable), and an app that moves
// trail ends every frame, behind aircraft that move every frame, stalled the map.
// Here a change only marks the layer for redrawing; MapKit draws overlays on
// background threads, and always below the annotations (the aircraft).
//
// Fed by two commands (AIRMapTrailsManager): setTrails, the trails' recorded lines
// every few seconds, and setTips, the stretch from each line's end to its aircraft,
// every frame.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import <React/RCTComponent.h>
#import "AIRMap.h"

@class AIRMapTrailsRenderer;

// One line: its points and a colour for each of them (the colour of the segment
// that ends there), or a single colour for all
@interface AIRMapTrailPath : NSObject
@property (nonatomic, strong) NSData *points; // MKMapPoint[]
@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, assign) MKMapRect bounds;
@end

@interface AIRMapTrails : MKAnnotationView <MKOverlay>

@property (nonatomic, weak) AIRMap *map;
@property (nonatomic, strong) AIRMapTrailsRenderer *renderer;
@property (nonatomic, assign) CGFloat strokeWidth;

- (void)setTrailsJSON:(NSString *)json;
- (void)setTipsString:(NSString *)tips;
// everything to draw, a consistent copy for the renderer's threads
- (NSArray<AIRMapTrailPath *> *)snapshot;

#pragma mark MKOverlay protocol

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly) MKMapRect boundingMapRect;
- (BOOL)intersectsMapRect:(MKMapRect)mapRect;
- (BOOL)canReplaceMapContent;

@end

@interface AIRMapTrailsRenderer : MKOverlayRenderer
@end
