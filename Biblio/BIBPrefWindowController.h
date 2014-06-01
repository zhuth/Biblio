//
//  BIBPrefWindowController.h
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-28.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIBPrefWindowController : NSWindowController<NSTableViewDataSource>

-(void)awakeFromNib;
-(void)initWithPrefDict:(NSMutableDictionary *)d;
@property (weak) IBOutlet NSTableView *prefTable;
@end
