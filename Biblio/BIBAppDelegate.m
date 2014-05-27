//
//  BIBAppDelegate.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBAppDelegate.h"

@implementation BIBAppDelegate

NSArray* fields;
NSDictionary *plist;
NSURL* filename = nil;

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
    
    // init format strings
    NSString *path=[[NSBundle mainBundle]pathForResource:@"Settings" ofType:@".plist"];
    plist = [[NSDictionary alloc]initWithContentsOfFile:path];
    
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
    bibEntries = [BIBDataSource new];
    [bibEntries initWithEntries:[NSMutableArray new]];
    [_mainTable setDataSource:bibEntries];
    [_mainTable reloadData];
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
    NSMutableAttributedString *akey = [NSMutableAttributedString new];
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
    NSMutableAttributedString *full = [[NSMutableAttributedString new] initWithHTML:htmlData documentAttributes:nil];
    [self writeToPasteboard:full];
}

- (IBAction)_prefMenuItemClick:(id)sender {

}

-(NSString*) formatString:(NSString*) format dict:(NSMutableDictionary*) dict {
    format = [NSString stringWithFormat:@"%@{", format];
    NSMutableString *s = [NSMutableString new];
    NSInteger lastPos = 0;
    for (NSInteger i = 0 ; i < [format length]; ++i) {
        if ([format characterAtIndex:i] == '{') {
            [s appendString:[format substringWithRange:NSMakeRange(lastPos, i - lastPos)]];
            lastPos = ++i;
            while (i < [format length] && [format characterAtIndex:i] != '}') ++i;
            if (i >= [format length]) break;
            NSString *key = [format substringWithRange:NSMakeRange(lastPos, i - lastPos)];
            NSString *val = [dict objectForKey:key];
            if (val)
                [s appendString:val];
            else {
                NSMutableString* authors = [dict objectForKey:@"author"];
                if ([key isEqualTo:@"authors"]) {
                    [authors replaceOccurrencesOfString:@" and " withString:@"," options:NSLiteralSearch range:NSMakeRange(0, [authors length])];
                    [s appendString:authors];
                } else if ([key isEqualTo:@"author1"]) {
                    NSString* a1 = [[authors componentsSeparatedByString:@" and "] objectAtIndex:0];
                    [s appendString:a1];
                }
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
    [NSApp terminate:self];
}

@end
