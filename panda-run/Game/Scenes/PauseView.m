//
//  PauseView.m
//  panda-run
//
//  Created by Qi He on 12-8-4.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "PauseView.h"
#import "Constants.h"

@implementation PauseView

@synthesize resumeButtonTarget, resumeButtonSelector, restartButtonTarget, restartButtonSelector, menuButtonTarget, menuButtonSelector, quitButtonTarget, quitButtonSelector;

- (id) init {
  
  if((self = [super init]))
    
  {
    self.isTouchEnabled = YES;

		viewSprite = [CCSprite spriteWithFile:IMAGE_PAUSE];
		[self addChild:viewSprite z:-1];
    
		CGSize size = viewSprite.contentSize;
    self.anchorPoint = ccp(0,0);
    
    resumeButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_RESUME] selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_RESUME_PRESSED] target:self selector:@selector(resumeButtonClicked:)];
    
    restartButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_RESTART] selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_RESTART_PRESSED] target:self selector:@selector(restartButtonClicked:)];
    
    menuButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_MENU] selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_MENU_PRESSED] target:self selector:@selector(menuButtonClicked:)];
    
    quitButton = [CCMenuItemImage itemFromNormalSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_QUIT] selectedSprite:[CCSprite spriteWithSpriteFrameName:IMAGE_BUTTON_QUIT_PRESSED] target:self selector:@selector(quitButtonClicked:)];
 
    int heightOffset = size.height/3;
    int widthOffset  = size.width/4;
    int buttonOffset = resumeButton.rect.size.height ;
    
    CCMenu *alertMenu = [CCMenu menuWithItems:resumeButton, nil];
		alertMenu.anchorPoint = ccp(.5,0);
//		[alertMenu alignItemsHorizontallyWithPadding:10];
		alertMenu.position = ccp(widthOffset, heightOffset + buttonOffset);
		[viewSprite addChild:alertMenu];
    
    alertMenu = [CCMenu menuWithItems:restartButton, nil];
		alertMenu.anchorPoint = ccp(.5,0);
//		[alertMenu alignItemsHorizontallyWithPadding:10];
		alertMenu.position = ccp(3*widthOffset, heightOffset + buttonOffset);
		[viewSprite addChild:alertMenu];
    
    alertMenu = [CCMenu menuWithItems:menuButton, nil];
		alertMenu.anchorPoint = ccp(.5,0);
//		[alertMenu alignItemsHorizontallyWithPadding:10];
		alertMenu.position = ccp(2*widthOffset, heightOffset - 3*buttonOffset/4);
		[viewSprite addChild:alertMenu];
    
//    alertMenu = [CCMenu menuWithItems:quitButton, nil];
//		alertMenu.anchorPoint = ccp(.5,0);
//		[alertMenu alignItemsHorizontallyWithPadding:10];
//		alertMenu.position = ccp(3*widthOffset, heightOffset - 3*buttonOffset/4);
//		[viewSprite addChild:alertMenu];
    
		viewSprite.scale = .6;
		viewSprite.opacity = 150;
    
		id fadeIn = [CCFadeIn actionWithDuration:0.1];
		id scale1 = [CCSpawn actions:fadeIn, [CCScaleTo actionWithDuration:0.15 scale:1.1], nil];
		id scale2 = [CCScaleTo actionWithDuration:0.1 scale:0.9];
		id scale3 = [CCScaleTo actionWithDuration:0.05 scale:1.0];
		id pulse = [CCSequence actions:scale1, scale2, scale3, nil];
    
		[viewSprite runAction:pulse];
  }
  
  return self;
}

- (void)dealloc{
  [super dealloc];
  resumeButton = nil;
	restartButton = nil;
	menuButton = nil;
	quitButton = nil;
  viewSprite = nil;
}

-(void) resumeButtonClicked:(id) sender
{
  [self removeFromParentAndCleanup:YES];
  
  NSMethodSignature * sig = nil;
  
  if( resumeButtonTarget && resumeButtonSelector ) {
    sig = [resumeButtonTarget methodSignatureForSelector:resumeButtonSelector];
    
    NSInvocation *invocation = nil;
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:resumeButtonTarget];
    [invocation setSelector:resumeButtonSelector];
#if NS_BLOCKS_AVAILABLE
    if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
    
    [invocation invoke];
  }
}

-(void) restartButtonClicked:(id) sender
{
  [self removeFromParentAndCleanup:YES];
  
  NSMethodSignature * sig = nil;
  
  if( restartButtonTarget && restartButtonSelector ) {
    sig = [restartButtonTarget methodSignatureForSelector:restartButtonSelector];
    
    NSInvocation *invocation = nil;
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:restartButtonTarget];
    [invocation setSelector:restartButtonSelector];
#if NS_BLOCKS_AVAILABLE
    if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
    
    [invocation invoke];
  }
}

-(void) menuButtonClicked:(id) sender
{
  [self removeFromParentAndCleanup:YES];
  
  NSMethodSignature * sig = nil;
  
  if( menuButtonTarget && menuButtonSelector ) {
    sig = [menuButtonTarget methodSignatureForSelector:menuButtonSelector];
    
    NSInvocation *invocation = nil;
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:menuButtonTarget];
    [invocation setSelector:menuButtonSelector];
#if NS_BLOCKS_AVAILABLE
    if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
    
    [invocation invoke];
  }
}


-(void) quitButtonClicked:(id) sender
{
  [self removeFromParentAndCleanup:YES];
  
  NSMethodSignature * sig = nil;
  
  if( quitButtonTarget && quitButtonSelector ) {
    sig = [quitButtonTarget methodSignatureForSelector:quitButtonSelector];
    
    NSInvocation *invocation = nil;
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:quitButtonTarget];
    [invocation setSelector:quitButtonSelector];
#if NS_BLOCKS_AVAILABLE
    if ([sig numberOfArguments] == 3)
#endif
			[invocation setArgument:&self atIndex:2];
    
    [invocation invoke];
  }
}




@end
