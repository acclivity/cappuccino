
@import "CPView.j"


@implementation _CPMenuItemSeparatorView : CPView
{
}

+ (id)view
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 10.0)];
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
        [self setAutoresizingMask:CPViewWidthSizable];

    return self;
}

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        bounds = [self bounds];

    CGContextBeginPath(context);

    CGContextMoveToPoint(context, CGRectGetMinX(bounds) + 2.0, FLOOR(CGRectGetMidY(bounds)) - 0.5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(bounds) - 2.0, FLOOR(CGRectGetMidY(bounds)) - 0.5);

    CGContextSetStrokeColor(context, [CPColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:199.0 / 255.0 alpha:1.0]);
    CGContextStrokePath(context);
}

@end