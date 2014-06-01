//
//  BIBDIctionaryTableSource.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-29.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIBDIctionaryTableSource : NSObject<NSTableViewDataSource> {
    NSMutableDictionary *d;
}

- (void)initWithDictionary:(NSMutableDictionary*) entries;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row;

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

- (void)add:(NSString*)value forKey:(NSString*)key;

- (void)remove:(NSUInteger) index;

@end
