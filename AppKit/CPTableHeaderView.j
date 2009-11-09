/*
 * CPTableHeaderView.j
 * AppKit
 *
 * Created by Ross Boucher.
 * Copyright 2009 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import "CPTableColumn.j"
@import "CPTableView.j"
@import "CPView.j"
@import <AppKit/CGGradient.j>

var _headerGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(),[1.0,1.0,1.0,1.0,0.929,0.929,0.929,1.0], [0.3,1], 2),
    _selectedHeaderGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [0.804,0.851,0.918,1.0,0.655,0.718,0.8,1.0], [0.3,1], 2),
    _pressedHeaderGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(),[0.929,0.929,0.929,1.0,1.0,1.0,1.0,1.0], [0.3,1], 2),
    _selectedPressedHeaderGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), [0.655,0.718,0.8,1.0,0.804,0.851,0.918,1.0], [0.3,1], 2),
    SelectionColor = nil;

@implementation _CPTableColumnHeaderView : CPView
{
    BOOL        _isPressed;
    CPTextField _textField;
}

+ (CPImage)selectionColor
{
    if (!SelectionColor)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:self] pathForResource:@"_CPTableColumnHeaderView/HeaderSelected.png"] size:CGSizeMake(1.0, 36.0)];
        SelectionColor = [CPColor colorWithPatternImage:image];
    }
    
    return SelectionColor;
}

- (void)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {   
        _isPressed = NO;        
        _textField = [CPTextField new];
        [_textField setFrame:frame];
        [_textField setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
        [self addSubview:_textField];
    }
    
    return self;
}

- (void)setPressed:(BOOL)flag
{
    _isPressed = flag;
    [self setNeedsDisplay:YES];
}

- (void)setStringValue:(CPString)string
{
    [_textField setStringValue:string];
}

- (CPString)stringValue
{
    return [_textField stringValue];
}

- (void)textField
{
    return _textField;
}

- (void)drawRect:(CGRect)rect
{
    if (!CPBrowserIsEngine(CPInternetExplorerBrowserEngine))
        [self _drawRect:rect];
}

- (void)_drawRect:(CGRect)rect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        bounds = [self bounds],
        isSelected = ([self themeState] & CPThemeStateSelected);

    if (_isPressed && isSelected)
        gradient = _selectedPressedHeaderGradient;
    else if (isSelected)
        gradient = _selectedHeaderGradient;
    else if (_isPressed)
        gradient = _pressedHeaderGradient;
    else 
        gradient = _headerGradient;
        
    CGContextBeginPath(context);
    CGContextAddRect(context, bounds);
    CGContextDrawLinearGradient(context, gradient, CGPointMakeZero(), CGPointMake(0, CGRectGetHeight(bounds)), 0);
    CGContextClosePath(context);
}

@end

@implementation CPTableHeaderView : CPView
{
    int _resizedColumn @accessors(readonly, property=resizedColumn);
    int _draggedColumn @accessors(readonly, property=draggedColumn);
    
    float _draggedDistance @accessors(readonly, property=draggedDistance);
    
    CPTableView _tableView @accessors(property=tableView);
    int _pressedColumn;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
        _resizedColumn = CPNotFound;
        _draggedColumn = CPNotFound;
        _draggedDistance = 0.0;
        _pressedColumn = -1;
    }

    return self;
}

- (int)columnAtPoint:(CGPoint)aPoint
{
    if (!CGRectContainsPoint([self bounds], aPoint))
        return CPNotFound;

    // at this point, we can essentially ignore height, because all columns have equal heights
    // and that height is equal to the height of our own bounds, which we know we are inside of

    var index = 0,
        count = [[_tableView tableColumns] count],
        tableSpacing = [_tableView intercellSpacing],
        tableColumns = [_tableView tableColumns],
        leftOffset = 0,
        pointX = aPoint.x;

    for (; index < count; index++)
    {
        var width = [tableColumns[index] width] + tableSpacing.width;

        if (pointX >= leftOffset && pointX < leftOffset + width)
            return index;

        leftOffset += width;
    }

    return CPNotFound;
}

- (CGRect)headerRectOfColumn:(int)aColumnIndex
{
    var tableColumns = [_tableView tableColumns],
        tableSpacing = [_tableView intercellSpacing],
        bounds = [self bounds];

    if (aColumnIndex < 0 || aColumnIndex > [tableColumns count])
        [CPException raise:"invalid" reason:"tried to get headerRectOfColumn: on invalid column"];

    bounds.size.width = [tableColumns[aColumnIndex] width] + tableSpacing.width;

    while (--aColumnIndex >= 0)
        bounds.origin.x += [tableColumns[aColumnIndex] width] + tableSpacing.width;

    return bounds;
}

- (CPRect)_resizeRectBeforeColumn:(CPInteger)column
{
    var rect = [self headerRectOfColumn:column];

    rect.origin.x -= 10;
    rect.size.width = 20;

    return rect;
}

- (void)trackResizeWithEvent:(CPEvent)anEvent
{
    var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
        type = [anEvent type];
        
    if (this.lastLocation == nil) this.lastLocation = location;
        
    if (type === CPLeftMouseUp)
    {
        _resizedColumn = CPNotFound;
        this.lastLocation = nil;
        return;
    }            
    else if (type === CPLeftMouseDragged)
    {	
        var column = [[_tableView tableColumns] objectAtIndex:_resizedColumn];
        var newWidth = [column width] + location.x - this.lastLocation.x;
        [column setWidth:newWidth];
        this.lastLocation = location;
    }
    
    [CPApp setTarget:self selector:@selector(trackResizeWithEvent:) forNextEventMatchingMask:CPLeftMouseDraggedMask | CPLeftMouseUpMask untilDate:nil inMode:nil dequeue:YES];
}

- (void)mouseDown:(CPEvent)theEvent
{
    var location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    var clickedColumn = [self columnAtPoint:location];
    
    if (clickedColumn > 0 && CGRectContainsPoint([self _resizeRectBeforeColumn:clickedColumn], location))
    {
        _resizedColumn = clickedColumn - 1;
        return [self trackResizeWithEvent:theEvent];
    }
    
    if ([[_tableView delegate] respondsToSelector:@selector(tableView:mouseDownInHeaderOfTableColumn:)])
        [[_tableView delegate] tableView:_tableView
          mouseDownInHeaderOfTableColumn:[[_tableView tableColumns] objectAtIndex:clickedColumn]];
    
    _pressedColumn = clickedColumn;
    var headerView = [_tableView._tableColumns[_pressedColumn] headerView];
    if ([headerView respondsToSelector:@selector(setPressed:)])
        [headerView setPressed:YES];
}

- (void)mouseUp:(CPEvent)theEvent
{
    var location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    var clickedColumn = [self columnAtPoint:location];
    
    if (_pressedColumn != -1)
    {
        var headerView = [_tableView._tableColumns[_pressedColumn] headerView];
        if ([headerView respondsToSelector:@selector(setPressed:)])
            [headerView setPressed:NO];

        _pressedColumn = -1;
    }
    
    if ([_tableView allowsColumnSelection])
    {
        if ([theEvent modifierFlags] & CPCommandKeyMask)
        {
            if ([_tableView isColumnSelected:clickedColumn])
                [_tableView deselectColumn:clickedColumn];
            else if ([_tableView allowsMultipleSelection] == YES)
                [_tableView selectColumnIndexes:[CPIndexSet indexSetWithIndex:clickedColumn]  byExtendingSelection:YES];
        }
        else if ([theEvent modifierFlags] & CPShiftKeyMask)
        {
        // should be from clickedColumn to lastClickedColum with extending: direction
            var selectedIndexes = [_tableView selectedColumnIndexes];
            var startColumn = MIN(clickedColumn, [selectedIndexes lastIndex]),
                endColumn = MAX(clickedColumn, [selectedIndexes firstIndex]);
        
            [_tableView selectColumnIndexes:[CPIndexSet indexSetWithIndexesInRange:CPMakeRange(startColumn, endColumn - startColumn + 1)] byExtendingSelection:YES];
        }
        else
            [_tableView selectColumnIndexes:[CPIndexSet indexSetWithIndex:clickedColumn] byExtendingSelection:NO];
    }
}

- (void)layoutSubviews
{
    var tableColumns = [_tableView tableColumns],
        count = [tableColumns count],
        columnRect = [self bounds],
        spacing = [_tableView intercellSpacing];
    
    columnRect.size.height -= 1;  
     
    for (var i = 0; i < count; ++i) 
    {
        var column = [tableColumns objectAtIndex:i],
            headerView = [column headerView];

        columnRect.size.width = [column width] + spacing.width - 1;
        
        [headerView setFrame:columnRect];

        columnRect.origin.x += [column width] + spacing.width;

        if([headerView superview] != self)
            [self addSubview:headerView];
    }
}

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        exposedColumnIndexes = [_tableView columnIndexesInRect:aRect],
        columnsArray = [],
        tableColumns = [_tableView tableColumns],
        exposedTableColumns = _tableView._exposedColumns,
        firstIndex = [exposedTableColumns firstIndex],
        exposedRange = CPMakeRange(firstIndex, [exposedTableColumns lastIndex] - firstIndex + 1);

    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColor(context, [_tableView gridColor]);

    [exposedColumnIndexes getIndexes:columnsArray maxCount:-1 inIndexRange:exposedRange];

    var columnArrayIndex = 0,
        columnArrayCount = columnsArray.length,
        columnMaxX;
    for(; columnArrayIndex < columnArrayCount; ++columnArrayIndex)
    {
        [[tableColumns[columnIndex] headerView] display];

        // grab each column rect and add vertical lines
        var columnIndex = columnsArray[columnArrayIndex],
            columnToStroke = [self headerRectOfColumn:columnIndex];
        columnMaxX = CGRectGetMaxX(columnToStroke);
        
        CGContextMoveToPoint(context, ROUND(columnMaxX) - 0.5, ROUND(CGRectGetMinY(columnToStroke)) - 0.5);
        CGContextAddLineToPoint(context, ROUND(columnMaxX) - 0.5, ROUND(CGRectGetMaxY(columnToStroke)) - 0.5);
        CGContextStrokePath(context);
    }
    
    // draw normal gradient for remaining space
    aRect.origin.x = columnMaxX - 0.5;
    aRect.size.width -= columnMaxX;
    CGContextBeginPath(context);
    CGContextAddRect(context, aRect);
    CGContextClosePath(context);    
    CGContextDrawLinearGradient(context, _headerGradient, CPMakePoint(0,0), CPMakePoint(0, CGRectGetHeight([self bounds])),0);

    // Draw bottom line
    CGContextMoveToPoint(context, 0, CGRectGetHeight([self bounds]) - 0.5);
    CGContextAddLineToPoint(context, CGRectGetMaxX(aRect), CGRectGetHeight([self bounds]) - 0.5);
    CGContextStrokePath(context);
}

@end