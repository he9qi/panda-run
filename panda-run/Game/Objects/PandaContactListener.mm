//
//  PandaContactListener.m
//  panda-run
//
//  Created by Qi He on 12-6-28.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "PandaContactListener.h"
#import "Panda.h"
#import "Game.h"
#import "UserData.h"

PandaContactListener::PandaContactListener(Panda* panda) {
	_panda = [panda retain];
}

PandaContactListener::~PandaContactListener() {
	[_panda release];
}

void PandaContactListener::EndContact(b2Contact* contact) {
//  if (!contact ) return;
//  
//  b2Body* bodyB = contact->GetFixtureB()->GetBody();
//  UserData *sb = (UserData*) bodyB->GetUserData();    
//  
//  // it's a panda collision
//  if (sb != nil || [sb isA:@"Panda"]) {
//    
//    b2Body* bodyA = contact->GetFixtureA()->GetBody();
//    UserData *sa = (UserData*) bodyA->GetUserData();
//    
//    if (sa != nil && ![sa isA:@"Terrain"]) {
////      CCLOG(@"PandaContactListener::BeginContact %@ <=> %@", sa.name, sb.name);
//      if ([sa isA:@"Energy"]) {
//        [_panda energify];
//      }
//    }
//    
//  }
}

void PandaContactListener::BeginContact(b2Contact* contact) {
  if (!contact ) return;
  
  b2Body* bodyB = contact->GetFixtureB()->GetBody();
  UserData *sb = (UserData*) bodyB->GetUserData();    
  
  // it's a panda collision
  if (sb != nil || [sb isA:@"Panda"]) {
    
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    UserData *sa = (UserData*) bodyA->GetUserData();
    
    if (sa != nil && ![sa isA:@"Terrain"]) {
//      CCLOG(@"PandaContactListener::BeginContact %@ <=> %@", sa.name, sb.name);
      id<ContactDelegate> cda = (id<ContactDelegate>)sa.ccObj;
      [cda beginContact:contact];
      if ([sa isA:@"Energy"]) {
        [_panda energify];
      }
    }

  }
    

}

void PandaContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
  if(contact){
    b2Fixture *a = contact->GetFixtureA();
    b2Body* bodyA = a->GetBody();
    UserData *sa = (UserData*) bodyA->GetUserData();
    
    
    b2Fixture *b = contact->GetFixtureB();
    b2Body* bodyB = b->GetBody();
    UserData *sb = (UserData*) bodyB->GetUserData();    
    
    if (sa != nil && sb != nil) {  
      if ([sa isA:@"Terrain"] && [sb isA:@"Panda"]){
        b2WorldManifold wm;
        contact->GetWorldManifold(&wm);
        b2PointState state1[2], state2[2];
        b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
        if (state2[0] == b2_addState) {
          const b2Body *b = contact->GetFixtureB()->GetBody();
          b2Vec2 vel = b->GetLinearVelocity();
          float va = atan2f(vel.y, vel.x);
          float na = atan2f(wm.normal.y, wm.normal.x);
          //		CCLOG(@"na = %.3f",na);
          if (na - va > kMaxAngleDiff) {
            [_panda hit];
          }
        }
      }
    }
  }
}

void PandaContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {}
