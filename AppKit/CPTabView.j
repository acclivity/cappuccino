@implementation CPTabView : CPView
{
	CPArray _tabViewItems;
	CPTabViewItem _selectedTabViewItem;
	
	CPFont _font;
	
	id _delegate;
}

- (id)initWithFrame:(CPRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self) 
	{		
		_tabViewItems = [];
		_selectedTabViewItem = nil;
		
		_font = [CPFont systemFontOfSize:14]; // TODO: Implement fonts
		
		[self layoutSubviews];
	}
	
	return self;
}

/* ADD / REMOVE TABS */
- (void)_notifyDelegateOfNumberOfItemsChange
{
	if ([_delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)])
	{
		[_delegate tabViewDidChangeNumberOfTabViewItems:self];
	}
}

- (void)addTabViewItem:(CPTabViewItem)tabViewItem
{	
	[_tabViewItems addObject:tabViewItem]
	[self _notifyDelegateOfNumberOfItemsChange];
	
	[self layoutSubviews];
}

- (void)insertTabViewItem:(CPTabViewItem)tabViewItem atIndex:(NSInteger)index
{
	[_tabViewItems insertObject:tabViewItem atIndex:index];
	[self _notifyDelegateOfNumberOfItemsChange];
	
	[self layoutSubviews];
}

- (void)removeTabViewItem:(CPTabViewItem)tabViewItem
{
	[_tabViewItems removeObject:tabViewItem];
	[self _notifyDelegateOfNumberOfItemsChange];
	
	[self layoutSubviews];
}

/* SELECTION */.
- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem
{	
	_selectedTabViewItem = tabViewItem;
	
	[self layoutSubviews];
}

- (void)selectTabViewItemAtIndex:(NSInteger)index
{
	[self selectTabViewItem:[_tabViewItems objectAtIndex:index]];
}

- (void)selectTabViewItemWithIdentifier:(id)identifier
{
	for (var index = 0; index < [_tabViewItems count]; index++)
	{
		var tabViewItem = [_tabViewItems objectAtIndex:index];
		if ([tabViewItem identifier] == identifier)
		{
			[self selectTabViewItem:tabViewItem];
		}
	}
}

- (void)takeSelectedTabViewItemFromSender:(id)sender
{
	[self selectTabViewItem:[_tabViewItems objectAtIndex:[sender indexOfSelectedItem]]];
}

/* NAVIGATION */
- (void)selectFirstTabViewItem:(id)sender
{
	[self selectTabViewItemAtIndex:0];
}

- (void)selectLastTabViewItem:(id)sender
{
	[self selectTabViewItem:[_tabViewItems lastObject]];
}

- (void)selectNextTabViewItem:(id)sender
{
	var newSelectedIndex = [_tabViewItems indexOfObject:_selectedTabViewItem] + 1;
	if (newSelectedIndex < [_tabViewItems count])
	{
		[self selectTabViewItemAtIndex:newSelectedIndex];
	}
}

- (void)selectPreviousTabViewItem:(id)sender
{	
	var newwSelectedIndex = [_tabViewItems indexOfObject:_selectedTabViewItem] - 1;
	if (newwSelectedIndex >= 0) 
	{
		[self selectTabViewItemAtIndex:newwSelectedIndex];
	}
}

/* QUERY */
- (int)numberOfTabViewItems
{
	return [_tabViewItems count];
}

- (int)indexOfTabViewItem:(NSTabViewItem *)tabViewItem
{
	return [_tabViewItems indexOfObject:tabViewItem];
}

- (CPTabViewItem *)tabViewItemAtIndex:(NSInteger)index
{
	return [_tabViewItems objectAtIndex:index];
}

- (int)indexOfTabViewItemWithIdentifier:(id)identifier
{
	for (var index = 0; index < [_tabViewItems count]; index++)
	{
		if ([[_tabViewItems objectAtIndex:index] identifier] == identifier)
		{
			return index;
		}
	}
	
	return CPNotFound;
}

/* DELEGATE */

/*
	- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem;
	- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem;
	- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
	- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)TabView;
*/
- (void)setDelegate:(id)aDelegate
{
	// TODO: implement should, will and did select delegates
	
	_delegate = aDelegate;
}

- (id)delegate
{
	return _delegate;
}

/* HIT TESTING */
- (CPTabViewItem)tabViewItemAtPoint:(CPPoint)point
{
	for (var index = 0; index < [_tabViewItems count]; index++)
	{
		
	}
}

/* GETTERS */
- (CPTabViewItem)selectedTabViewItem
{
	return _selectedTabViewItem;
}

- (CPFont)font
{
	return _font;
}

- (CPTabViewType)tabViewType
{
	// TODO: Implement this
	return nil;
}

- (CPArray)tabViewItems
{
	return _tabViewItems;
}

- (BOOL)allowsTruncatedLabels
{
	// TODO: Implement this
	return YES;
}

- (CPSize)minimumSize
{
	// TODO: Implement this, waiting for CPSegmentedControler sizeToFit
}

- (BOOL)drawsBackground
{
	// TODO: Implement this
	return YES;
}

// - (NSControlTint)controlTint;
// - (NSControlSize)controlSize;

