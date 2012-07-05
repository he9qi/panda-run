/* see TriangleMesh.cpp for details
 */
#ifndef __TRIANGLE_MESH_H
#define __TRIANGLE_MESH_H

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include <assert.h>

#ifndef TRIANGLEMESH_STANDALONE
#include "Box2D.h"
#else
   typedef float      float32;
   typedef signed int int32;
#endif

#define tmVERSION 1.004

#define tmAssert(condition) assert((condition))
#define tmMin( a, b)  ((a) < (b) ) ? (a) : (b)
#define tmMax( a, b)  ((a) > (b) ) ? (a) : (b)
#define tmAbs( a )    fabs( (a) )

// errors and warnings
#define tmE_OK                0
#define tmE_MEM               1
#define tmE_HOLES             2
#define tmE_NOINSIDETRIANGLES 3
#define tmE_INTERSECTS        4
#define tmE_OPENFILEWT        5

// constants
#define tmC_ZEROTOL    0.00001f         // actually not used
#define tmC_PI         3.14159265359f   // pi
#define tmC_PIx2       6.28318530718f   // 2 pi
#define tmC_PI_3       1.04719755119f   // pi/3
#define tmC_SQRT2      1.41421356237f   // squareroot of 2
// default big number to calculate a triangle covering all points (vertices[0-2])
#define tmC_BIGNUMBER       1.0e10f
// default maximal number of vertices (resp. nodes)
#define tmC_DEFAULTMAXVERTEX 500
// default abort-inserting if tmO_GRADING option set (angle in deg)
#define tmC_DEFAULTGRADINGLOWERANGLE   30.0f

// TriangleMesh::options
// automatic segment boundary vertices => SegmentVertices()
#define tmO_SEGMENTBOUNDARY   2
// hull vertices => ConvexHull()
#define tmO_CONVEXHULL        4
// abort (=>InsertSegments()), if worst angle > minAngle
#define tmO_MINIMALGRID       8  // depreciated
#define tmO_GRADING           8
// turn on intesection check => HasIntersections()
#define tmO_CHECKINTERSECT   16
// bits for playing... around,debugging and testing, see code
#define tmO_BASICMESH        64
#define tmO_NOCALC          128
#define tmO_BASICMESHNODEL  256
#define tmO_WRITEINPUT      512 

typedef struct
{
  float32 x,y;
} tmVertex;

typedef struct
{
  tmVertex *v[2];
} tmSegment;

typedef struct
{
  int32 i1,i2;
} tmSegmentId;

typedef struct
{
 tmVertex        *v[2];
 struct Triangle *t[2];
 bool   locked;
} tmEdge ;

typedef struct Triangle
{
 tmVertex *v[3];
 tmEdge   *e[3];
 float32 minAngle, angle;
 float32 area;
 bool    inside;
 // hold attributes for the triangles, external use only
 void    *userData;
} tmTriangle;

class TriangleMesh
{
  public:
   // defaults at instancing
   TriangleMesh(int32 aMaxVertexCount=tmC_DEFAULTMAXVERTEX,
                int32 aOptions=tmO_GRADING|tmO_CONVEXHULL);
   // main mesh function 1)
   int32  Mesh(tmVertex *input, int32 n_input,
               tmSegmentId *segment=NULL, int32 n_segment=0,
               tmVertex *hole=NULL, int32 n_holes=0);
   //                    2)
   int32  Mesh(tmVertex *input, int32 n_input,
               tmVertex *segment, int32 n_segment,
               tmVertex *hole, int32 n_holes);

   void SegmentVertices(int32 startNode, int32 endNode, bool doclose);
   // set-funtions
   void SetOptions(int32 aOptions)     { options = aOptions;  }
   void AddOption(int32 aOptions)      { options |= aOptions; }
   void DeleteOption(int32 aOptions)   { options &= ~aOptions; }
   void SetMaxVertexCount(int32 count)
   {
       if ( count>3 )
       {
           maxVertexCount = count;
           options &= ~tmO_GRADING;
       }
   }
   void   SetGradingLowerAngle(float32 angle)
   {
       gradingLowerAngle = angle;
       options |= tmO_GRADING;
   }
   // get-functions, should be const...
   int32  GetVertexCount()          { return vertexCount;        }
   int32  GetInputVertexCount()     { return inputVertexCount;   }
   int32  GetEdgeCount()            { return edgeCount;          }
   int32  GetTriangleCount()        { return triangleCount;      }
   int32  GetSegmentCount()         { return segmentCount;       }
   int32  GetHoleCount()            { return holeCount;          }
   int32  GetInsideTriangleCount()  { return insideTriangleCount;}
   tmVertex*     GetVertices()      { return Vertices;           }
   tmEdge*       GetEdges()         { return Edges;              }
   tmTriangle*   GetTriangles()     { return Triangles;          }
   tmSegment*    GetSegments()      { return Segments;           }
   tmVertex*     GetHoles()         { return Holes;              }

