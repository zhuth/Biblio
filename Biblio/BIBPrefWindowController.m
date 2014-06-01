//
//  BIBPrefWindowController.m
//  Biblio
//
//  Created by Zhu Tianhua on 14-5-28.
//  Copyright (c) 2014年 zth. All rights reserved.
//

#import "BIBPrefWindowController.h"
#import "BIBDIctionaryTableSource.h"

@implementation BIBPrefWindowController

NSMutableDictionary* plist;
BIBDIctionaryTableSource* bfs;

- (IBAction)plusButtonClick:(id)sender {
    [bfs add:@"" forKey:@"(new)"];
    [_prefTable reloadData];
}

- (IBAction)minusButtonClick:(id)sender {
    if ([_prefTable selectedRow] >= 0) {
        if ([[NSAlert alertWithMessageText:@"Sure to remove this setting?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"This operation is unreversable."] runModal] == NSAlertDefaultReturn)
            [bfs remove:[_prefTable selectedRow]];
    }
    [_prefTable reloadData];
}

-(void)initWithPrefDict:(NSMutableDictionary *)d{
    plist = d;
    bfs = [BIBDIctionaryTableSource new];
    [bfs initWithDictionary:plist];
    [_prefTable setDataSource: bfs];

}

-(void)awakeFromNib{
    [_prefTable reloadData];
}

@end
