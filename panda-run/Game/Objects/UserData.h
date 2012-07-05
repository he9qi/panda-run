//
//  UserData.h
//  panda-run
//
//  Created by Qi He on 12-6-30.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#include "CCNode.h"
#include "ContactDelegate.h"

@interface UserData : NSObject{
  NSString *_name;
  NSInteger _sid;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, copy) id<ContactDelegate> ccObj;

@property NSInteger sid;

+ (id) userDataWithName:(NSString*)name;
- (id) initWithName:(NSString *)name;
- (id) initWithName:(NSString *)name SID:(NSInteger)sid;
- (id) initWithName:(NSString *)name Delegate:(id<ContactDelegate>)delegate;

@end
