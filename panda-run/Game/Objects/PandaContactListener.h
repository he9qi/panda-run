//
//  PandaContactListener.h
//  panda-run
//
//  Created by Qi He on 12-6-28.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Box2D.h"

#define kMaxAngleDiff 2.4f // in radians

@class Panda;

class PandaContactListener : public b2ContactListener {
public:
	Panda *_panda;
	
	PandaContactListener(Panda *panda);
	~PandaContactListener();
	
	void BeginContact(b2Contact* contact);
	void EndContact(b2Contact* contact);
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};
