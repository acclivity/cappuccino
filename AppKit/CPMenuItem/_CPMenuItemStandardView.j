@import "CPControl.j"


var LEFT_MARGIN                 = 5.0,
    RIGHT_MARGIN                = 10.0,
    STATE_COLUMN_WIDTH          = 14.0,
    INDENTATION_WIDTH           = 17.0,
    VERTICAL_MARGIN             = 4.0,

    RIGHT_COLUMNS_MARGIN        = 30.0,
    KEY_EQUIVALENT_MARGIN       = 10.0;

var SUBMENU_INDICATOR_COLOR                     = nil,
    _CPMenuItemSelectionColor                   = nil,
    _CPMenuItemTextShadowColor                  = nil,

    _CPMenuItemDefaultStateImages               = [],
    _CPMenuItemDefaultStateHighlightedImages    = [];

@implementation _CPMenuItemStandardView : CPView
{
    CPMenuItem              _menuItem @accessors(property=menuItem);

    CPFont                  _font;
    CPColor                 _textColor;
    CPColor                 _textShadowColor;

    CGSize                  _minSize @accessors(readonly, property=minSize);
    BOOL                    _isDirty;

    CPView                  _contentView;

    CPImageView             _stateView;
    _CPImageAndTextView     _imageAndTextView;
    _CPImageAndTextView     _keyEquivalentView;
    CPView                  _submenuIndicatorView;
}

+ (void)initialize
{
    if (self !== [_CPMenuItemStandardView class])
        return;

    SUBMENU_INDICATOR_COLOR = [CPColor colorWithRed:162.0 / 255.0 green:162.0 / 255.0 blue:162.0 / 255.0 alpha:1.0];

    _CPMenuItemSelectionColor =  [CPColor colorWithCalibratedRed:87.0 / 255.0 green:127.0 / 255.0 blue:215.0 / 255.0 alpha:1.0];
    _CPMenuItemTextShadowColor = [CPColor colorWithWhite:0.0 alpha:0.15];

    var bundle = [CPBundle bundleForClass:self];

    _CPMenuItemDefaultStateImages[CPOffState]               = nil;
    _CPMenuItemDefaultStateHighlightedImages[CPOffState]    = nil;

    _CPMenuItemDefaultStateImages[CPOnState]               = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPMenuItem/CPMenuItemOnState.png"] size:CGSizeMake(14.0, 14.0)];
    _CPMenuItemDefaultStateHighlightedImages[CPOnState]    = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"CPMenuItem/CPMenuItemOnStateHighlighted.png"] size:CGSizeMake(14.0, 14.0)];

    _CPMenuItemDefaultStateImages[CPMixedState]             = nil;
    _CPMenuItemDefaultStateHighlightedImages[CPMixedState]  = nil;
}

+ (id)view
{
    return [[self alloc] initWithFrame:CGRectMakeZero()];
}

- (id)initWithFrame:(CGRect)theFrame
{
    if (self = [super initWithFrame:theFrame])
    {
        [self setAutoresizingMask:CPViewWidthSizable];
        [[self _contentView] setAutoresizingMask:CPViewWidthSizable]
    }

    return self;
}

+ (float)_standardLeftMargin
{
    return LEFT_MARGIN + STATE_COLUMN_WIDTH + (VERTICAL_MARGIN / 2.0);
}

- (CPColor)textColor
{
    if (![_menuItem isEnabled])
        return [CPColor lightGrayColor];

    return _textColor || [CPColor colorWithCalibratedRed:70.0 / 255.0 green:69.0 / 255.0 blue:69.0 / 255.0 alpha:1.0];
}

- (CPColor)textShadowColor
{
    if (![_menuItem isEnabled])
        return nil;

    return _textShadowColor || [CPColor colorWithWhite:1.0 alpha:0.8];
}

- (void)setFont:(CPFont)aFont
{
    _font = aFont;
}

