//
//  PBGitCommit.m
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBGitCommit.h"
#import "PBGitDefaults.h"


NSString * const kGitXCommitType = @"commit";


@implementation PBGitCommit

@synthesize repository, subject, timestamp, author, parentShas, nParents, sign, lineInfo;

- (NSArray *) parents
{
	if (nParents == 0)
		return NULL;

	int i;
	NSMutableArray *p = [NSMutableArray arrayWithCapacity:nParents];
	for (i = 0; i < nParents; ++i)
	{
		char *s = git_oid_mkhex(parentShas + i);
		[p addObject:[NSString stringWithUTF8String:s]];
		free(s);
	}
	return p;
}

- (NSDate *)date
{
	return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

- (NSString *) dateString
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M:%S" allowNaturalLanguage:NO];
	return [formatter stringFromDate: self.date];
}

- (NSArray*) treeContents
{
	return self.tree.children;
}

- (git_oid *)sha
{
	return &sha;
}

+ (id)commitWithRepository:(PBGitRepository*)repo andSha:(git_oid)newSha
{
	return [[[self alloc] initWithRepository:repo andSha:newSha] autorelease];
}

- (id)initWithRepository:(PBGitRepository*) repo andSha:(git_oid)newSha
{
	details = nil;
	repository = repo;
	sha = newSha;
	return self;
}

- (NSString *)realSha
{
	if (!realSHA) {
		char *hex = git_oid_mkhex(&sha);
		realSHA = [NSString stringWithUTF8String:hex];
		free(hex);
	}

	return realSHA;
}

- (BOOL)isOnSameBranchAs:(PBGitCommit *)other
{
	if (!other)
		return NO;

	NSString *mySHA = [self realSha];
	NSString *otherSHA = [other realSha];

	if ([otherSHA isEqualToString:mySHA])
		return YES;

	NSString *commitRange = [NSString stringWithFormat:@"%@..%@", mySHA, otherSHA];
	NSString *parentsOutput = [repository outputForArguments:[NSArray arrayWithObjects:@"rev-list", @"--parents", @"-1", commitRange, nil]];
	if ([parentsOutput isEqualToString:@""]) {
		return NO;
	}

	NSString *mergeSHA = [repository outputForArguments:[NSArray arrayWithObjects:@"merge-base", mySHA, otherSHA, nil]];
	if ([mergeSHA isEqualToString:mySHA] || [mergeSHA isEqualToString:otherSHA])
		return YES;

	return NO;
}

- (BOOL)isOnHeadBranch
{
	return [self isOnSameBranchAs:[repository headCommit]];
}

// FIXME: Remove this method once it's unused.
- (NSString*) details
{
	return @"";
}

- (NSString *) patch
{
	if (_patch != nil)
		return _patch;

	NSString *p = [repository outputForArguments:[NSArray arrayWithObjects:@"format-patch",  @"-1", @"--stdout", [self realSha], nil]];
	// Add a GitX identifier to the patch ;)
	_patch = [[p substringToIndex:[p length] -1] stringByAppendingString:@"+GitX"];
	return _patch;
}

- (PBGitTree*) tree
{
	return [PBGitTree rootForCommit: self];
}

- (void)addRef:(PBGitRef *)ref
{
	if (!self.refs)
		self.refs = [NSMutableArray arrayWithObject:ref];
	else
		[self.refs addObject:ref];
}

- (void)removeRef:(id)ref
{
	if (!self.refs)
		return;

	[self.refs removeObject:ref];
}

- (BOOL)hasRef:(PBGitRef *)ref
{
	if (!self.refs)
		return NO;

	for (PBGitRef *existingRef in self.refs)
		if ([existingRef isEqual:ref])
			return YES;

	return NO;
}

- (NSMutableArray *)refs
{
	return [[repository refs] objectForKey:[self realSha]];
}

- (void) setRefs:(NSMutableArray *)refs
{
	[[repository refs] setObject:refs forKey:[self realSha]];
}

- (void)finalize
{
	free(parentShas);
	[super finalize];
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
	return NO;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
	return NO;
}


#pragma mark <PBGitRefish>

- (NSString *)refishName
{
	return [self realSha];
}

- (NSString *)shortName
{
	return [[self realSha] substringToIndex:10];
}

- (NSString *)refishType
{
	return kGitXCommitType;
}

@end
