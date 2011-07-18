/*
 * AppController.j
 * CPMenuPerformance
 *
 * Created by You on July 18, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@import "MyMenu.j"

@implementation AppController : CPObject
{
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    var popUpButton = [[CPPopUpButton alloc] initWithFrame:CGRectMakeZero()];

    [popUpButton setMenu:[self _createMenuWithTitle:@"Popup"]];
    [popUpButton sizeToFit];

    [popUpButton setFrameSize:CGSizeMake(100.0, CGRectGetHeight([popUpButton bounds]))];
    [popUpButton setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [popUpButton setCenter:[contentView center]];

    [contentView addSubview:popUpButton];

    var contextMenu = [self _createMenuWithTitle:@"Context"];
    [contextMenu setShowsStateColumn:NO];
    [contentView setMenu:contextMenu];

    // Uncomment the following line to turn on the standard menu bar.
    [CPMenu setMenuBarVisible:YES];

    var mainMenuItem = [[CPMenuItem alloc] initWithTitle:@"Long" action:nil keyEquivalent:nil];
    [mainMenuItem setSubmenu:[self _createMenuWithTitle:@"Long"]];
    [[CPApp mainMenu] addItem:mainMenuItem];

    [theWindow orderFront:self];
}

- (void)menuWillOpen:(CPMenu)theMenu
{
    CPLog.debug(@"menuWillOpen: %@", [theMenu title]);
}

- (void)menuDidClose:(CPMenu)theMenu
{
    CPLog.debug(@"menuDidClose: %@", [theMenu title]);
}

- (BOOL)validateMenuItem:(CPMenuItem)theMenuItem
{
    var validated = Math.random() * 1 > 0.5;
    // CPLog.debug(@"%@ enabled: %@", [theMenuItem title], validated)
    return validated;
}

- (CPMenu)_createMenuWithTitle:(CPString)theTitle
{
    var menu = [[MyMenu alloc] initWithTitle:theTitle];
    for (var i = 0; i < 100; i++)
        [menu addItemWithTitle:@"Item " + i action:@selector(someAction:) keyEquivalent:@"" + i];

    [menu setDelegate:self];
    return menu;
}

- (void)someAction:(id)theSender
{
    CPLog.debug(@"someAction: %@", [theSender title]);
}

@end
