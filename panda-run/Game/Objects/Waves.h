//
//  Waves.h
//  panda-run
//
//  Created by Qi He on 12-8-16.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Waves1DNode.h"

@interface Waves : Waves1DNode{
  float _offset;
}

-(id)initWithBounds:(CGRect)bounds count:(int)count damping:(float)damping diffusion:(float)diffusion offset:(float)offset;
- (void)setOffset:(float)offset;

@end
