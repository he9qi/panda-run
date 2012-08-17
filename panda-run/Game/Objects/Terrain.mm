//
//  Terrain.m
//  panda-run
//
//  Created by Qi He on 12-6-27.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import "Terrain.h"
#import "Constants.h"
#import "Box2DHelper.h"
#import "UserData.h"
#import "TerrainImageItem.h"
#import "Waves.h"

@interface Terrain()

- (CCSprite*) generateSprite;
- (CCTexture2D*) generateTexture;

- (void) generateHillKeyPoints;
- (void) generateBorderVertices;
- (void) createBox2DBody;
- (void) refreshHillVertices;
@end

@implementation Terrain

@synthesize sprite = _sprite;
@synthesize offsetX = _offsetX;

+ (id) terrainWithWorld:(b2World*)w {
	return [[[self alloc] initWithWorld:w] autorelease];
}

- (id) initWithWorld:(b2World*)w {
	
	if ((self = [super init])) {
		
		world = w;
    
		CGSize size = [[CCDirector sharedDirector] winSize];
		screenW = size.width;
		screenH = size.height;
    
#ifndef DRAW_BOX2D_WORLD
		textureSize = 512;
		self.sprite = [self generateSprite];
#endif
		
		[self generateHillKeyPoints];
//    [self generateHillWaterBoundsPoints];
		[self generateBorderVertices];
		[self createBox2DBody];
    
    firstTime = YES;
    fromKeyPointI = 0;
    toKeyPointI = 0;
    self.offsetX = 0;
	}
	return self;
}

- (void) dealloc {
  
#ifndef DRAW_BOX2D_WORLD
	self.sprite = nil;
#endif
  
	[super dealloc];
}

- (CCSprite*) generateSprite {
	
	CCTexture2D *texture = [self generateTexture];
	CCSprite *sprite = [CCSprite spriteWithTexture:texture];
	ccTexParams tp = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
	[sprite.texture setTexParameters:&tp];
	
	return sprite;
}

- (CCTexture2D*) generateTexture {
	
	CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:textureSize height:textureSize];
	[rt begin];
	[self renderhill];
	[self renderGradient];
	[self renderHighlight];
//  [self renderGrass];
	[self renderTopBorder];
	[self renderNoise];
	[rt end];
	
	return rt.sprite.texture;
}

- (void) renderhill {
	
	ccVertex2F *vertices = (ccVertex2F*)malloc(sizeof(ccVertex2F)*6);
	ccColor4F *colors = (ccColor4F*)malloc(sizeof(ccColor4F)*6);
	int nVertices = 0;
	
	float x1, x2, y1, y2;
	ccColor4F c;
  
  x1 = 0;
  y1 = 0;
  
  x2 = (float)textureSize;
  y2 = 0;
	
  //sky color
	ccColor3B cb = (ccColor3B){230,177,27};
	c = ccc4FFromccc3B(cb);
  
  for (int k=0; k<6; k++) {
    colors[nVertices+k] = c;
  }
  vertices[nVertices++] = (ccVertex2F){x1, y1}; //0, 0
  vertices[nVertices++] = (ccVertex2F){x2, y2}; //512, 0
  vertices[nVertices++] = (ccVertex2F){x1, (float)textureSize}; //0, 512
  
  vertices[nVertices++] = (ccVertex2F){x2, y2}; //512, 0
  vertices[nVertices++] = (ccVertex2F){x2, (float)textureSize}; //512, 512
  vertices[nVertices++] = (ccVertex2F){x1, (float)textureSize}; //0, 512
  
  CCLOG(@"Render hill nVertices = %d", nVertices);
  
	// adjust vertices for retina
	for (int i=0; i<nVertices; i++) {
		vertices[i].x *= CC_CONTENT_SCALE_FACTOR();
		vertices[i].y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glColor4f(1, 1, 1, 1);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_TRIANGLES, 0, (GLsizei)nVertices);
	
	free(vertices);
	free(colors);
}

