//
//  UserData.m
//  panda-run
//
//  Created by Qi He on 12-6-30.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "UserData.h"

@implementation UserData

@synthesize name = _name;
@synthesize sid  = _sid;
@synthesize ccObj = _ccObj;

+ (id) userDataWithName:(NSString*)name;{
	return [[[self alloc] initWithName:name] autorelease];
}

- (id) initWithName:(NSString *)name{
  return [self initWithName:name SID:-1];
}

- (id) initWithName:(NSString *)name Delegate:(id<ContactDelegate>)delegate
{
  if ((self = [super init])) {
    _name  = name;
    _sid   = -1;
    _ccObj = delegate;
	}
  CCLOG(@"user data %@, ccobj = %@", self, self.ccObj);
	return self;
}

- (void)dealloc{
  _name = nil;
  _ccObj= nil;
  [super dealloc];
}

- (id) initWithName:(NSString *)name SID:(NSInteger)sid{
  if ((self = [super init])) {
    _name = name;
    _sid  = sid;
	}
	return self;
}

@end
