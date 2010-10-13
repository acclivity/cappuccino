@import <AppKit/CPTableHeaderView.j>

@implementation ESTableHeaderView : CPTableHeaderView
{
}

- (CPMenu)menuForEvent:(CPEvent)anEvent
{
    var tableColumns = [[self tableView] tableColumns],
        columnCount = [tableColumns count],
        columnIndex = 0;

    var contextMenu = [[CPMenu alloc] initWithTitle:@""];
    for (; columnIndex < columnCount; columnIndex++)
    {
        var tableColumn = [tableColumns objectAtIndex:columnIndex],
            headerView = [tableColumn headerView],
            menuItem = [[CPMenuItem alloc] initWithTitle:[headerView stringValue] action:@selector(updateVisibleColumns:) keyEquivalent:nil];
        
        // We explicetly don't want to use the responder chain for this event
        [menuItem setTarget:self];
        [menuItem setState:[tableColumn isHidden] ? CPOffState : CPOnState];
        [menuItem setRepresentedObject:tableColumn];
        
        [contextMenu addItem:menuItem];
    }
    
    return contextMenu;
}

- (void)updateVisibleColumns:(id)aSender
{
    var tableColumn = [aSender representedObject];
    [tableColumn setHidden:![tableColumn isHidden]];
}

@end