- (void) renderGradient {
	
	float gradientAlpha = 0.5f;
	float gradientWidth = textureSize;
	
	ccVertex2F vertices[6];
	ccColor4F colors[6];
	int nVertices = 0;
	
	vertices[nVertices] = (ccVertex2F){0, 0};
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = (ccVertex2F){textureSize, 0};
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	
	vertices[nVertices] = (ccVertex2F){0, gradientWidth};
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	vertices[nVertices] = (ccVertex2F){textureSize, gradientWidth};
	colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	
	if (gradientWidth < textureSize) {
		vertices[nVertices] = (ccVertex2F){0, textureSize};
		colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
		vertices[nVertices] = (ccVertex2F){textureSize, textureSize};
		colors[nVertices++] = (ccColor4F){0, 0, 0, gradientAlpha};
	}
	
	// adjust vertices for retina
	for (int i=0; i<nVertices; i++) {
		vertices[i].x *= CC_CONTENT_SCALE_FACTOR();
		vertices[i].y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
}

- (void) renderHighlight {
	
	float highlightAlpha = 0.5f;
	float highlightWidth = textureSize/8;
	
	ccVertex2F vertices[4];
	ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = (ccVertex2F){0, 0};
	colors[nVertices++] = (ccColor4F){1, 1, 1, highlightAlpha}; // yellow
	vertices[nVertices] = (ccVertex2F){textureSize, 0};
	colors[nVertices++] = (ccColor4F){1, 1, 1, highlightAlpha};
	
	vertices[nVertices] = (ccVertex2F){0, highlightWidth};
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	vertices[nVertices] = (ccVertex2F){textureSize, highlightWidth};
	colors[nVertices++] = (ccColor4F){0, 0, 0, 0};
	
	// adjust vertices for retina
	for (int i=0; i<nVertices; i++) {
		vertices[i].x *= CC_CONTENT_SCALE_FACTOR();
		vertices[i].y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glColorPointer(4, GL_FLOAT, 0, colors);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nVertices);
}

- (void) renderTopBorder {
	
	float borderAlpha = 0.5f;
	float borderWidth = 2.5 * CC_CONTENT_SCALE_FACTOR();
	
	ccVertex2F vertices[4];
  ccColor4F colors[4];
	int nVertices = 0;
	
	vertices[nVertices] = (ccVertex2F){0, borderWidth/2};
	colors[nVertices++] = ccc4FFromccc3B(ccYELLOW); // yellow
	vertices[nVertices] = (ccVertex2F){textureSize, borderWidth/2};
	colors[nVertices++] = ccc4FFromccc3B(ccYELLOW); // yellow
	
	// adjust vertices for retina
	for (int i=0; i<nVertices; i++) {
		vertices[i].x *= CC_CONTENT_SCALE_FACTOR();
		vertices[i].y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	glDisableClientState(GL_COLOR_ARRAY);
	
	glLineWidth(borderWidth*CC_CONTENT_SCALE_FACTOR());
	glColor4f(0, 0, 0, borderAlpha);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDrawArrays(GL_LINE_STRIP, 0, (GLsizei)nVertices);
}

/*** Water ***/

- (ccVertex2F)getHillWaterLeftSide{
  return hillKeyPoints[kMaxHillKeyPoints/2-1];
}

- (ccVertex2F)getHillWaterRightSide{
  return hillKeyPoints[kMaxHillKeyPoints/2+3];
}

- (void) generateHillWaterBoundsPoints{
  
	float maxHeight = screenH - 150;
	float minHeight = 60;
  
  //water mountain
  hillKeyPoints[kMaxHillKeyPoints/2-1].y = maxHeight;
  hillKeyPoints[kMaxHillKeyPoints/2].y   = minHeight;
  hillKeyPoints[kMaxHillKeyPoints/2+1].y = minHeight;
  hillKeyPoints[kMaxHillKeyPoints/2+2].y = minHeight;
  hillKeyPoints[kMaxHillKeyPoints/2+3].y = maxHeight;
  
}

/*** Water ***/

- (void) generateHillKeyPoints {
  
	nHillKeyPoints = 0;
	
	float x, y, dx, dy, ny;
	
	x = -screenW/4;
	y = screenH*3/4;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
  
	// starting point
	x = 0;
	y = screenH/2;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
	
	int minDX = 160, rangeDX = 80;
	int minDY = 50,  rangeDY = 40;
	float sign = -1; // +1 - going up, -1 - going  down
	float maxHeight = screenH - 150;
	float minHeight = 60;
	while (nHillKeyPoints < kMaxHillKeyPoints-4) { //save 4 for last finish points
		dx = arc4random()%rangeDX+minDX;
		x += dx;
		dy = arc4random()%rangeDY+minDY;
		ny = y + dy*sign;
		if(ny > maxHeight) ny = maxHeight;
		if(ny < minHeight) ny = minHeight;
		y = ny;
		sign *= -1;
		hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
	}
  
	// finish point
	x += minDX+rangeDX;
	y = minHeight;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
  
	x += minDX;
	y = minHeight + rangeDY;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
  
	x += minDX;
	y = minHeight + rangeDY;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
  
	x += 10*minDX;
	y = minHeight + rangeDY;
	hillKeyPoints[nHillKeyPoints++] = (ccVertex2F){x, y};
  
	// adjust vertices for retina
	for (int i=0; i<nHillKeyPoints; i++) {
		hillKeyPoints[i].x *= CC_CONTENT_SCALE_FACTOR();
		hillKeyPoints[i].y *= CC_CONTENT_SCALE_FACTOR();
	}
	
	fromKeyPointI = 0;
	toKeyPointI = 0;
  firstTime = YES;
}

- (void) renderNoise {
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	CCSprite *s = [CCSprite spriteWithFile:@"mountain_bg.png"];
	[s setBlendFunc:(ccBlendFunc){GL_DST_COLOR, GL_ZERO}];
	s.position = ccp(textureSize/2, textureSize/2);
	float imageSize = s.textureRect.size.width;
	s.scale = (float)textureSize/imageSize*CC_CONTENT_SCALE_FACTOR();
	glColor4f(1, 1, 1, 1);
	[s visit];
}

- (b2Vec2)getBorderNormalAt:(int)index
{
  return borderNormals[index];
}

- (ccVertex2F)getBorderVerticeAt:(int)p{
  return borderVertices[p];
}

- (ccVertex2F)getHillKeyPointAt:(int)p{
  return hillKeyPoints[p];
}

- (int)getNumHilKeyPoints{
  return nHillKeyPoints;
}

- (ccVertex2F)getTempleBorderVertice
{
//  CCLOG(@"temple position = %d", [self getTemplePostition]);
  return [self getBorderVerticeAt:[self getTemplePostition]];
}

- (int)getTemplePostition{
  return nBorderVertices - kTemplePositionOffset;
}

- (int)getNumBorderVertices{
  return nBorderVertices;
}

- (void) generateBorderVertices {
  
	nBorderVertices = 0;
	ccVertex2F p0, p1, pt0, pt1;
	p0 = hillKeyPoints[0];
	for (int i=1; i<nHillKeyPoints; i++) {
		p1 = hillKeyPoints[i];
		
		int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
		float dx = (p1.x - p0.x) / hSegments;
		float da = M_PI / hSegments;
		float ymid = (p0.y + p1.y) / 2;
		float ampl = (p0.y - p1.y) / 2;
		pt0 = p0;
		borderVertices[nBorderVertices++] = pt0;
		for (int j=1; j<hSegments+1; j++) {
			pt1.x = p0.x + j*dx;
			pt1.y = ymid + ampl * cosf(da*j);
      
      float dx = pt1.x-pt0.x;
      float dy = pt1.y-pt0.y;
      
      borderNormals[nBorderVertices].x = dy;
      borderNormals[nBorderVertices].y = -dx;
      
			borderVertices[nBorderVertices++] = pt1;
      
			pt0 = pt1;
		}
		
		p0 = p1;
	}
  
  CCLOG(@"nBorderVertices = %d", nBorderVertices);
}

- (void) createBox2DBody {
	
	b2BodyDef bd;
	bd.position.Set(0, 0);
	
	body = world->CreateBody(&bd);
	
	b2Vec2 b2vertices[kMaxBorderVertices];
	int nVertices = 0;
	for (int i=0; i<nBorderVertices; i++) {
		b2vertices[nVertices++].Set(borderVertices[i].x * [Box2DHelper metersPerPixel],
                                borderVertices[i].y * [Box2DHelper metersPerPixel]);
	}
	b2vertices[nVertices++].Set(borderVertices[nBorderVertices-1].x * [Box2DHelper metersPerPixel], 0);
	b2vertices[nVertices++].Set(borderVertices[0].x * [Box2DHelper metersPerPixel], 0);
	
	b2LoopShape shape;
	shape.Create(b2vertices, nVertices);
  
  UserData *data = [[UserData alloc]initWithName:@"Terrain"];
  body->SetUserData(data);
	body->CreateFixture(&shape, 0);
}

- (void) refreshHillVertices {
//  CCLOG(@"Terrain::refreshHillVertices");
//#ifdef DRAW_BOX2D_WORLD
//	return;
//#endif
	
	static int prevFromKeyPointI = -1;
	static int prevToKeyPointI = -1;
	
	// key points interval for drawing
	
	float leftSideX = _offsetX-screenW/8/self.scale;
	float rightSideX = _offsetX+screenW*7/8/self.scale;
	
	// adjust position for retina
	leftSideX *= CC_CONTENT_SCALE_FACTOR();
	rightSideX *= CC_CONTENT_SCALE_FACTOR();
  
//  CCLOG(@"leftSideX = %f", leftSideX);
//  CCLOG(@"rightSideX = %f", rightSideX);
//  CCLOG(@"_offsetX = %f", _offsetX);
	
	while (hillKeyPoints[fromKeyPointI+1].x < leftSideX) {
		fromKeyPointI++;
		if (fromKeyPointI > nHillKeyPoints-1) {
			fromKeyPointI = nHillKeyPoints-1;
			break;
		}
	}
	while (hillKeyPoints[toKeyPointI].x < rightSideX) {
		toKeyPointI++;
		if (toKeyPointI > nHillKeyPoints-1) {
			toKeyPointI = nHillKeyPoints-1;
			break;
		}
	}
  
  
	if (prevFromKeyPointI != fromKeyPointI || prevToKeyPointI != toKeyPointI) {
		
//		CCLOG(@"building hillVertices array for the visible area");
//    
//		CCLOG(@"leftSideX = %f", leftSideX);
//		CCLOG(@"rightSideX = %f", rightSideX);
//		
//		CCLOG(@"fromKeyPointI = %d (x = %f)",fromKeyPointI,hillKeyPoints[fromKeyPointI].x);
//		CCLOG(@"toKeyPointI = %d (x = %f)",toKeyPointI,hillKeyPoints[toKeyPointI].x);
		
		// vertices for visible area
		nHillVertices = 0;
		ccVertex2F p0, p1, pt0, pt1;
		p0 = hillKeyPoints[fromKeyPointI];
		for (int i=fromKeyPointI+1; i<toKeyPointI+1; i++) {
			p1 = hillKeyPoints[i];
			
			// triangle strip between p0 and p1
			int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
			int vSegments = 1;
      
      float invHSegments = 1/(float)hSegments;
      float invVSegments = 1/(float)vSegments;
			float dx = (p1.x - p0.x) * invHSegments;
			float da = M_PI * invHSegments;
			float ymid = (p0.y + p1.y) * 0.5f;
			float ampl = (p0.y - p1.y) * 0.5f; //use multi, not division
      
			pt0 = p0;
			for (int j=1; j<hSegments+1; j++) {
				pt1.x = p0.x + j*dx;
				pt1.y = ymid + ampl * cosf(da*j);
				for (int k=0; k<vSegments+1; k++) {
					hillVertices[nHillVertices] = (ccVertex2F){pt0.x, pt0.y-(float)textureSize*invVSegments*k};
					hillTexCoords[nHillVertices++] = (ccVertex2F){pt0.x/(float)textureSize, (float)(k)*invVSegments};
					hillVertices[nHillVertices] = (ccVertex2F){pt1.x, pt1.y-(float)textureSize*invVSegments*k};
					hillTexCoords[nHillVertices++] = (ccVertex2F){pt1.x/(float)textureSize, (float)(k)*invVSegments};
				}
				pt0 = pt1;
			}
			
			p0 = p1;
		}
		
//    CCLOG(@"nHillVertices = %d", nHillVertices);
		
		prevFromKeyPointI = fromKeyPointI;
		prevToKeyPointI = toKeyPointI;
	}
}

- (void) setOffsetX:(float)offsetX {
	if (_offsetX != offsetX || firstTime) {
		firstTime = NO;
		_offsetX = offsetX;
		self.position = ccp(screenW/8-_offsetX*self.scale, 0);
		[self refreshHillVertices];
	}
}

//draws every step
- (void) draw {
	
#ifdef DRAW_BOX2D_WORLD
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glPushMatrix();
	glScalef(CC_CONTENT_SCALE_FACTOR(), CC_CONTENT_SCALE_FACTOR(), 1.0f);
	world->DrawDebugData();
	glPopMatrix();
	
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
#else
//	CCLOG(@"stripes texture %@ ", _sprite);
	glBindTexture(GL_TEXTURE_2D, _sprite.texture.name);
	
	glDisableClientState(GL_COLOR_ARRAY);
	
	glColor4f(1, 1, 1, 1);
	glVertexPointer(2, GL_FLOAT, 0, hillVertices);
	glTexCoordPointer(2, GL_FLOAT, 0, hillTexCoords);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)nHillVertices);
	
	glEnableClientState(GL_COLOR_ARRAY);
	
#endif
}

