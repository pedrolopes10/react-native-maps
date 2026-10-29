//
// Created by Leland Richardson on 12/27/15.
// Copyright (c) 2015 Facebook. All rights reserved.
//

#import "AIRMapPolyline.h"
#import "AIRMapPolylineRenderer.h"
#import <React/UIView+React.h>


// ANSY: every prop setter used to remove the overlay from the map and add it
// back at once, and a React update sets several props: one coordinates change
// was half a dozen overlay swaps, plus geodesic lines built twice, on the main
// thread. Apps that redraw lines several times a second (rbapp's playback
// trails) stalled the map for ~50 ms a time. After the first build, changes
// are now gathered and applied once, on the next turn of the main run loop.
@implementation AIRMapPolyline {
    BOOL _updateScheduled;
    BOOL _coordinatesDirty;
}

- (void)scheduleUpdate {
    if (_updateScheduled) return;
    _updateScheduled = YES;
    __weak AIRMapPolyline *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        AIRMapPolyline *strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_updateScheduled = NO;
        if (strongSelf->_coordinatesDirty) {
            strongSelf->_coordinatesDirty = NO;
            [strongSelf buildPolyline];
        }
        [strongSelf update];
    });
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    [self scheduleUpdate];
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    _strokeColor = strokeColor;
    [self scheduleUpdate];
}

- (void)setStrokeColors:(NSArray<UIColor *> *)strokeColors {
    _strokeColors = strokeColors;
    if ((self.renderer != nil) && ![_renderer isKindOfClass:[AIRMapPolylineRenderer class]]) {
        self.renderer = [self createRenderer];
    }
    [self scheduleUpdate];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    _strokeWidth = strokeWidth;
    [self scheduleUpdate];
}

- (void)setLineJoin:(CGLineJoin)lineJoin {
    _lineJoin = lineJoin;
    [self scheduleUpdate];
}

- (void)setLineCap:(CGLineCap)lineCap {
    _lineCap = lineCap;
    [self scheduleUpdate];
}

- (void)setMiterLimit:(CGFloat)miterLimit {
    _miterLimit = miterLimit;
    [self scheduleUpdate];
}

- (void)setLineDashPhase:(CGFloat)lineDashPhase {
    _lineDashPhase = lineDashPhase;
    [self scheduleUpdate];
}

- (void)setLineDashPattern:(NSArray <NSNumber *> *)lineDashPattern {
    _lineDashPattern = lineDashPattern;
    [self scheduleUpdate];
}

-(void)setGeodesic:(BOOL)geodesic
{
  _geodesic = geodesic;
    if (_coordinates && self.polyline != nil) {
        _coordinatesDirty = YES;
        [self scheduleUpdate];
    } else if (_coordinates) {
        [self setCoordinates:_coordinates];
    }
}

- (void)setCoordinates:(NSArray<AIRMapCoordinate *> *)coordinates {
    _coordinates = coordinates;
    // the first build is immediate: the map asks for the overlay's renderer
    // as soon as it is added, and has to get one
    if (self.polyline != nil) {
        _coordinatesDirty = YES;
        [self scheduleUpdate];
        return;
    }
    [self buildPolyline];
    [self update];
}

- (void)buildPolyline {
    NSArray<AIRMapCoordinate *> *coordinates = _coordinates;
    CLLocationCoordinate2D *coords = calloc(coordinates.count, sizeof(CLLocationCoordinate2D));
    for(int i = 0; i < coordinates.count; i++)
    {
        coords[i] = coordinates[i].coordinate;
    }
    if(_geodesic){
        self.polyline = [MKGeodesicPolyline polylineWithCoordinates:coords count:coordinates.count];
    } else {
        self.polyline = [MKPolyline polylineWithCoordinates:coords count:coordinates.count];
    }
    free(coords);
    
    self.renderer = [self createRenderer];
}

- (MKOverlayPathRenderer*)createRenderer {
    if (self.polyline == nil) return nil;
    if (self.strokeColors == nil) {
        // Use the default renderer when no array of stroke-colors is defined.
        // This behaviour may be changed in the future if we permanently want to 
        // use the custom renderer, because it can add funtionality that is not
        // supported by the default renderer.
        return [[MKPolylineRenderer alloc] initWithPolyline:self.polyline];
    }
    else {
        return [[AIRMapPolylineRenderer alloc] initWithOverlay:self polyline:self.polyline];
    }
}

- (void) update
{
    if (!_renderer) return;
    [self updateRenderer:_renderer];
    
    if (_map == nil) return;
    [_map removeOverlay:self];
    [_map addOverlay:self];
}

- (void) updateRenderer:(MKOverlayPathRenderer*)renderer {
    renderer.fillColor = _fillColor;
    renderer.strokeColor = _strokeColor;
    renderer.lineWidth = _strokeWidth;
    renderer.lineCap = _lineCap;
    renderer.lineJoin = _lineJoin;
    renderer.miterLimit = _miterLimit;
    renderer.lineDashPhase = _lineDashPhase;
    renderer.lineDashPattern = _lineDashPattern;
    
    if ([renderer isKindOfClass:[AIRMapPolylineRenderer class]]) {
        ((AIRMapPolylineRenderer*)renderer).strokeColors = _strokeColors;
    }
}

#pragma mark MKOverlay implementation

- (CLLocationCoordinate2D) coordinate
{
    return self.polyline.coordinate;
}

- (MKMapRect) boundingMapRect
{
    return self.polyline.boundingMapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    BOOL answer = [self.polyline intersectsMapRect:mapRect];
    return answer;
}

- (BOOL)canReplaceMapContent
{
    return NO;
}


#pragma mark AIRMapSnapshot implementation

- (void) drawToSnapshot:(MKMapSnapshot *) snapshot context:(CGContextRef) context
{
    AIRMapPolylineRenderer* renderer = [[AIRMapPolylineRenderer alloc] initWithSnapshot:snapshot overlay:self polyline:self.polyline];
    [self updateRenderer:renderer];
    [renderer drawWithZoomScale:2 inContext:context];
}

@end
