// ANSY: see AIRMapTrails.h

#import "AIRMapTrailsManager.h"

#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import "AIRMapTrails.h"

@implementation AIRMapTrailsManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[AIRMapTrails alloc] initWithFrame:CGRectZero];
}

RCT_EXPORT_VIEW_PROPERTY(strokeWidth, CGFloat)

RCT_EXPORT_METHOD(setTrails:(nonnull NSNumber *)reactTag trails:(NSString *)trails)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if ([view isKindOfClass:[AIRMapTrails class]]) [(AIRMapTrails *)view setTrailsJSON:trails];
    }];
}

RCT_EXPORT_METHOD(setTips:(nonnull NSNumber *)reactTag tips:(NSString *)tips)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if ([view isKindOfClass:[AIRMapTrails class]]) [(AIRMapTrails *)view setTipsString:tips];
    }];
}

@end
