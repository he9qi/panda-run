//
//  UserData.m
//  panda-run
//
//  Created by Qi He on 12-6-30.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "UserData.h"

#define DEFAULT_GROUP @"ContactDelegate"

@implementation UserData

@synthesize name  = _name;
@synthesize group = _group;
@synthesize ccObj = _ccObj;

+ (id) userDataWithName:(NSString*)name;{
	return [[[self alloc] initWithName:name] autorelease];
}

- (id) initWithName:(NSString *)name
{
  return [self initWithName:name Group:DEFAULT_GROUP];
}

- (id) initWithName:(NSString *)name Delegate:(id<ContactDelegate>)delegate
{
  return [self initWithName:name Group:DEFAULT_GROUP Delegate:delegate];
}

- (id) initWithName:(NSString *)name Group:(NSString *)group
{
  return [self initWithName:name Group:DEFAULT_GROUP Delegate:nil];
}

- (id) initWithName:(NSString *)name Group:(NSString *)group Delegate:(id<ContactDelegate>)delegate
{
  if ((self = [super init])) {
    _name  = name;
    _group = group;
    _ccObj = delegate;
	}
//  CCLOG(@"user data=%@, group=%@, ccobj=%@", _name, _group, self.ccObj);
	return self;
}

- (bool) isA:(NSString *)objName
{
  return !!self.name && [self.name isEqualToString:objName];
}

- (bool) belongsTo:(NSString *)groupName
{
  return !!self.group && [self.group isEqualToString:groupName];
}

- (void)dealloc{
  _name = nil;
  _group = nil;
  _ccObj= nil;
  [super dealloc];
}

@end
