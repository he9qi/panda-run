//
//  Coin.m
//  panda-run
//
//  Created by Qi He on 12-6-29.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Coin.h"
#import "UserData.h"
#import "Constants.h"
#import "Box2DHelper.h"

#import "Game.h"
#import "Terrain.h"
#import "Panda.h"

@implementation Coin

+ (id) coinWithGame:(Game*)game Position:(CGPoint)p{
  [Box2DHelper getSpriteBatch];
	return [[[self alloc] initWithGame:game Sprite:[CCSprite spriteWithSpriteFrameName:IMAGE_COIN] Radius:RADIUS_COIN Position:p] autorelease];
}

+ (TTConsumableItem *)createItemTo:(Game *)game On:(Terrain *)terrain At:(int)index{
  ccVertex2F bp = [terrain getBorderVerticeAt:index];
  CGPoint p = ccp(bp.x * [Box2DHelper pointsPerPixel], bp.y* [Box2DHelper pointsPerPixel] + kCoinPositionYOffset);
  
  Coin *coin = [Coin coinWithGame:game Position:p];
  
  [terrain addChild:coin];
  return coin;
}

- (void)beginContact:(b2Contact *)contact{
  [super hideSprite];
  float score = _game.panda.isCrazy ? kCoinScore * kPandaCoinMultiFactor : kCoinScore;
  [_game incScore:score];
}

@end
