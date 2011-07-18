@import <AppKit/CPMenu.j>

@implementation MyMenu : CPMenu
{
}

- (void)update
{
    CPLog.debug(@"update: %@", [self title]);
    [super update];
}

@end