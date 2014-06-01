//
//  BIBDataSource.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-26.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface BIBDataSource : NSObject<NSTableViewDataSource> {
    NSMutableArray* _entries;
}

- (void)initWithEntries:(NSMutableArray*) entries;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)row;

- (void)add:(NSMutableDictionary *)dict;

- (void)remove:(NSUInteger) index;

- (NSMutableDictionary*)objectAt:(NSUInteger) index;

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation;

@end
