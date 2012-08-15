//
//  Panda.h
//  panda-run
//
//  Created by Qi He on 12-6-28.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define kPerfectTakeOffVelocityY 2.0f
#define kMaxEnergy 100
#define kEnergyMagifySize 2.5f
#define kPandaReachTempleOffset 25.0f
#define kFrenzyLimit 4

@class Game;
class PandaContactListener;

typedef enum {
	kPandaStateIdle,
	kPandaStateWalk,
	kPandaStateSlide,
	kPandaStateFly,
} PandaState;

typedef enum {
	kPandaModeNormal,
	kPandaModeFrenzy
} PandaMode;

@interface Panda : CCNode{
	Game *_game;
	CCSprite *_sprite;
	CCSprite *_shadowSprite;
  
	b2Body *_body;
	float _radius;
	BOOL _awake;
	BOOL _flying;
	BOOL _diving;
	PandaContactListener *_contactListener;
	int _nPerfectSlides;
  int _energy;
  PandaState _state;
  PandaMode _mode;
  
  CCRepeatForever *_walkForeverAction;
  CCRepeatForever *_rotateForeverAction;
  CCParticleSystem* _fireSystem;
  
  BOOL _energized;
}

@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) CCSprite *sprite;
@property (readonly) BOOL awake;
@property (nonatomic) BOOL diving;
@property (nonatomic) int energy;
@property (nonatomic,assign) PandaState state;

+ (id) heroWithGame:(Game*)game;
- (id) initWithGame:(Game*)game;

- (void) reset;
- (void) energify;
- (void) sleep;
- (void) wake;
- (void) updatePhysics;
- (void) updateNode;

- (void) landed;
- (void) tookOff;
- (void) hit;
- (bool) isCrazy;


@end
