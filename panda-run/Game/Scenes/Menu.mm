//
//  Menu.m
//  panda-run
//
//  Created by Qi He on 12-7-12.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Menu.h"
#import "Game.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"
#import "TTSpriteItem.h"
#import "Cloud.h"

@interface Menu()
- (void)tapDownAt:(CGPoint)location;
- (void)tapUpAt:(CGPoint)location;
@end

@implementation Menu

+ (CCScene*)scene {
	CCScene *scene = [CCScene node];
	[scene addChild:[Menu node]];
	return scene;
}

- (id)init {
	if((self = [super init])) {
    
		self.isTouchEnabled = YES;
    
		CGSize ss = [[CCDirector sharedDirector] winSize];
		float sw = ss.width;
		float sh = ss.height;
		
		CCSprite *background = [CCSprite spriteWithFile:BG_MENU rect:CGRectMake(0, 0, sw, sh)];
		background.position = ccp(sw/2, sh/2);
		[self addChild:background];
		ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
		[background.texture setTexParameters:&tp];
    
    // sprite sheet
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:PLIST_SPRITE];
    
    batch = [CCSpriteBatchNode batchNodeWithFile:IMAGE_SPRITE capacity:50];
		[self addChild:batch z:1 tag:GameSceneNodeTagSpritesBatch];
    
    
		// Create a number of leaves up front and re-use them whenever necessary.
		for (int i = 0; i < kMaxLeaves; i++){
			TTSpriteItem* si = [TTSpriteItem createSpriteItemWithName:IMAGE_LEAF];
			[batch addChild:si z:1 tag:GameSceneNodeTagLeaf];
      [si start];
		}
    
    for (int i = 0; i < kMaxCloud; i++){
			Cloud* cloud = [Cloud createCloud];
			[batch addChild:cloud z:1 tag:GameSceneNodeTagCloud];
      [cloud start];
		}
    
		// sprites
		CCSprite *sprite;
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"play_button.png"];
		sprite.position = ccp(sw/2+150, sh/2+10);
		sprite.opacity = 0;
		[sprite runAction:[CCFadeIn actionWithDuration:0.1f]];
		[batch addChild:sprite];
		playButton = [sprite retain];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"click.caf"];
    
  }
  return self;
}

- (void)dealloc
{
  playButton = nil;
	tipsButton = nil;
	quitButton = nil;
  
  batch = nil;
  
  [super dealloc];
}

- (void)registerWithTouchDispatcher {
  [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint location = [touch locationInView:[touch view]];
  location = [[CCDirector sharedDirector] convertToGL:location];
  [self tapDownAt:location];
  return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint location = [touch locationInView:[touch view]];
  location = [[CCDirector sharedDirector] convertToGL:location];
  [self tapUpAt:location];
}

- (bool)tapAtPlayButton:(CGSize)screenSize:(CGPoint)location{
  // play button
	CGRect rect = CGRectMake(screenSize.width/2+92, screenSize.height/2-8, 120, 38);
	return CGRectContainsPoint(rect, location);
}

- (void)tapDownAt:(CGPoint)location {
	CCLOG(@"tapDown");
	CGSize screenSize = [[CCDirector sharedDirector] winSize];

	if( [self tapAtPlayButton:screenSize:location] ) {
		playButton.scale = 0.95f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
	}
  
}

- (void)tapUpAt:(CGPoint)location {
	CCLOG(@"tapUp");
	playButton.scale = 1.0f;
  
  CGSize screenSize = [[CCDirector sharedDirector] winSize];
  
	if( [self tapAtPlayButton:screenSize:location] ) {
    [[CCDirector sharedDirector] pushScene:[Game scene]];	
  }
}

@end
