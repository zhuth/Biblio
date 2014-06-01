//
//  BIBDIctionaryTableSource.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-29.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBDIctionaryTableSource.h"

@implementation BIBDIctionaryTableSource

- (void)initWithDictionary:(NSMutableDictionary*) entries {
    d = entries;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return[d count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row{
    if ([[aTableColumn identifier] isEqualTo:@"key"])
        return [[d allKeys] objectAtIndex:row];
    else
        return [[d allValues] objectAtIndex:row];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *key = [[d allKeys] objectAtIndex:rowIndex];
    NSString *value = [[d objectForKey:key] copy];
    if ([aTableColumn.identifier isEqualToString:@"value"]) {
        [d setValue:anObject forKey:key];
    } else {
        [d removeObjectForKey:key];
        [d setValue:value forKey:anObject];
    }
    [aTableView reloadData];
}

- (void)add:(NSString*)value forKey:(NSString*)key {
    [d setValue:value forKey:key];
}

- (void)remove:(NSUInteger) index {
    [d removeObjectForKey:[[d allKeys] objectAtIndex:index]];
}


@end
