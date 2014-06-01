//
//  BIBAppDelegate.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBAppDelegate.h"
#import "BIBPrefWindowController.h"
#import "BIBDictionaryTableSource.h"

@implementation BIBAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self _newMenuItemClick:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
    NSString *sFields = @"key;type;author;title;journal;volume;year;month;number;pages;booktitle;chapter;publisher;address;annote;crossref;date;doi;edition;editor;eprint;howpublished;institution;note;organization;school;series;url";
    fields = [sFields componentsSeparatedByString:@";"];
    
    for(NSString *field in fields) {
        NSTableColumn *keyTableColumn = [[NSTableColumn new] initWithIdentifier:[field copy]];
        [[keyTableColumn headerCell] setStringValue:[field capitalizedString]];
        [_mainTable addTableColumn:keyTableColumn];
    }
    
    [_mainTable setDataSource:bibEntries];
    [_mainTable setTarget:self];
    [_mainTable setDoubleAction:@selector(rowDoubleClicked:)];
    
    [_mainTable registerForDraggedTypes:[NSArray arrayWithObject:(NSString*)kUTTypeFileURL]];
    
    // init format strings
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Settings" ofType:@".plist"];
    plist = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
    bibEntry = [BIBDIctionaryTableSource alloc];
    
    [_selTable setDataSource:bibEntry];
    
    // init pdfview
    [_pdfview setAllowsDragging:YES];
    
    // Insert code here to initialize your application
}

- (NSString*)getLocale:(NSMutableDictionary *)d{
    NSString* lang = [d objectForKey:@"lang"];
    if (lang && [lang isEqualTo:@"chinese"]) return @"zh";
    lang = [d objectForKey:@"title"];
    unichar uc = [lang characterAtIndex:0];
    if ((uc >= 'a' && uc <= 'z') || (uc >= 'A' && uc <= 'Z')) return @"en";
    return @"zh";
}

- (IBAction)_newMenuItemClick:(id)sender {
    filename = nil;
    bibEntries = [[BIBDataSource alloc] init];
    [bibEntries initWithEntries:[NSMutableArray new]];
    [_mainTable setDataSource:bibEntries];
    [_mainTable reloadData];
    [_mainTable setDelegate:self];
}

- (IBAction)rowDoubleClicked:(id)sender
{
    NSInteger row = [_mainTable selectedRow];
    if (row < 0) return;
    NSMutableDictionary *dict = [bibEntries objectAt:row];
    if (!dict) return;
    NSString *pdf = [dict valueForKey:@"pdf"];
    if (!pdf) return;
    [[NSWorkspace sharedWorkspace] openFile:[[NSURL URLWithString:pdf] path]];
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    NSInteger row = [_mainTable selectedRow];
    
    if (row == -1) {
        //do stuff for the no-rows-selected case
    }
    else {
        NSMutableDictionary *ent = [bibEntries objectAt:row];
        [bibEntry initWithDictionary:ent];
        [_selTable reloadData];
        [_pdfview setTable:_selTable forDict:ent];
        NSString* pdf = [ent objectForKey:@"pdf"];
        if (pdf) {
            pdfdoc = [[PDFDocument alloc] initWithURL:[[NSURL alloc] initWithString:pdf]];
            [_pdfview setDocument:pdfdoc];
        }
        else
            [_pdfview setDocument:nil];
        // do stuff for the selected row
    }
    
}

- (IBAction)_openMenuItemClick:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject: @"bib"]];
    if ([openPanel runModal] == NSOKButton){
           NSURL *fileURL = [openPanel URL];
        NSError *error;
        NSString *content = [[NSString alloc]
                                         initWithContentsOfURL:fileURL
                                         encoding:NSUTF8StringEncoding
                                         error:&error];
            NSLog(@"%@", fileURL);
            // we now just support bibtex file.
        [self parseBibcontent:content];
        
        filename = fileURL;
        
        [_mainTable reloadData];
    }
}