- (void) reset {
	
#ifndef DRAW_BOX2D_WORLD
	self.sprite = [self generateSprite];
#endif
	
  firstTime = YES;
	fromKeyPointI = 0;
	toKeyPointI = 0;
  self.offsetX = 0;
}

- (void)addImageItemWithType:(int)cType At:(int)index To:(NSMutableArray *)items
{
  index *= CC_CONTENT_SCALE_FACTOR();
    
  NSString *name;
  float offsetFactor = TERRAIN_IMAGE_OFFSET_FACTOR;
  
  switch ( cType ) {
    case cTerrainImageItemTree:
      name = IMAGE_TREE;
      offsetFactor = 2.25f + arc4random() % 10 * 0.1f;
      break;
    case cTerrainImageItemBush:
      name = IMAGE_BUSH;
      offsetFactor = 4.5f + arc4random() % 10 * 0.1f;
      break;
    case cTerrainImageItemWood:
      name = IMAGE_WOOD;
      offsetFactor = 3.75f + arc4random() % 10 * 0.1f;
      break;
    case cTerrainImageItemGrass:
      name = IMAGE_GRASS;
      offsetFactor = TERRAIN_IMAGE_OFFSET_FACTOR;
      break;
    case cTerrainImageItemTemple:
      name = IMAGE_TEMPLE;
      offsetFactor = kTemplePositionYOffset;
      break;
    default:
      name = IMAGE_GRASS;
      break;
  }
  
  if (name != nil) { 
    TerrainImageItem *tii = (TerrainImageItem *)[TerrainImageItem createItemWithImage:name On:self At:index Offset:offsetFactor];
    if (items != nil) {
      [items addObject:tii];
    }
  }

}


- (void)addImageItemsWithType:(int)cType At:(int *)indices To:(NSMutableArray *)items{
  for (int i=0; i < kMaxTerrainItems; i++) {
    if (indices[i]) {
      [self addImageItemWithType:cType At:indices[i] To:items];
    }  
  }
}


@end
