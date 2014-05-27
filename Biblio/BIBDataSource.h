//
//  BIBDataSource.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIBDataSource : NSObject<NSTableViewDataSource> {
    NSMutableArray* entries;
}

- (void)initWithEntries:(NSMutableArray*) entries;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row;

- (void)add:(NSMutableDictionary *)dict;

- (void)remove:(NSUInteger) index;

- (NSMutableDictionary*)objectAt:(NSUInteger) index;

@end
