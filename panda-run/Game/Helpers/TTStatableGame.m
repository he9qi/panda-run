//
//  TTStatableGame.m
//  panda-run
//
//  Created by Qi He on 12-8-5.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "TTStatableGame.h"

@implementation TTStatableGame

- (void)pause
{
  _state = kGameStatePaused;
  [self pauseSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] pauseTarget:sprite];
  }
}

- (void)restart
{
  _state = kGameStateIdle;
  [self resumeSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] resumeTarget:sprite];
  }
}

- (void)resume
{
  _state = kGameStateStarted;
  [self resumeSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] resumeTarget:sprite];
  }
}

- (void)finish
{
  _state = kGameStateFinished;
  [self pauseSchedulerAndActions];
  for(CCSprite *sprite in [self children]) {
    [[CCActionManager sharedManager] pauseTarget:sprite];
  }
}

- (void)start
{
  _state = kGameStateStarted;
}

- (BOOL)isIdle
{
  return _state == kGameStateIdle;
}

- (BOOL)isStarted
{
  return _state == kGameStateStarted;
}

- (BOOL)isFinished
{
  return _state == kGameStateFinished;
}

- (BOOL)isPaused
{
  return _state == kGameStatePaused;
}

@end
