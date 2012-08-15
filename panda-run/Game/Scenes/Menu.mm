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
#import "Leaf.h"
#import "Cloud.h"
#import "Tips.h"

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
		[Leaf createLeavesTo:batch Count:kMaxLeaves Z:1 Tag:GameSceneNodeTagLeaf];
    
    // Create cloud
    [Cloud createCloudsTo:batch Count:kMaxCloud Z:1 Tag:GameSceneNodeTagCloud]; 
    
		// sprites
		CCSprite *sprite;
    
    sprite = [CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_PLAY];
		sprite.opacity = 0;
		[sprite runAction:[CCFadeIn actionWithDuration:0.25f]];
    playButton = [CCMenuItemImage itemFromNormalSprite:sprite selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_PLAY_PRESSED] target:self selector:@selector(onPlayButtonClicked:)];
    
		sprite.opacity = 0;
		[sprite runAction:[CCFadeIn actionWithDuration:0.25f]];
    sprite = [CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_TIPS];
    tipsButton = [CCMenuItemImage itemFromNormalSprite:sprite selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_TIPS_PRESSED] target:self selector:@selector(onTipsButtonClicked:)];
    
		sprite.opacity = 0;
		[sprite runAction:[CCFadeIn actionWithDuration:0.25f]];
    sprite = [CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_QUIT];
    quitButton = [CCMenuItemImage itemFromNormalSprite:sprite selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_QUIT_PRESSED] target:self selector:@selector(onQuitButtonClicked:)];
    
    
    int widthOffset = 3 * sw / 4;
    int heightOffset = sh / 2 + sprite.contentSize.height/2;
    
    CCMenu *button = [CCMenu menuWithItems:playButton, nil];
		button.anchorPoint = ccp(.5,0);
		button.position = ccp(widthOffset, heightOffset);
		[self addChild:button];
    
    button = [CCMenu menuWithItems:tipsButton, nil];
		button.anchorPoint = ccp(.5,0);
		button.position = ccp(widthOffset, heightOffset - (sprite.contentSize.height+25) );
		[self addChild:button];
    
//    button = [CCMenu menuWithItems:quitButton, nil];
//		button.anchorPoint = ccp(.5,0);
//		button.position = ccp(widthOffset, heightOffset - (sprite.contentSize.height+5) * 2);
//		[self addChild:button];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"click.caf"];
    
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"intro.mp3"];
    
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

- (void) onPlayButtonClicked:(id) sender {
  [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
  [[CCDirector sharedDirector] pushScene:[Game scene]];	
}

- (void) onTipsButtonClicked:(id) sender {
  [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
  [[CCDirector sharedDirector] pushScene:[Tips scene]];	
}

- (void) onQuitButtonClicked:(id) sender {
  
}


//- (void)registerWithTouchDispatcher {
//  [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
//}
//
//- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
//  CGPoint location = [touch locationInView:[touch view]];
//  location = [[CCDirector sharedDirector] convertToGL:location];
//  [self tapDownAt:location];
//  return YES;
//}
//
//- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
//  CGPoint location = [touch locationInView:[touch view]];
//  location = [[CCDirector sharedDirector] convertToGL:location];
//  [self tapUpAt:location];
//}

//- (bool)tapAtPlayButton:(CGSize)screenSize:(CGPoint)location{
//  // play button
//	CGRect rect = CGRectMake(screenSize.width/2+92, screenSize.height/2-8, 120, 38);
//	return CGRectContainsPoint(rect, location);
//}

//- (void)tapDownAt:(CGPoint)location {
//	CCLOG(@"tapDown");
//	CGSize screenSize = [[CCDirector sharedDirector] winSize];
//
//	if( [self tapAtPlayButton:screenSize:location] ) {
//		playButton.scale = 0.95f;
//		[[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
//	}
//}

//- (void)tapUpAt:(CGPoint)location {
//	CCLOG(@"tapUp");
//	playButton.scale = 1.0f;
//  
//  CGSize screenSize = [[CCDirector sharedDirector] winSize];
//  
//	if( [self tapAtPlayButton:screenSize:location] ) {
//    [[CCDirector sharedDirector] pushScene:[Game scene]];	
//  }
//}

@end
