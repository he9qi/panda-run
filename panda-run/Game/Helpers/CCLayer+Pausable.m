//
//  CCLayer+Pausable.m
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "CCLayer+Pausable.h"
#import "cocos2d.h"

@implementation CCLayer (Pausable)

- (void)pause
{
  [self pauseSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] pauseTarget:sprite];
  }
}

- (void)resume
{
  [self resumeSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] resumeTarget:sprite];
  }
}

@end
