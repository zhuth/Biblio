//
//  BIBAppDelegate.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BIBDataSource.h"

@interface BIBAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet BIBDataSource *bibEntries;
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSScrollView *tableScrollView;
@property (weak) IBOutlet NSTableView *mainTable;
@property (weak) IBOutlet NSTableHeaderView *tableHeader;
- (IBAction)_deleteMenuItemClick:(id)sender;
- (IBAction)_pasteMenuItemClick:(id)sender;
- (IBAction)_copyKeyMenuItemClick:(id)sender;
- (IBAction)_copyMenuItemClick:(id)sender;
- (void)parseBibcontent:(NSString*)content;
@end
