/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AIRMapPolylineManager.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTUIManager.h>
#import "AIRMapCoordinate.h"
#import <React/RCTConvert+CoreLocation.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTViewManager.h>
#import <React/UIView+React.h>
#import "RCTConvert+AirMap.h"
#import "AIRMapMarker.h"
#import "AIRMapPolyline.h"

@interface AIRMapPolylineManager()

@end

@implementation AIRMapPolylineManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    AIRMapPolyline *polyline = [AIRMapPolyline new];
    return polyline;
}

// ANSY: move the line without a React render, "lat,lng;lat,lng;…" (the
// Android command's format); applied with the next coalesced update
RCT_EXPORT_METHOD(updateCoordinates:(nonnull NSNumber *)reactTag coordinates:(NSString *)coordinates)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AIRMapPolyline class]]) return;
        NSMutableArray<AIRMapCoordinate *> *points = [NSMutableArray new];
        for (NSString *pair in [coordinates componentsSeparatedByString:@";"]) {
            NSArray<NSString *> *latLng = [pair componentsSeparatedByString:@","];
            if (latLng.count != 2) continue;
            AIRMapCoordinate *point = [AIRMapCoordinate new];
            point.coordinate = CLLocationCoordinate2DMake([latLng[0] doubleValue], [latLng[1] doubleValue]);
            [points addObject:point];
        }
        if (points.count >= 2) [(AIRMapPolyline *) view setCoordinates:points];
    }];
}

RCT_EXPORT_VIEW_PROPERTY(coordinates, AIRMapCoordinateArray)
RCT_EXPORT_VIEW_PROPERTY(strokeColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(strokeColors, UIColorArray)
RCT_EXPORT_VIEW_PROPERTY(strokeWidth, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(lineCap, CGLineCap)
RCT_EXPORT_VIEW_PROPERTY(lineJoin, CGLineJoin)
RCT_EXPORT_VIEW_PROPERTY(miterLimit, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(lineDashPhase, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(lineDashPattern, NSArray)
RCT_EXPORT_VIEW_PROPERTY(geodesic, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

@end
