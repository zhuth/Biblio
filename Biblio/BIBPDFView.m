//
//  BIBPDFView.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-6-1.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBPDFView.h"

@implementation BIBPDFView

- (void)setTable:(NSTableView*)tableView forDict:(NSMutableDictionary*)dic {
    table = tableView;
    dict = dic;
}

-(void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    if (table == nil || dict == nil) return;
    [dict setValue:[[self document].documentURL absoluteString] forKey:@"pdf"];
    [table reloadData];
}

@end