- (IBAction)_deleteMenuItemClick:(id)sender {
    NSInteger i = [_mainTable selectedRow];
    if (i < 0 || i > [bibEntries numberOfRowsInTableView:nil]) return;
    
    NSAlert *alert= [NSAlert alertWithMessageText:@"Are you sure to delete this item?" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Are you sure to delete this item?"];
    if ([alert runModal]!=NSAlertDefaultReturn) return;
    
    [_mainTable beginUpdates];
    [_mainTable removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:NSTableViewAnimationEffectFade];
    [bibEntries remove:i];
    [_mainTable endUpdates];
    
}

- (IBAction)_pasteMenuItemClick:(id)sender {
    NSString *s = [self readFromPasteboard];
    if (s == nil) return;
    [self parseBibcontent:s];
    [_mainTable reloadData];
}

- (IBAction)_saveMenuItemClick:(id)sender {
    if (filename== nil) [self _saveAsMenuItemClick:sender];
    else [self saveBib];
}

- (IBAction)_saveAsMenuItemClick:(id)sender {
    NSSavePanel * savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject: @"bib"]];
    if ([savePanel runModal] == NSOKButton){
        filename = [savePanel URL];
    } else {
        return;
    }
    [self saveBib];
}

- (void)writeToPasteboard:(NSMutableAttributedString*) string{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    NSData* myStringData = [string RTFDFromRange:NSMakeRange(0, string.length)
                              documentAttributes:nil];
    [pb setString:[string string] forType:NSStringPboardType];
    [pb setData:myStringData forType:NSRTFDPboardType];
}

- (NSString*)readFromPasteboard {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [pb types];
    if ([types containsObject:NSStringPboardType]) {
        NSString *value = [pb stringForType:NSStringPboardType];
        return value;
    }
    
    return nil;
}

-(void)saveBib {
    NSMutableString* zStr = [NSMutableString new];
    
    NSInteger count = [bibEntries numberOfRowsInTableView:nil];
    
    for(NSUInteger i; i < count; ++i) {
        NSMutableDictionary *d = [bibEntries objectAt:i];
        [zStr appendFormat:@"@%@{%@", [d objectForKey:@"type"], [d objectForKey:@"key"]];
        NSEnumerator *enumerator = [d keyEnumerator];
        id key;
        
        while ((key = [enumerator nextObject])) {
            if (![key isEqualToString:@"key"] && ![key isEqualToString:@"type"]) {
                [zStr appendFormat:@",\n%@ = {%@}", key, [d objectForKey:key]];
            }
        }
        [zStr appendString:@"}\n"];
    }
    
    NSLog(@"%@ ==> %@", zStr, filename);
    
    BOOL zBoolResult = [zStr writeToURL:filename
                             atomically:YES
                               encoding:NSUTF8StringEncoding
                                  error:NULL];
    if (! zBoolResult) {
        NSLog(@"writeUsingSavePanel failed");
    }
}

- (NSMutableDictionary *) currentItem {
    if ([_mainTable selectedRow] < 0) return nil;
    return [bibEntries objectAt:[_mainTable selectedRow]];
}

- (IBAction)_copyKeyMenuItemClick:(id)sender {
    NSMutableDictionary *d = [self currentItem];
    if (!d) return;
    NSString *key = [self formatString:[plist objectForKey:[NSString stringWithFormat:@"%@-key", [self getLocale:d]]]
                                  dict:d];
    NSMutableAttributedString *akey = [[NSMutableAttributedString alloc] init];
    akey = [akey initWithString:key];
    [self writeToPasteboard:akey];
}