   // utilities
   tmVertex    PolygonCenter(tmVertex* v, int32 n, int32 from=0);
   void        FreeMemory();
   void        PrintData(FILE* f = stdout);
   int32       PrintTriangles();
   const char* GetErrorMessage(int32 errId);


  private:
   // data
   tmVertex   *Vertices;
   tmEdge     *Edges;
   tmTriangle *Triangles;
   tmSegment  *Segments;
   tmVertex   *Holes;

   int32       maxVertexCount, maxEdgeCount,
               maxTriangleCount,maxSegmentCount;
   int32       vertexCount, inputVertexCount;
   int32       edgeCount, triangleCount, segmentCount, holeCount;
   int32       insideTriangleCount;
   bool        haveEnoughVertices;

   float32     gradingLowerAngle;

   int32       options;

   tmTriangle *lastTriangle;
   char        lastErrorMessage[128];

   // internal functions
   int32       Setup(int32* endVertex, tmVertex *input, int32 n_input,
                     tmSegmentId *segment=NULL, int32 n_segment=0,
                     tmVertex *hole=NULL, int32 n_holes=0);

   int32       DoMesh(int32 n_input);

   void        Triangulate();

   bool        Intersect(tmVertex* v1, tmVertex* v2, tmVertex* w1, tmVertex* w2);
   bool        HasIntersections(tmVertex* v, int32 start, int32 end);

   int32       MarkInsideTriangles(bool holes);
   void        InsertSegments();
   void        DeleteBadTriangles();
   void        DeleteTriangle(tmTriangle* t);

   tmVertex   *AddVertex();
   tmVertex   *GetClosestVertex(float32 x, float32 y);
   tmTriangle *FindVertex(tmVertex* v);
   bool        ContainsVertex(tmVertex* v0, tmVertex* v1, tmVertex* v);
   float32     GetVertexPosition(tmVertex* a, tmVertex* b, tmVertex* c);
   bool        InsertVertexAt(tmVertex* v, tmEdge* e);
   bool        InsertVertex(tmVertex* v);
   bool        SameVertex(tmVertex* v0, tmVertex* v1);
   tmVertex   *GetOppositeVertex(tmEdge* e, tmTriangle* t);

   tmEdge     *AddEdge();
   void        SetEdge(tmEdge* e, tmVertex* v0, tmVertex* v1, tmTriangle* t0, tmTriangle* t1);
   void        FixEdge(tmEdge* e, tmTriangle* t0, tmTriangle* t1);
   tmEdge     *GetEdge(tmVertex* v0, tmVertex* v1);
   bool        CheckEdge(tmEdge* e);
   tmSegment  *AddSegment();
   tmSegment  *GetSegment(tmVertex* v0, tmVertex* v1);

   tmTriangle *AddTriangle();
   void        SetTriangle(tmTriangle* t,
                           tmVertex* v0, tmVertex* v1, tmVertex* v2,
                           tmEdge* e0, tmEdge* e1, tmEdge* e2);
   bool        SetTriangleData(tmVertex* v0,tmVertex* v1,tmVertex* v2,
                               float32 *minAngle, float32 *angle, float32 *area);

   void        GetAdjacentEdges(tmEdge* e, tmTriangle* t,
                                tmEdge** e0, tmEdge** e1, tmVertex** v);
   bool        IsOppositeVertex(tmVertex* v0, tmVertex* v1, tmVertex* v2);
   bool        HasBoundingVertices(tmVertex* v0,tmVertex* v1,tmVertex* v2);
   void        CircumCenter(tmVertex* c, tmTriangle* t);
   void        GetSplitPosition(tmVertex* v, tmVertex* v0, tmVertex* v1);
   bool        SplitSegment(tmSegment* s);
   void        ConvexHull();
#ifdef TEST_WriteInput
   int32       WriteInput(tmSegmentId* seg, int32 n_seg);
#endif   
   void        Reset();
   void       *Alloc(size_t size);
   void        CheckNumber(float32 x);
   float32     ArcTan2(float32 x, float32 y);
   float32     GetAngle(float32 a1, float32 a0);
};

#endif


