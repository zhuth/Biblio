//
//  BIBDataSource.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBDataSource.h"

@implementation BIBDataSource

NSMutableArray* entries;

- (void)initWithEntries:(NSMutableArray*) a_entries {
    entries = a_entries;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return entries.count;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row {
    NSMutableDictionary *o = (NSMutableDictionary*) [entries objectAtIndex:row];
    if (!o) return nil;
    
    return [o objectForKey:aTableColumn.identifier];
}

- (void)add:(NSMutableDictionary *)dict {
    [entries addObject:dict];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSMutableDictionary *dict = (NSMutableDictionary*)[entries objectAtIndex:rowIndex];
    [dict setValue:anObject forKey:aTableColumn.identifier];
    [aTableView reloadData];
}

- (void)remove:(NSUInteger)index {
    [entries removeObjectAtIndex:index];
}

- (NSMutableDictionary*)objectAt:(NSUInteger) index {
    return [entries objectAtIndex:index];
}

@end
