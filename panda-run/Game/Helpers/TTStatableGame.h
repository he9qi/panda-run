//
//  TTStatableGame.h
//  panda-run
//
//  Created by Qi He on 12-8-5.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
	kGameStateIdle,
	kGameStateStarted,
	kGameStatePaused,
	kGameStateFinished
} GameState;

@interface TTStatableGame : CCLayer{
  GameState _state;
}

- (void)pause;
- (void)resume;
- (void)finish;
- (void)start;
- (void)restart;

- (BOOL)isIdle;
- (BOOL)isStarted;
- (BOOL)isFinished;
- (BOOL)isPaused;

@end