- (IBAction)_copyMenuItemClick:(id)sender {
    NSMutableDictionary *d = [self currentItem];
    if (!d) return;
    NSString *html = [plist objectForKey:[NSString stringWithFormat:@"%@-%@", [self getLocale:d], [d objectForKey:@"type"]]];
    if (!html) {
        html = [plist objectForKey:[NSString stringWithFormat:@"%@-default", [self getLocale:d]]];
    }
    if (!html) return;
    html = [self formatString:html dict:d];
    NSData *htmlData = [html dataUsingEncoding:NSUnicodeStringEncoding];
    NSMutableAttributedString *full = [[[NSMutableAttributedString alloc] init] initWithHTML:htmlData documentAttributes:nil];
    [self writeToPasteboard:full];
}

- (IBAction)_prefMenuItemClick:(id)sender {
    prefWindowControl = [[BIBPrefWindowController alloc] initWithWindowNibName:@"Preferences"];
    [prefWindowControl showWindow:self];
    [prefWindowControl initWithPrefDict:plist];
}

- (IBAction)_findMenuItemClick:(id)sender {
    NSString *sf = [self input:@"Search for..." defaultValue:@""];
    if (!sf || [sf isEqualTo:@""]) return;
    
    [_mainTable deselectAll:nil];
    NSInteger count = [bibEntries numberOfRowsInTableView:nil];
    for(NSInteger i = 0; i < count; ++i)
    {
        for(NSTableColumn *col in [_mainTable tableColumns]) {
            NSString* p = [bibEntries tableView:nil objectValueForTableColumn:col row:i];
            if (!p) continue;
            if ([p rangeOfString:sf].location != NSNotFound) {
                [_mainTable selectRowIndexes:[[NSIndexSet alloc] initWithIndex:i]  byExtendingSelection:YES];
            }
        }
    }
}

- (IBAction)_newEntryMenuItemClick:(id)sender {
    [bibEntries add:[NSMutableDictionary new]];
    [_mainTable reloadData];
}

- (NSString *)input: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %ld", (long)button);
        return nil;
    }
}

