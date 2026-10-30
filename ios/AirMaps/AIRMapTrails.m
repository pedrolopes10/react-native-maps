// ANSY: see AIRMapTrails.h

#import "AIRMapTrails.h"

static UIColor *AIRTrailColor(NSString *hex)
{
    NSString *s = [hex hasPrefix:@"#"] ? [hex substringFromIndex:1] : hex;
    unsigned int value = 0;
    if (![[NSScanner scannerWithString:s] scanHexInt:&value]) return [UIColor blackColor];
    if (s.length == 8) {
        return [UIColor colorWithRed:((value >> 24) & 0xFF) / 255.0
                               green:((value >> 16) & 0xFF) / 255.0
                                blue:((value >> 8) & 0xFF) / 255.0
                               alpha:(value & 0xFF) / 255.0];
    }
    return [UIColor colorWithRed:((value >> 16) & 0xFF) / 255.0
                           green:((value >> 8) & 0xFF) / 255.0
                            blue:(value & 0xFF) / 255.0
                           alpha:1.0];
}

static AIRMapTrailPath *AIRTrailPathMake(const MKMapPoint *points, NSUInteger count, NSArray<UIColor *> *colors)
{
    AIRMapTrailPath *path = [AIRMapTrailPath new];
    path.points = [NSData dataWithBytes:points length:count * sizeof(MKMapPoint)];
    path.colors = colors;
    double minX = INFINITY, minY = INFINITY, maxX = -INFINITY, maxY = -INFINITY;
    for (NSUInteger i = 0; i < count; i++) {
        minX = MIN(minX, points[i].x); maxX = MAX(maxX, points[i].x);
        minY = MIN(minY, points[i].y); maxY = MAX(maxY, points[i].y);
    }
    path.bounds = count ? MKMapRectMake(minX, minY, maxX - minX, maxY - minY) : MKMapRectNull;
    return path;
}

@implementation AIRMapTrailPath
@end

@implementation AIRMapTrails {
    NSDictionary<NSString *, AIRMapTrailPath *> *_trails;
    NSDictionary<NSString *, AIRMapTrailPath *> *_tips;
    BOOL _redrawScheduled;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _trails = @{};
        _tips = @{};
        _strokeWidth = 1.5;
        _renderer = [[AIRMapTrailsRenderer alloc] initWithOverlay:self];
    }
    return self;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth
{
    _strokeWidth = strokeWidth;
    [self scheduleRedraw];
}

// [{"id": "…", "p": [lat, lng, lat, lng, …], "c": ["#rrggbb", …]}, …]
- (void)setTrailsJSON:(NSString *)json
{
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *list = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    if (![list isKindOfClass:[NSArray class]]) return;

    NSMutableDictionary<NSString *, AIRMapTrailPath *> *trails = [NSMutableDictionary new];
    // one object per colour, so the renderer can tell runs of a colour apart
    NSMutableDictionary<NSString *, UIColor *> *palette = [NSMutableDictionary new];
    for (NSDictionary *trail in list) {
        if (![trail isKindOfClass:[NSDictionary class]]) continue;
        NSArray *p = trail[@"p"];
        NSArray *c = trail[@"c"];
        NSString *trailId = [NSString stringWithFormat:@"%@", trail[@"id"]];
        if (![p isKindOfClass:[NSArray class]] || p.count < 4) continue;
        NSUInteger count = p.count / 2;
        MKMapPoint *points = malloc(count * sizeof(MKMapPoint));
        for (NSUInteger i = 0; i < count; i++) {
            points[i] = MKMapPointForCoordinate(CLLocationCoordinate2DMake([p[i * 2] doubleValue], [p[i * 2 + 1] doubleValue]));
        }
        NSMutableArray<UIColor *> *colors = [NSMutableArray new];
        if ([c isKindOfClass:[NSArray class]]) {
            for (id color in c) {
                NSString *hex = [NSString stringWithFormat:@"%@", color];
                UIColor *parsed = palette[hex];
                if (!parsed) palette[hex] = parsed = AIRTrailColor(hex);
                [colors addObject:parsed];
            }
        }
        trails[trailId] = AIRTrailPathMake(points, count, colors);
        free(points);
    }
    @synchronized (self) {
        _trails = trails;
    }
    [self scheduleRedraw];
}

