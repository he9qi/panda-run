//
//  Waves.m
//  panda-run
//
//  Created by Qi He on 12-8-16.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Waves.h"

@implementation Waves

-(id)initWithBounds:(CGRect)bounds count:(int)count damping:(float)damping diffusion:(float)diffusion offset:(float)offset;
{
	if((self = [super init])){
		_bounds = bounds;
		_count = count;
		_damping = damping;
		_diffusion = diffusion;
    _offset = offset;
		
		_h1 = calloc(_count, sizeof(float));
		_h2 = calloc(_count, sizeof(float));
	}
	
	return self;
}

- (void)computeHight {
  GLfloat dx = [self dx];
	GLfloat top = _bounds.size.height;
	
	// Build a vertex array and render it.
	for(int i=0; i<_count; i++){
		GLfloat x = i*dx + _offset;
		_verts[2*i + 0] = (ccVertex2F){x, 0};
		_verts[2*i + 1] = (ccVertex2F){x, top + _h2[i]};
	}
}

- (void)setOffset:(float)offset{
  _offset = offset;
}

- (void)draw {
  // It would be better to run these on a fixed timestep.
	// As an GFX only effect it doesn't really matter though.
	[self vertlet];
	[self diffuse];
  [self computeHight];
  
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glDisable(GL_TEXTURE_2D);
	
	GLfloat r = 105.0f/255.0f;
	GLfloat g = 193.0f/255.0f;
	GLfloat b = 212.0f/255.0f;
	GLfloat a = 0.6f;
	glColor4f(r*a, g*a, b*a, a);
	
	glVertexPointer(2, GL_FLOAT, 0, _verts);
	
	glPushMatrix(); {
//		glScalef(CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0);
//		glTranslatef(_bounds.origin.x, _bounds.origin.y, 0.0);
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, _count*2);
	} glPopMatrix();
	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
}


@end
