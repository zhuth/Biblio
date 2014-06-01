//
//  BIBDataSource.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBDataSource.h"

@implementation BIBDataSource

- (void)initWithEntries:(NSMutableArray*) a_entries {
    _entries = a_entries;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _entries.count;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row {
    NSMutableDictionary *o = (NSMutableDictionary*) [_entries objectAtIndex:row];
    if (!o) return nil;
    
    return [o objectForKey:aTableColumn.identifier];
}

- (void)add:(NSMutableDictionary *)dict {
    [_entries addObject:dict];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSMutableDictionary *dict = (NSMutableDictionary*)[_entries objectAtIndex:rowIndex];
    [dict setValue:anObject forKey:aTableColumn.identifier];
    [aTableView reloadData];
}

- (void)remove:(NSUInteger)index {
    [_entries removeObjectAtIndex:index];
}

- (NSMutableDictionary*)objectAt:(NSUInteger) index {
    return [_entries objectAtIndex:index];
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    //get the file URLs from the pasteboard
    NSPasteboard* pb = info.draggingPasteboard;
    
    //list the file type UTIs we want to accept
    NSArray* acceptedTypes = [NSArray arrayWithObject:(NSString*)kUTTypePDF];
    
    NSArray* urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                      options:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
                                               acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
                                               nil]];
    
    if(urls.count > 0) return NSDragOperationCopy;
    
    return NSDragOperationNone;
}

NSMutableString *tmpStr;

void arrayCallback(CGPDFScannerRef inScanner, void *userInfo)
{
    CGPDFArrayRef array;
    
    bool success = CGPDFScannerPopArray(inScanner, &array);
    
    for(size_t n = 0; n < CGPDFArrayGetCount(array); n += 2)
    {
        if(n >= CGPDFArrayGetCount(array))
            continue;
        
        CGPDFStringRef string;
        success = CGPDFArrayGetString(array, n, &string);
        if(success)
        {
            NSString *data = (__bridge NSString *)CGPDFStringCopyTextString(string);
            [tmpStr appendFormat:@"%@", data];
        }
    }
}

void stringCallback(CGPDFScannerRef inScanner, void *userInfo)
{
    CGPDFStringRef string;
    
    bool success = CGPDFScannerPopString(inScanner, &string);
    
    if(success)
    {
        NSString *data = (__bridge NSString *)CGPDFStringCopyTextString(string);
        [tmpStr appendFormat:@" %@", data];
    }
}


- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    NSPasteboard* pb = info.draggingPasteboard;
    NSArray* acceptedTypes = [NSArray arrayWithObject:(NSString*)kUTTypePDF];
    NSArray* urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                      options:[NSDictionary dictionaryWithObjectsAndKeys:
                                               [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
                                               acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
                                               nil]];
    
    CGPDFOperatorTableRef myTable;
    
    myTable = CGPDFOperatorTableCreate();
    
    CGPDFOperatorTableSetCallback(myTable, "TJ", arrayCallback);
    CGPDFOperatorTableSetCallback(myTable, "Tj", stringCallback);    
    
    for(NSURL *url in urls) {
        NSMutableDictionary *entry = [NSMutableDictionary new];

        tmpStr = [NSMutableString new];
        CGPDFDocumentRef myDocument;
        myDocument = CGPDFDocumentCreateWithURL((CFURLRef)url);// 1
        if (myDocument == NULL) {// 2
            NSLog(@"can't open `%@'.", url.absoluteString);
            return NO;
        }
        if (CGPDFDocumentIsEncrypted (myDocument)) {// 3
            if (!CGPDFDocumentUnlockWithPassword (myDocument, "")) {
                //....
            }
        }
        if (!CGPDFDocumentIsUnlocked (myDocument)) {// 4
            NSLog(@"can't unlock `%@'.", url.absoluteString);
            CGPDFDocumentRelease(myDocument);
            return NO;
        }
        if (CGPDFDocumentGetNumberOfPages(myDocument) == 0) {// 5
            CGPDFDocumentRelease(myDocument);
            return EXIT_FAILURE;
        }
        CGPDFPageRef myPage = CGPDFDocumentGetPage(myDocument, 1);
        CGPDFContentStreamRef myContentStream = CGPDFContentStreamCreateWithPage (myPage);
        CGPDFScannerRef myScanner = CGPDFScannerCreate (myContentStream, myTable, NULL);
        CGPDFScannerScan (myScanner);// 5
        CGPDFPageRelease (myPage);// 6
        CGPDFScannerRelease (myScanner);// 7
        CGPDFContentStreamRelease (myContentStream);
        
        [entry setValue:tmpStr forKey:@"title"];
        [entry setValue:[url absoluteString] forKey:@"pdf"];
        [entry setValue:[NSString stringWithFormat:@"k%ld", time(0)] forKey:@"key"];
        
        BIBDataSource* bib = (BIBDataSource*)[tableView dataSource];
        [bib add:entry];
        [tableView reloadData];
    }
    
    return YES;
}

@end
