//
//  ContactDelegate.h
//  panda-run
//
//  Created by Qi He on 12-7-5.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

@protocol ContactDelegate <NSObject>

// post solve to check break condition
- (void) postSolve:(b2Contact *)contact:(const b2ContactImpulse*)impulse;

// pre solve
- (void) preSolve:(b2Contact *)contact:(const b2Manifold *)manifold;

- (void) beginContact:(b2Contact *)contact;

- (void) endContact:(b2Contact *)contact;

@optional
- (void) hideSprite;
- (void) showSprite;

@end