- (void)update
{
    var x = LEFT_MARGIN + [_menuItem indentationLevel] * INDENTATION_WIDTH,
        height = 0.0,
        hasStateColumn = [[_menuItem menu] showsStateColumn];

    if (hasStateColumn)
    {
        var stateView = [self _stateView];

        [stateView setHidden:NO];
        [stateView setImage:_CPMenuItemDefaultStateImages[[_menuItem state]] || nil];

        x += STATE_COLUMN_WIDTH;
    }
    else
    {
        // Don't use the accessor to make sure the view isn't lazily unnecessarily instantiated
        [_stateView setHidden:YES];
    }

    var imageAndTextView = [self _imageAndTextView];
    [imageAndTextView setFont:[_menuItem font] || _font];
    [imageAndTextView setVerticalAlignment:CPCenterVerticalTextAlignment];
    [imageAndTextView setImage:[_menuItem image]];
    [imageAndTextView setImageOffset:5.0]; // Should be themeable
    [imageAndTextView setText:[_menuItem title]];
    [imageAndTextView setTextColor:[self textColor]];
    [imageAndTextView setTextShadowColor:[self textShadowColor]];
    [imageAndTextView setTextShadowOffset:CGSizeMake(0.0, 1.0)];
    [imageAndTextView sizeToFit];

    var imageAndTextViewFrame = [imageAndTextView frame];

    imageAndTextViewFrame.origin.x = x;
    x += CGRectGetWidth(imageAndTextViewFrame);
    height = MAX(height, CGRectGetHeight(imageAndTextViewFrame));

    var hasKeyEquivalent = !![_menuItem keyEquivalent],
        hasSubmenu = [_menuItem hasSubmenu];

    if (hasKeyEquivalent || hasSubmenu)
        x += RIGHT_COLUMNS_MARGIN;

    if (hasKeyEquivalent)
    {
        var keyEquivalentView = [self _keyEquivalentView];

        [keyEquivalentView setFont:[_menuItem font] || _font];
        [keyEquivalentView setVerticalAlignment:CPCenterVerticalTextAlignment];
        [keyEquivalentView setImage:[_menuItem image]];
        [keyEquivalentView setText:[_menuItem keyEquivalentStringRepresentation]];
        [keyEquivalentView setTextColor:[self textColor]];
        [keyEquivalentView setTextShadowColor:[self textShadowColor]];
        [keyEquivalentView setTextShadowOffset:CGSizeMake(0, 1)];
        [keyEquivalentView setFrameOrigin:CGPointMake(x, VERTICAL_MARGIN)];
        [keyEquivalentView sizeToFit];

        var keyEquivalentViewFrame = [keyEquivalentView frame];

        keyEquivalentViewFrame.origin.x = CGRectGetWidth([[self _contentView] bounds]) - CGRectGetWidth(keyEquivalentViewFrame) - 7.0;
        x += CGRectGetWidth(keyEquivalentViewFrame);
        height = MAX(height, CGRectGetHeight(keyEquivalentViewFrame));

        if (hasSubmenu)
            x += RIGHT_COLUMNS_MARGIN;
    }
    else
    {
        // Don't use the accessor to make sure the view isn't lazily unnecessarily instantiated
        [_keyEquivalentView setHidden:YES];
    }

    height += 2.0 * VERTICAL_MARGIN;

    if (hasSubmenu)
    {
        var submenuIndicatorView = [self _submenuIndicatorView],
            submenuViewFrame = [submenuIndicatorView frame];

        [submenuIndicatorView setHidden:NO];

        submenuViewFrame.origin.x = CGRectGetWidth([[self _contentView] bounds]) - CGRectGetWidth(submenuViewFrame) - 7.0;
        submenuViewFrame.origin.y = FLOOR((height - CGRectGetHeight(submenuViewFrame)) / 2.0);

        [_submenuIndicatorView setFrame:submenuViewFrame];

        x += CGRectGetWidth(submenuViewFrame);
        height = MAX(height, CGRectGetHeight(submenuViewFrame));
    }
    else
    {
        // Don't use the accessor to make sure the view isn't lazily unnecessarily instantiated
        [_submenuIndicatorView setHidden:YES];
    }

    imageAndTextViewFrame.origin.y = FLOOR((height - CGRectGetHeight(imageAndTextViewFrame)) / 2.0);
    [imageAndTextView setFrame:imageAndTextViewFrame];

    if (hasStateColumn)
        [[self _stateView] setFrameSize:CGSizeMake(STATE_COLUMN_WIDTH, height)];

    if (hasKeyEquivalent)
    {
        keyEquivalentViewFrame.origin.y = FLOOR((height - CGRectGetHeight(keyEquivalentViewFrame)) / 2.0);
        [[self _keyEquivalentView] setFrame:keyEquivalentViewFrame];
    }

    _minSize = CGSizeMake(x + RIGHT_MARGIN, height);

    [self setAutoresizesSubviews:NO];
    [self setFrameSize:_minSize];
    [self setAutoresizesSubviews:YES];

    [self setAutoresizesSubviews:NO];
    [[self _contentView] setFrame:CGRectInset([self bounds], 2.0, 0.0)];
    [self setAutoresizesSubviews:YES];
}

