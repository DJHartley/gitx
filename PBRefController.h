//
//  PBLabelController.h
//  GitX
//
//  Created by Pieter de Bie on 21-10-08.
//  Copyright 2008 Pieter de Bie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PBGitHistoryController.h"
#import "PBCommitList.h"
#import "PBGitRef.h"
#import "PBGitCommit.h"
#import "PBRefContextDelegate.h"

@class PBRefMenuItem;

@interface PBRefController : NSObject <PBRefContextDelegate> {
	IBOutlet __weak PBGitHistoryController *historyController;
	IBOutlet NSArrayController *commitController;
	IBOutlet PBCommitList *commitList;

	IBOutlet NSPopUpButton *branchPopUp;
}

- (void)removeRef:(PBRefMenuItem *)sender;
- (void)checkoutRef:(PBRefMenuItem *)sender;
- (void)tagInfo:(PBRefMenuItem *)sender;

- (void)createBranch:(PBRefMenuItem *)sender;

- (NSArray *)menuItemsForRef:(PBGitRef *)ref;
- (NSArray *)menuItemsForCommit:(PBGitCommit *)commit;

- (void) changeBranch:(NSMenuItem *)sender;
- (void) selectCurrentBranch;
- (void) updateBranchMenu;

@end
