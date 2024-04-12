//
//  AnnotationView.h
//  react-native-maps
//
//  Created by Ricardo Barroso on 22/05/2018.
//

#import <MapKit/MapKit.h>

/// This class implementation is based on James H answer's with Swift code for fixing iOS 11 zIndex bug:
/// https://stackoverflow.com/questions/1145238/how-to-define-the-order-of-overlapping-mkannotationviews
/// and adapted with conditional code for still working ok on iOS versions < 11 (tested with iOS 10).
@interface AnnotationView : MKAnnotationView
+ (Class)layerClass;

- (void)setStickyZPosition:(CGFloat)stickyZPosition;
- (CGFloat)stickyZPosition;
- (void)bringViewToFront;
- (void)setViewToDefaultZOrder;
@end