- (void)highlight:(BOOL)shouldHighlight
{
    // FIXME: This should probably be even throw.
    if (![_menuItem isEnabled])
        return;

    if (shouldHighlight)
    {
        [[self _contentView] setBackgroundColor:_CPMenuItemSelectionColor];

        // Don't use the accessor to make sure the view isn't lazily unnecessarily instantiated
        [_imageAndTextView setImage:[_menuItem alternateImage] || [_menuItem image]];
        [_imageAndTextView setTextColor:[CPColor whiteColor]];
        [_keyEquivalentView setTextColor:[CPColor whiteColor]];
        [_submenuIndicatorView setColor:[CPColor whiteColor]];

        [_imageAndTextView setTextShadowColor:_CPMenuItemTextShadowColor];
        [_keyEquivalentView setTextShadowColor:_CPMenuItemTextShadowColor];
    }
    else
    {
        [[self _contentView] setBackgroundColor:nil];

        // Don't use the accessor to make sure the view isn't lazily unnecessarily instantiated
        [_imageAndTextView setImage:[_menuItem image]];
        [_imageAndTextView setTextColor:[self textColor]];
        [_keyEquivalentView setTextColor:[self textColor]];
        [_submenuIndicatorView setColor:SUBMENU_INDICATOR_COLOR];

        [_imageAndTextView setTextShadowColor:[self textShadowColor]];
        [_keyEquivalentView setTextShadowColor:[self textShadowColor]];
    }

    if ([[_menuItem menu] showsStateColumn])
    {
        if (shouldHighlight)
            [[self _stateView] setImage:_CPMenuItemDefaultStateHighlightedImages[[_menuItem state]] || nil];
        else
            [[self _stateView] setImage:_CPMenuItemDefaultStateImages[[_menuItem state]] || nil];
    }
}

- (CPView)_contentView
{
    if (!_contentView)
    {
        _contentView = [[CPView alloc] initWithFrame:CGRectInset([self bounds], 7.0, 0.0)];
        [_contentView setBackgroundColor:nil];
        [self addSubview:_contentView];
    }

    return _contentView;
}

- (CPView)_stateView
{
    if (!_stateView)
    {
        _stateView = [[CPImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        [_stateView setImageScaling:CPScaleNone];
        [[self _contentView] addSubview:_stateView];
    }

    return _stateView;
}

- (_CPImageAndTextView)_imageAndTextView
{
    if (!_imageAndTextView)
    {
        _imageAndTextView = [[_CPImageAndTextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        [_imageAndTextView setImagePosition:CPImageLeft];
        [_imageAndTextView setTextShadowOffset:CGSizeMake(0.0, 1.0)];
        [[self _contentView] addSubview:_imageAndTextView];
    }

    return _imageAndTextView;
}

- (_CPImageAndTextView)_keyEquivalentView
{
    if (!_keyEquivalentView)
    {
        _keyEquivalentView = [[_CPImageAndTextView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];

        [_keyEquivalentView setImagePosition:CPNoImage];
        [_keyEquivalentView setTextShadowOffset:CGSizeMake(0.0, 1.0)];
        [_keyEquivalentView setAutoresizingMask:CPViewMinXMargin];

        [[self _contentView] addSubview:_keyEquivalentView];
    }

    return _keyEquivalentView;
}

- (_CPMenuItemSubmenuIndicatorView)_submenuIndicatorView
{
    if (!_submenuIndicatorView)
    {
        _submenuIndicatorView = [[_CPMenuItemSubmenuIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 5.0, 8.0)];
        [_submenuIndicatorView setColor:SUBMENU_INDICATOR_COLOR];
        [_submenuIndicatorView setAutoresizingMask:CPViewMinXMargin];
        [[self _contentView] addSubview:_submenuIndicatorView];
    }

    return _submenuIndicatorView;
}

@end

@implementation _CPMenuItemSubmenuIndicatorView : CPView
{
    CPColor _color;
}

- (void)setColor:(CPColor)aColor
{
    if (_color === aColor)
        return;

    _color = aColor;

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        bounds = [self bounds];

    bounds.size.height -= 1.0;

    CGContextBeginPath(context);

    CGContextMoveToPoint(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
    CGContextAddLineToPoint(context, CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    CGContextAddLineToPoint(context, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));

    CGContextClosePath(context);

    CGContextSetFillColor(context, _color);
    CGContextFillPath(context);
}

@end