-(NSString*) formatString:(NSString*) format dict:(NSMutableDictionary*) dict {
    format = [NSString stringWithFormat:@"%@{", format];
    NSMutableString *s = [NSMutableString new];
    NSInteger lastPos = 0;
    NSString *locale = [self getLocale:dict];
    
    for (NSInteger i = 0 ; i < [format length]; ++i) {
        if ([format characterAtIndex:i] == '{') {
            [s appendString:[format substringWithRange:NSMakeRange(lastPos, i - lastPos)]];
            lastPos = ++i;
            while (i < [format length] && [format characterAtIndex:i] != '}') ++i;
            if (i >= [format length]) break;
            NSString *key = [format substringWithRange:NSMakeRange(lastPos, i - lastPos)];
            
            NSString* authors = [[[dict objectForKey:@"author"]
                                  stringByReplacingOccurrencesOfString:@"{" withString:@""] stringByReplacingOccurrencesOfString:@"}" withString:@""];
            if ([key isEqualTo:@"authors"]) {
                NSArray *aus = [authors componentsSeparatedByString:@" and "];
                int counter = 0;
                for(NSString *au in aus) {
                    if (counter == 0) {
                        [s appendString:au];
                    } else {
                        if ([locale isEqualToString:@"en"]) {
                            NSArray *auf = [[au stringByAppendingString:@","] componentsSeparatedByString:@","];
                            [s appendFormat:@", %@ %@",
                             [(NSString*)[auf objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]],
                             [(NSString*)[auf objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n\r"]]];
                        }
                        else {
                            NSString *aut = [au stringByReplacingOccurrencesOfString:@", " withString:@"、"];
                            [s appendFormat:@"、%@", aut];
                        }
                    }
                    ++counter;
                }
            } else if ([key isEqualTo:@"author1"]) {
                NSString* a1 = [[authors componentsSeparatedByString:@" and "] objectAtIndex:0];
                NSRange rg = [a1 rangeOfString:@","];
                if (rg.location != NSNotFound)
                    a1 = [a1 substringToIndex:rg.location];
                [s appendString:a1];
            } else if ([key isEqualTo:@"pages"]) {
                NSString *pages = [[dict objectForKey:key] stringByReplacingOccurrencesOfString:@"--" withString:@"-"];
                if (pages) {
                if ([locale isEqualToString:@"en"]){
                    if ([pages rangeOfString:@"-"].location != NSNotFound)
                        [s appendString:@"pp."];
                    else
                        [s appendString:@"p."];
                    [s appendString:pages];
                } else {
                    [s appendFormat:@"第%@页", pages];
                }
                }
            } else {
                NSString *val = [dict objectForKey:key];
                if (val)
                    [s appendString:val];
            }
            lastPos = i+1;
        }
    }
    return s;
}

-(void)parseBibcontent:(NSString*)content {
    
    content = [content stringByAppendingString:@"@"];
    
    BOOL whitespaceBefore = NO, fieldFinished = NO;
    int inBracket = 0;
    
    NSMutableString *sField = [NSMutableString new];
    NSMutableString *sValue = [NSMutableString new];
    NSMutableDictionary *entry = nil;
    
    for (NSUInteger i = 0; i < [content length]; ++i) {
        unichar ch = [content characterAtIndex:i];
        switch (ch) {
            case ' ':
            case '\r':
            case '\n':
            case '\t':
                if (!whitespaceBefore) {
                    whitespaceBefore=YES;
                    if (inBracket > 1) [sValue appendString:@" "];
                }
                break;
            case '{':
                whitespaceBefore = NO;
                if (inBracket >= 2) {
                    [sValue appendString:@"{"];
                } else if (inBracket == 0) {
                    // save type
                    [entry setValue:[sValue lowercaseString] forKeyPath:sField];
                    fieldFinished = YES;
                    sField = [NSMutableString stringWithString:@"key"];
                    sValue =  [NSMutableString new];
                }
                ++inBracket;
                break;
            case '}':
                whitespaceBefore = NO;
                if (inBracket > 2) {
                    [sValue appendString:@"}"];
                } else if (inBracket == 1) {
                    [entry setValue:sValue forKeyPath:[sField lowercaseString]];
                    NSLog(@"fv: %@ = %@", [sField lowercaseString], sValue);
                }
                if (inBracket> 0) --inBracket;
                break;
            case '@':
                whitespaceBefore = NO;
                if (inBracket == 0) {
                    if (entry != nil) {
                        [bibEntries add:entry];
                    }
                    entry = [NSMutableDictionary new];
                    [entry setValue:[NSString stringWithFormat:@"k%ld", time(0)] forKey:@"key"];
                    NSLog(@"new entry");
                    sField = [NSMutableString stringWithString:@"type"];
                    sValue = [NSMutableString new];
                    fieldFinished = YES;
                }
                else [sValue appendString:@"@"];
                break;
            case '%':
                whitespaceBefore = NO;
                while (i < [content length] && [content characterAtIndex:i] != '\r' && [content characterAtIndex:i] != '\n')
                    ++i;
                --i;
                break;
            case '=':
                whitespaceBefore = NO;
                if (inBracket == 1) {
                    fieldFinished = YES;
                } else {
                    [sValue appendFormat:@"="];
                }
                break;
            case ',':
                whitespaceBefore = NO;
                if (inBracket == 1) {
                    // save current field
                    [entry setValue:sValue forKeyPath:[sField lowercaseString]];
                    NSLog(@"fv: %@ = %@", [sField lowercaseString], sValue);
                    fieldFinished = NO;
                    sField = [NSMutableString new];
                    sValue = [NSMutableString new];
                } else {
                    [sValue appendFormat:@","];
                }
                break;
            default:
                whitespaceBefore = NO;
                if (!fieldFinished)
                    [sField appendFormat:@"%C", ch];
                else
                    [sValue appendFormat:@"%C", ch];
                break;
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Settings" ofType:@".plist"];
    [plist writeToFile:path atomically:YES];
    [NSApp terminate:self];
}

@end
