//
//  AnnotationView.m
//  react-native-maps
//
//  Created by Ricardo Barroso on 22/05/2018.
//

#import "AnnotationView.h"

/// iOS 11 automagically manages the CALayer zPosition, which breaks manual z-ordering.
/// This subclass just throws away any values which the OS sets for zPosition, and provides
/// a specialized accessor for setting the zPosition
@interface ZPositionableLayer: CALayer
- (void)setZPosition:(CGFloat)zPosition;
- (CGFloat)zPosition;
- (void)setStickyZPosition:(CGFloat)stickyZPosition;
- (CGFloat)stickyZPosition;
@end

@implementation ZPositionableLayer

/// no-op accessor for setting the zPosition
- (void)setZPosition:(CGFloat)zPosition {
    if (@available(iOS 11, *)) {
        // do nothing
    } else {
        [super setZPosition:zPosition];
    }
}

- (CGFloat)zPosition {
    return super.zPosition;
}

- (void)setStickyZPosition:(CGFloat)stickyZPosition {
    if (@available(iOS 11, *)) {
        super.zPosition = stickyZPosition;
    } else {
        // do nothing
    }
}

- (CGFloat)stickyZPosition {
    return super.zPosition;
}

@end

@interface AnnotationView ()
@property (nonatomic, assign) CGFloat stickyZPosition;
@end

@implementation AnnotationView

/// Override the layer factory for this class to return a custom CALayer class
+ (Class)layerClass {
    if (@available(iOS 11, *)) {
        return ZPositionableLayer.class;
    } else {
        return [super layerClass];
    }
}

- (void)setStickyZPosition:(CGFloat)stickyZPosition {
    ((ZPositionableLayer *)self.layer).stickyZPosition = stickyZPosition;
}

/// convenience accessor for setting zPosition
- (CGFloat)stickyZPosition {
    return ((ZPositionableLayer *)self.layer).stickyZPosition;
}

/// force the pin to the front of the z-ordering in the map view
- (void)bringViewToFront {
    [super bringSubviewToFront:self];
    self.stickyZPosition = 1;
}

/// force the pin to the back of the z-ordering in the map view
- (void)setViewToDefaultZOrder {
    self.stickyZPosition = 0;
}

@end