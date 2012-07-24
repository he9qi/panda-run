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
  NSString *_group;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *group;

@property (nonatomic, copy) id<ContactDelegate> ccObj;


+ (id) userDataWithName:(NSString*)name;
- (id) initWithName:(NSString *)name;
- (id) initWithName:(NSString *)name Group:(NSString *)group;
- (id) initWithName:(NSString *)name Delegate:(id<ContactDelegate>)delegate;
- (id) initWithName:(NSString *)name Group:(NSString *)group Delegate:(id<ContactDelegate>)delegate;

- (bool) isA:(NSString *)objName;
- (bool) belongsTo:(NSString *)groupName;

@end