// "id|#rrggbb|lat,lng,lat,lng,…;id|…" — every frame, so no JSON
- (void)setTipsString:(NSString *)string
{
    NSMutableDictionary<NSString *, AIRMapTrailPath *> *tips = [NSMutableDictionary new];
    for (NSString *tip in [string componentsSeparatedByString:@";"]) {
        NSArray<NSString *> *parts = [tip componentsSeparatedByString:@"|"];
        if (parts.count != 3) continue;
        NSArray<NSString *> *values = [parts[2] componentsSeparatedByString:@","];
        NSUInteger count = values.count / 2;
        if (count < 2) continue;
        MKMapPoint *points = malloc(count * sizeof(MKMapPoint));
        for (NSUInteger i = 0; i < count; i++) {
            points[i] = MKMapPointForCoordinate(CLLocationCoordinate2DMake([values[i * 2] doubleValue], [values[i * 2 + 1] doubleValue]));
        }
        tips[parts[0]] = AIRTrailPathMake(points, count, @[AIRTrailColor(parts[1])]);
        free(points);
    }
    @synchronized (self) {
        _tips = tips;
    }
    [self scheduleRedraw];
}

- (NSArray<AIRMapTrailPath *> *)snapshot
{
    @synchronized (self) {
        return [_trails.allValues arrayByAddingObjectsFromArray:_tips.allValues];
    }
}

// one redraw per turn of the main run loop, however many updates came in it
- (void)scheduleRedraw
{
    if (_redrawScheduled) return;
    _redrawScheduled = YES;
    __weak AIRMapTrails *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        AIRMapTrails *strongSelf = weakSelf;
        if (!strongSelf) return;
        strongSelf->_redrawScheduled = NO;
        [strongSelf.renderer setNeedsDisplay];
    });
}

#pragma mark MKOverlay implementation

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(0, 0);
}

- (MKMapRect)boundingMapRect
{
    return MKMapRectWorld;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    return YES;
}

- (BOOL)canReplaceMapContent
{
    return NO;
}

@end

@implementation AIRMapTrailsRenderer

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    AIRMapTrails *trails = (AIRMapTrails *)self.overlay;
    NSArray<AIRMapTrailPath *> *paths = [trails snapshot];
    // doubled like AIRMapPolylineRenderer's, so a strokeWidth draws as wide as a Polyline's
    CGFloat width = (trails.strokeWidth / zoomScale) * 2.0;
    // a line's width reaches past its points: draw what crosses into the tile
    MKMapRect area = MKMapRectInset(mapRect, -width * 2, -width * 2);

    CGContextSetLineWidth(context, width);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    for (AIRMapTrailPath *path in paths) {
        if (!MKMapRectIntersectsRect(path.bounds, area)) continue;
        const MKMapPoint *points = path.points.bytes;
        NSUInteger count = path.points.length / sizeof(MKMapPoint);
        NSArray<UIColor *> *colors = path.colors;
        if (count < 2 || colors.count == 0) continue;

        // consecutive segments of one colour go in one stroke
        UIColor *current = nil;
        for (NSUInteger i = 1; i < count; i++) {
            UIColor *color = colors.count >= count ? colors[i] : colors[colors.count - 1];
            if (color != current) {
                if (current) CGContextStrokePath(context);
                current = color;
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGPoint a = [self pointForMapPoint:points[i - 1]];
                CGContextMoveToPoint(context, a.x, a.y);
            }
            CGPoint b = [self pointForMapPoint:points[i]];
            CGContextAddLineToPoint(context, b.x, b.y);
        }
        if (current) CGContextStrokePath(context);
    }
}

@end
