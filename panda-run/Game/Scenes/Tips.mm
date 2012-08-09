//
//  Tips.m
//  panda-run
//
//  Created by Qi He on 12-8-8.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Tips.h"
#import "Constants.h"

@implementation Tips
+ (CCScene*)scene {
	CCScene *scene = [CCScene node];
	[scene addChild:[Tips node]];
	return scene;
}

- (id)init {
	if((self = [super init])) {
    
		self.isTouchEnabled = YES;
    
		CGSize ss = [[CCDirector sharedDirector] winSize];
		float sw = ss.width;
		float sh = ss.height;
		
		CCSprite *background = [CCSprite spriteWithFile:BG_TIPS rect:CGRectMake(0, 0, sw, sh)];
		background.position = ccp(sw/2, sh/2);
		[self addChild:background];
		ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
		[background.texture setTexParameters:&tp];
    
  }
  return self;
}

- (void)registerWithTouchDispatcher {
  [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  [[CCDirector sharedDirector] popScene];	
}

@end
