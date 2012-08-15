//
//  Rain.m
//  panda-run
//
//  Created by Qi He on 12-8-14.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Rain.h"

@implementation Rain
-(id) init
{
	return [self initWithTotalParticles:kMaxFlyingLeaves];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
		// duration
		duration = kCCParticleDurationInfinity;
		
		self.emitterMode = kCCParticleModeGravity;
    
		// Gravity Mode: gravity
		self.gravity = ccp(-30,0);
		
		// Gravity Mode: radial
		self.radialAccel = 0;
		self.radialAccelVar = 1;
		
		// Gravity Mode: tagential
		self.tangentialAccel = 0;
		self.tangentialAccelVar = 1;
    
		// Gravity Mode: speed of particles
		self.speed = -100;
		self.speedVar = 30;
		
		// angle
		angle = 0;
		angleVar = 5;
		
    self.startSpin = 0.0f;
    self.startSpinVar = 360.0f;
		
		// emitter position
		self.position = (CGPoint) {
			[[CCDirector sharedDirector] winSize].width,
			[[CCDirector sharedDirector] winSize].height/2
		};
		posVar = ccp( 0, [[CCDirector sharedDirector] winSize].height / 2 );
		
		// life of particles
		life = 3.5f;
		lifeVar = 0;
		
		// size, in pixels
		startSize = 12.0f;
		startSizeVar = 2.0f;
		endSize = kCCParticleStartSizeEqualToEndSize;
    
		// emits per second
		emissionRate = totalParticles / life;
		
		// color of particles
		startColor.r = 0.3f;
		startColor.g = 0.8f;
		startColor.b = 0.3f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 0.3f;
		endColor.g = 0.8f;
		endColor.b = 0.3f;
		endColor.a = 0.8f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fly_leaf.png"];
    
//    self.texture = [[CCTextureCache sharedTextureCache] textureForKey:@"leaf.png"];
//    self.texture = frameFire.texture;
    
//    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"leaf.png"];
//    self.texture = sprite.texture;
  
		// additive
		self.blendAdditive = NO;
	}
	return self;
}

@end