/* SETTERS */
- (void)setFont:(CPFont)aFont
{
	if (_font != font) 
	{
		_font = aFont;
		
		[self setNeedsLayout];
	}
}

- (void)setTabViewType:(CPTabViewType)tabViewType
{
	// TODO: Implement this
}

- (void)setAllowsTruncatedLabels:(BOOL)allowTruncatedLabels
{
	// TODO: Implement this
}

- (void)setDrawsBackground:(BOOL)flag
{
	// TODO: Implement this
}

// - (void)setControlTint:(NSControlTint)controlTint;
// - (void)setControlSize:(NSControlSize)controlSize;

/* LAYOUT */
- (CGRect)rectForEphemeralSubviewNamed:(CPString)aName
{
	var bounds = [self bounds];
	
	if (aName == 'tabbar-view')
	{
		return CPRectMake(0.0, 0.0, bounds.size.width, 24.0);
	}
	else if (aName == 'content-view')
	{
		return CPRectMake(1.0, 24.0, bounds.size.width - 2.0, bounds.size.height - 25.0);
	}
	
	return [super rectForEphemeralSubviewNamed:aName];
}

- (CPView)createEphemeralSubviewNamed:(CPString)aName
{	
	if (aName == 'tabbar-view')
	{
		var view = [[CPSegmentedControl alloc] initWithFrame:CPRectMakeZero()];
		
		[view setTarget:self];
		[view setAction:@selector(takeSelectedTabViewItemFromSender:)]
		
		return view;
	} 
	else if (aName == 'content-view') 
	{
		var view = [[CPView alloc] initWithFrame:CPRectMakeZero()];
		return view;
	}
	
	return [super createEphemeralSubviewNamed];
}

- (void)_setupTabsView:(CPSegmentedControl)theTabsView withContentView:(CPView)aContentView
{		
	[theTabsView setSegmentCount:[_tabViewItems count]];
	for (var index = 0; index < [_tabViewItems count]; index++)
	{
		var tabViewItem = [_tabViewItems objectAtIndex:index];
		
		[theTabsView setLabel:[tabViewItem label] forSegment:index];
		
		// Make sure the view is removed from the content view. This will be re-added later if necesary.
		[[tabViewItem view] removeFromSuperview];
	}
	
	if ([_tabViewItems count] > 0)
	{		
		// Make sure there is always one item selected
		if (!_selectedTabViewItem) _selectedTabViewItem = [_tabViewItems objectAtIndex:0];
		
		[theTabsView setSelectedSegment:[_tabViewItems indexOfObject:_selectedTabViewItem]];
		
		var selectedView = [_selectedTabViewItem view];
		[selectedView setFrame:[aContentView bounds]];
		[aContentView addSubview:selectedView];
	}
}

- (void)layoutSubviews
{	
	[super layoutSubviews];

	// CONTENT VIEW	
	var contentView = [self layoutEphemeralSubviewNamed:@"content-view"
											 positioned:CPWindowBelow
						relativeToEphemeralSubviewNamed:@"tabbar-view"];
						
	// TABS VIEW
	var tabsView = [self layoutEphemeralSubviewNamed:@"tabbar-view" 
										  positioned:CPWindowAbove 
				     relativeToEphemeralSubviewNamed:@"content-view"];

	[self _setupTabsView:tabsView withContentView:contentView];
}

- (void)drawRect:(CPRect)rect
{
	var context = [[CPGraphicsContext currentContext] graphicsPort];
	
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColor(context, [CPColor colorWithRed:193.0 / 255.0 green:193.0 / 255.0 blue:193.0 / 255.0 alpha:1.0]);	
	
	var bounds = [self bounds]
	CGContextStrokeRect(context, CPRectMake(0.0, 13.0, bounds.size.width - 1.5, bounds.size.height - 13.5));	
}

@end

var CPTabViewItemsKey				= "CPTabViewItemsKey",
	CPTabViewSelectedItemKey		= "CPTabViewSelectedItemKey",
	CPTabViewTypeKey				= "CPTabViewTypeKey",
	CPTabViewDelegateKey			= "CPTabViewDelegateKey";

@implementation CPTabView (CPCoding)

- (id)initWithCoder:(CPCoder)aCoder
{
	if (self = [super initWithCoder:aCoder])
	{
		_tabViewItems = [];
		
		var items = [aCoder decodeObjectForKey:CPTabViewItemsKey];
		for (var i = 0; items && i < items.length; i++)
		{
			[self insertTabViewItem:items[i] atIndex:i];
		}
		
		var selected = [aCoder decodeObjectForKey:CPTabViewSelectedItemKey];
		if (selected) { [self selectTabViewItem:selected] };
		
		[self setDelegate:[aCoder decodeObjectForKey:CPTabViewDelegateKey]];
	}
	
	return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
	[super encodeWithCoder:aCoder];
	
	[aCoder encodeObject:_tabViewItems forKey:CPTabViewItemsKey];
	[aCoder encodeObject:_selectedTabViewItem forKey:CPTabViewSelectedItemKey];

	[aCoder encodeConditionalObject:_delegate forKey:CPTabViewDelegateKey];
}

@end


@implementation CPSegmentedControl (CPTabView)

- (int)indexOfSelectedItem
{
	return [self selectedSegment];
}

@end

