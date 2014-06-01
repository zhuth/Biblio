//
//  BIBPDFView.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-6-1.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface BIBPDFView : PDFView {
    NSTableView *table;
    NSMutableDictionary *dict;
}

- (void)setTable:(NSTableView*)tableView forDict:(NSMutableDictionary*)dic;

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender;


@end
