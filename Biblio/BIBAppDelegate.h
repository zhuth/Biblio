//
//  BIBAppDelegate.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "BIBDataSource.h"
#import "BIBPrefWindowController.h"
#import "BIBDictionaryTableSource.h"
#import "BIBPDFView.h"

@interface BIBAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate> {
    IBOutlet BIBDataSource *bibEntries;
    NSArray* fields;
    NSMutableDictionary *plist;
    BIBDIctionaryTableSource *bibEntry;
    NSURL* filename;
    BIBPrefWindowController *prefWindowControl;
    PDFDocument *pdfdoc;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSScrollView *tableScrollView;
@property (weak) IBOutlet NSTableView *selTable;
@property (weak) IBOutlet NSTableView *mainTable;
@property (weak) IBOutlet BIBPDFView *pdfview;


@property (weak) IBOutlet NSTableHeaderView *tableHeader;
- (IBAction)_deleteMenuItemClick:(id)sender;
- (IBAction)_pasteMenuItemClick:(id)sender;
- (IBAction)_copyKeyMenuItemClick:(id)sender;
- (IBAction)_copyMenuItemClick:(id)sender;
- (IBAction)_prefMenuItemClick:(id)sender;
- (IBAction)_newEntryMenuItemClick:(id)sender;
- (void)parseBibcontent:(NSString*)content;
@end
