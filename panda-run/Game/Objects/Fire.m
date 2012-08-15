//
//  Fire.m
//  panda-run
//
//  Created by Qi He on 12-8-13.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Fire.h"

@implementation Fire

-(id) init
{
	return [self initWithTotalParticles:6];
}

-(id) initWithTotalParticles:(NSUInteger) p
{
	if( (self=[super initWithTotalParticles:p]) ) {
    
//		// duration
//		duration = kCCParticleDurationInfinity;
//    
//		// Gravity Mode
//		self.emitterMode = kCCParticleModeGravity;
//    
//		// Gravity Mode: gravity
//		self.gravity = ccp(0,0);
//		
//		// Gravity Mode: radial acceleration
//		self.radialAccel = 0;
//		self.radialAccelVar = 0;
//		
//		// Gravity Mode: speed of particles
//		self.speed = -60;
//		self.speedVar = 20;		
//		
//		// starting angle
//		angle = 0;
//		angleVar = 10;
//		
//		// emitter position
//		CGSize winSize = [[CCDirector sharedDirector] winSize];
//		self.position = ccp(winSize.width/2, 60);
//		posVar = ccp(40, 20);
//		
//		// life of particles
//		life = 3;
//		lifeVar = 0.25f;
//		
//    
//		// size, in pixels
//		startSize = 54.0f;
//		startSizeVar = 10.0f;
//		endSize = kCCParticleStartSizeEqualToEndSize;
//    
//		// emits per frame
//		emissionRate = totalParticles/life;
//		
//		// color of particles
//		startColor.r = 0.76f;
//		startColor.g = 0.25f;
//		startColor.b = 0.12f;
//		startColor.a = 1.0f;
//		startColorVar.r = 0.0f;
//		startColorVar.g = 0.0f;
//		startColorVar.b = 0.0f;
//		startColorVar.a = 0.0f;
//		endColor.r = 0.0f;
//		endColor.g = 0.0f;
//		endColor.b = 0.0f;
//		endColor.a = 1.0f;
//		endColorVar.r = 0.0f;
//		endColorVar.g = 0.0f;
//		endColorVar.b = 0.0f;
//		endColorVar.a = 0.0f;
//		
//		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
//		
//		// additive
//		self.blendAdditive = YES;

		
    
    
    // duration
		duration = kCCParticleDurationInfinity;
    
		// Gravity Mode
		self.emitterMode = kCCParticleModeGravity;
    
		// Gravity Mode: gravity
		self.gravity = ccp(0,0);
		
		// Gravity Mode: radial acceleration
		self.radialAccel = 0;
		self.radialAccelVar = 0;
		
		// Gravity Mode: speed of particles
		self.speed = -400;
		self.speedVar = 20;		
		
		// starting angle
		angle = 0;
		angleVar = 0;
		
		// emitter position
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2, 60);
		posVar = ccp(5, 5);
		
		// life of particles
		life = 0.25f;
		lifeVar = 0.05f;
		
    
		// size, in pixels
		startSize = 32.0f;
		startSizeVar = 0.0f;
		endSize = startSize/2;//kCCParticleStartSizeEqualToEndSize;
    
		// emits per frame
		emissionRate = totalParticles/life;
		
		// color of particles
		startColor.r = 1.0f;
		startColor.g = 1.0f;
		startColor.b = 1.0f;
		startColor.a = 1.0f;
		startColorVar.r = 0.0f;
		startColorVar.g = 0.0f;
		startColorVar.b = 0.0f;
		startColorVar.a = 0.0f;
		endColor.r = 1.0f;
		endColor.g = 1.0f;
		endColor.b = 1.0f;
		endColor.a = 1.0f;
		endColorVar.r = 0.0f;
		endColorVar.g = 0.0f;
		endColorVar.b = 0.0f;
		endColorVar.a = 0.0f;
    
		self.texture = [[CCTextureCache sharedTextureCache] addImage: @"star.png"];
    
		// additive
		self.blendAdditive = NO;

	}
	return self;
}


@end
