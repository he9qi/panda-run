/* A lite constrained delauney triangle mesh generator,supporting holes and
 * non convex boundaries.
 * (c) 2008 nimodo@hispeed.ch
 *
 * See
 * 1) A Delaunay Refinement Algorithm for Quality 2-Dimensional Mesh Generation
 *    Jim Ruppert - Journal of Algorithms, 1995
 * 2) Jonathan Shewchuk
 *    http://www.cs.cmu.edu/~quake/triangle.html
 * 3) Recursive triangle eating
 *    François Labelle
 *    http://www.cs.berkeley.edu/~flab/
 * 4) example - at the end of this file
 *
 * History
 * 2001/03 as part of a basic FEA package
 * 2008/05 some small changes for box2d
 * 2008/06 small bugs
 *         tmO_BASICMESH option for testing only, works sometimes ;)
 *         some comments (see .h file)
 *         variable names changed for better understanding, example
 *         - tmO_MINIMALGRID renamed to tmO_GRADING, used option with
 *           gradingLowerANgle
 *         bug in SegmentVertices()
 *         playing with "zero tolerances..."
 *         GetVersion() added
 * 2008/07 tmO_CHECKINTERSEC (optional) added, see HasIntersections()
 *         alternative to Mesh() added, using tmVertex* instead of tmSegmentId*
 *         malloc() replaced with Alloc()
 *         zlib license added
 *
 * License
 *   This software is provided 'as-is', without any express or implied
 *   warranty.  In no event will the authors be held liable for any damages
 *   arising from the use of this software.
 *   Permission is granted to anyone to use this software for any purpose,
 *   including commercial applications, and to alter it and redistribute it
 *   freely, subject to the following restrictions:
 *   1. The origin of this software must not be misrepresented; you must not
 *   claim that you wrote the original software. If you use this software
 *   in a product, an acknowledgment in the product documentation would be
 *   appreciated but is not required.
 *   2. Altered source versions must be plainly marked as such, and must not be
 *   misrepresented as being the original software.
 *   3. This notice may not be removed or altered from any source distribution.
 */

#include "TriangleMesh.h"

/*----------------------------------------------------------------------------*/
TriangleMesh::TriangleMesh(int32 aMaxVertexCount, int32 aOptions)
{
    Reset();
    maxVertexCount    = aMaxVertexCount;
    options           = aOptions;
    gradingLowerAngle = tmC_DEFAULTGRADINGLOWERANGLE;
    haveEnoughVertices= false;
}

/*----------------------------------------------------------------------------*/
int32 TriangleMesh::Mesh(tmVertex *input, int32 n_input,
                         tmSegmentId *segment, int32 n_segment,
                         tmVertex *hole, int32 n_holes)
{
    int32 endVertex, rtn;

    // setup data
    rtn = Setup(&endVertex, input, n_input, segment, n_segment,  hole, n_holes);
     
    if ( rtn!=tmE_OK ) return(rtn);

    // for testing only
    if ( options&tmO_NOCALC ) return 0;

    // check intersections
    if ( (options&tmO_CHECKINTERSECT) )
    {
      if ( HasIntersections(input, 0, endVertex) )
        return(tmE_INTERSECTS);
    }

    // mesh main
    rtn = DoMesh(n_input);

    return rtn;
}


/*----------------------------------------------------------------------------*/
/* alternative, segments given as points */
int32 TriangleMesh::Mesh(tmVertex *input, int32 n_input,
                         tmVertex *segments, int32 n_segments,
                         tmVertex *hole, int32 n_holes)
{
    int32 i,endVertex, rtn;
    tmSegmentId *sid;
    tmVertex    *v;

    // alloc space
    sid = (tmSegmentId *) Alloc(n_segments * sizeof(tmSegmentId));
    v   = (tmVertex    *) Alloc( (n_input+n_segments) * sizeof(tmVertex));

    // copy points and assign seg id's
    for ( i=0; i<n_input; i++ )
    {
      v[i].x = input[i].x;
      v[i].y = input[i].y;
    }
    for ( i=n_input; i<n_input+n_segments; i++ )
    {
      v[i].x = segments[i-n_input].x;
      v[i].y = segments[i-n_input].y;
    }
    for ( i=0; i<n_segments-1; i++ )
    {
      sid[i].i1 = n_input+i+1;
      sid[i].i2 = n_input+i+2;
    }
    sid[i].i1 = n_input+i+1;
    sid[i].i2 = n_input+1;

    // setup data
    rtn = Setup(&endVertex, v, n_input+n_segments, sid, n_segments,  hole, n_holes);

    // clean
    free(sid);
    free(v);

    if ( rtn!=tmE_OK ) return(rtn);

    // for testing only
    if ( options&tmO_NOCALC ) return 0;

    // check intersections
    if ( (options&tmO_CHECKINTERSECT) )
    {
      if ( HasIntersections(input, 0, endVertex) )
          return(tmE_INTERSECTS);
    }

    // mesh main
    rtn = DoMesh(n_input+n_segments);

    return rtn;
}

#ifdef TEST_WriteInput
/*----------------------------------------------------------------------------*/
int32 TriangleMesh::WriteInput(tmSegmentId* seg, int32 n_seg)
{
    int32 i;
    errno_t err;
    FILE *f;
    err = fopen_s(&f,"input.dat","wt"); 
    if ( err!=0 ) return(tmE_OPENFILEWT);
    fprintf(f,"input\n#vertices\n%d\n",inputVertexCount);
    for (i=0;i<inputVertexCount;i++)
      fprintf(f,"%d %G %G\n",i+1, (float)Vertices[i+3].x,(float)Vertices[i+3].y );

    fprintf(f,"#segments\n%d\n",n_seg); 
    for (i=0;i<n_seg;i++)
        fprintf(f,"%d %d %d\n",i+1,seg[i].i1, seg[i].i2); 

    fprintf(f,"#holes\n%d\n",holeCount); 
    for (i=0;i<holeCount;i++)
      fprintf(f,"%d %G %G\n",i+1, (float)Holes[i].x,(float)Holes[i].y );

    fclose(f);
    return(0);
}
#endif
/*----------------------------------------------------------------------------*/
int32 TriangleMesh::DoMesh(int32 n_input)
{
    int32 i, rtn = tmE_OK;
    bool hasInsideTriangles=false;

    // base triangulation
    Triangulate();

    // refine
    if ( !(options&tmO_BASICMESH) )
    {
      // needed for some pointer arith...
      inputVertexCount = vertexCount;

      // non convex graphs
      if ( options & tmO_CONVEXHULL ) ConvexHull();

      //
      InsertSegments();

      // mark triangles
      if ( haveEnoughVertices )
      {
         MarkInsideTriangles(true) ;

         for ( i=0; i<triangleCount; i++ )
         {
           if ( Triangles[i].inside )
           {
               hasInsideTriangles = true;
               break;
           }
         }
         if ( hasInsideTriangles==false ) return(tmE_NOINSIDETRIANGLES);
      }
      else
      {
         MarkInsideTriangles(false);
      }

      //
      tmEdge    *e;
      for ( i=0; i<segmentCount; i++ )
      {
        e  = GetEdge( Segments[i].v[0], Segments[i].v[1]);
        if ( e!=NULL ) e->locked = true ;
      }

      //
      DeleteBadTriangles();
    }
    else
    {
    // for testing only
    // quick & dirty hack for a mesh with lesser angles than with the
    // tmO_GRADING flag and gradingLowerAngle set
      MarkInsideTriangles( !(options&tmO_BASICMESHNODEL) );
    }

    // restore original number of input vertices
    inputVertexCount = n_input;

    // count inner triangles
    insideTriangleCount = 0;
    for ( i=0; i<triangleCount; i++)
    {
      if ( Triangles[i].inside )  insideTriangleCount++;
    }
    return (rtn);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::SegmentVertices(int32 startNode, int32 endNode, bool doclose)
{
    int32 i, k=segmentCount;

    for ( i=startNode-1; i<endNode-1; i++,k++ )
    {
      Segments[k].v[0] = &Vertices[i+3];
      Segments[k].v[1] = &Vertices[i+3+1];

      segmentCount++;
    }

    if ( doclose )
    {
      Segments[k].v[0] = &Vertices[i+3];
      Segments[k].v[1] = &Vertices[3];

      segmentCount++;
    }
}

/*----------------------------------------------------------------------------*/
tmVertex TriangleMesh::PolygonCenter(tmVertex* v, int32 n, int32 from )
{
    int32 i;
    tmVertex vc;
    vc.x = v[from].x;
    vc.y = v[from].y;
    for ( i=from+1; i<n; i++ )
    {
      vc.x += v[i].x;
      vc.y += v[i].y;
    }
    vc.x /= (float32)(n-from);
    vc.y /= (float32)(n-from);
    return(vc);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::FreeMemory()
{
    if (Vertices)  free(Vertices);
    if (Edges)     free(Edges);
    if (Triangles) free(Triangles);
    if (Segments)  free(Segments);
    Reset();
}

/*----------------------------------------------------------------------------*/
const char* TriangleMesh::GetErrorMessage(int32 errId)
{
 switch (errId)
 {
    case tmE_OK:
      strcpy(lastErrorMessage,"ok");
    break;

    case tmE_MEM:
      strcpy(lastErrorMessage,"memory allocation failed");
    break;

    case tmE_HOLES:
      strcpy(lastErrorMessage,"could not drill the holes");
    break;

    case tmE_NOINSIDETRIANGLES:
      strcpy(lastErrorMessage,"there are no inside triangles,all might be eaten");
    break;

    case tmE_INTERSECTS:
      strcpy(lastErrorMessage,"intersecting boundary segments found");
    break;

    default:
      strcpy(lastErrorMessage,"unknown error occurred");
    break;
 }

 return ((const char*)lastErrorMessage);
}

/*----------------------------------------------------------------------------*/
int32 TriangleMesh::PrintTriangles()
{
    tmTriangle *t0;
    for ( int32 i=0; i<triangleCount; i++ )
    {
       t0 = &Triangles[i];
       fprintf(stdout,
          "%04d;%6.2f;%6.2f;%6.2f;%6.2f;%6.2f;%6.2f;%d;%6.2f;%6.2f\n",i,
          (float)t0->v[0]->x,(float)t0->v[0]->y,(float)t0->v[1]->x,(float)t0->v[1]->y,
          (float)t0->v[2]->x,(float)t0->v[2]->y,(float)t0->inside,(float)t0->minAngle,(float)t0->angle);
    }
    return 0;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::PrintData(FILE *f)
{
    fprintf(f,"Options    : %d\n",  options);
    fprintf(f,"MinAngle   : %G\n",  (float)gradingLowerAngle);
    fprintf(f,"Max V/E/T/S: %d %d %d %d\n",maxVertexCount,maxEdgeCount,maxTriangleCount,maxSegmentCount);
    fprintf(f,"    actual : %d %d %d %d %d\n",vertexCount,edgeCount, triangleCount, segmentCount, holeCount);
    fprintf(f,"Vertices   : %d\n",vertexCount);
    fprintf(f,"Segments   : %d\n",segmentCount);
    fprintf(f,"Triangles  : %d (total: %d)\n",insideTriangleCount,triangleCount);
}

/*----------------------------------------------------------------------------
 *  INTERNAL
 */

/*----------------------------------------------------------------------------*/
int32 TriangleMesh::Setup(int32* endVertex, tmVertex *input, int32 n_input,
                          tmSegmentId *segment, int32 n_segment,
                          tmVertex *hole, int32 n_holes)
{
    int32 i,k,rtn = tmE_OK;

    inputVertexCount = n_input;
    vertexCount      = n_input + 3;

    // max sizes
    if (n_input>maxVertexCount) maxVertexCount = n_input;
    maxVertexCount  += 3;
    maxEdgeCount     = 3*maxVertexCount - 6;
    maxTriangleCount = 2*maxVertexCount - 5 + 1;
    maxSegmentCount  = 3*maxVertexCount - 6;

    // allocate space
    Vertices  = (tmVertex*)   Alloc(maxVertexCount * sizeof(tmVertex));
    Edges     = (tmEdge*)     Alloc(maxEdgeCount * sizeof(tmEdge));
    Triangles = (tmTriangle*) Alloc(maxTriangleCount * sizeof(tmTriangle));
    Segments  = (tmSegment *) Alloc(maxSegmentCount * sizeof(tmSegment));

    // first 3 points make a big equilateral triangle
    for ( i=0; i<3; i++ )
    {
      Vertices[i].x = tmC_BIGNUMBER * (float32)cos((float32)i*(tmC_PIx2/3.0f));
      Vertices[i].y = tmC_BIGNUMBER * (float32)sin((float32)i*(tmC_PIx2/3.0f));
    }

    // copy input vertices
    if ( input && n_input>0 )
    {
      for ( i=3; i<vertexCount; i++ )
      {
        Vertices[i].x = input[i-3].x;
        Vertices[i].y = input[i-3].y;
      }
    }

    // add boundary and close last/first,this adds ALL input vertices but
    // to the first input segment
    *endVertex = inputVertexCount;
    if ( (options&tmO_SEGMENTBOUNDARY) )
    {
      // find outer boundary end-node, assume first segment input is start
      // of inner boundaries (holes)
      if ( n_segment>0 )
      {
        if (    (segment[0].i1<inputVertexCount)
             && (segment[0].i2==segment[0].i1+1) )
          *endVertex = segment[0].i1-1;
      }
      SegmentVertices(1, *endVertex, true);
    }

    // given segments
    if ( n_segment>0 )
    {
      for ( i=segmentCount,k=0; i<segmentCount+n_segment; i++,k++ )
      {
        Segments[i].v[0] = &Vertices[segment[k].i1+3-1];
        Segments[i].v[1] = &Vertices[segment[k].i2+3-1];
      }
      segmentCount += n_segment;
    }

    // assign hole pointer (will not be freed by FreeMemory)
    holeCount = n_holes;
    Holes     = hole;

#ifdef TEST_WriteInput
    if (options & tmO_WRITEINPUT) WriteInput(segment, n_segment);
#endif
    return(rtn);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::Triangulate()
{
    tmVertex    *v0, *v1, *v2;
    tmTriangle  *t0, *t1;
    tmEdge      *e0, *e1, *e2;

    triangleCount = 0;
    edgeCount     = 0;
    lastTriangle  = NULL;

    v0 = &Vertices[0];
    v1 = &Vertices[1];
    v2 = &Vertices[2];

    t0 = AddTriangle();
    t1 = AddTriangle();

    e0 = AddEdge();
    e1 = AddEdge();
    e2 = AddEdge();

    SetTriangle( t0, v0, v1, v2, e0, e1, e2);
    SetTriangle( t1, v0, v2, v1, e2, e1, e0);

    SetEdge(e0, v0, v1, t0, t1);
    SetEdge(e1, v1, v2, t0, t1);
    SetEdge(e2, v2, v0, t0, t1);

    for ( int32 i=3; i<vertexCount; i++)
       InsertVertex( &Vertices[i]);

}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::Intersect(tmVertex *v0, tmVertex *v1,
                             tmVertex *w0, tmVertex *w1)
{
    float32 d1, d2;

    // check consecutive vertices
    if ( v0==w1 || v1==w0 )   return false;

    // test v for intersection
    d1 = GetVertexPosition(v0, v1, w0);
    d2 = GetVertexPosition(v0, v1, w1);
    if ( d1*d2 > 0.0f ) return false;    // same sign

    // test w for intersection
    d1 = GetVertexPosition(w0, w1, v0);
    d2 = GetVertexPosition(w0, w1, v1);
    if ( d1*d2 > 0.0f ) return false;   // same sign

    // intersection
    return true;     
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::HasIntersections(tmVertex *v, int32 start, int32 end)
{
   int32 i,i1, k,k1;
   for ( i=start; i<end; i++ )
   {
      i1 = (i < end-1) ? i+1 : start;
      for ( k=i+1; k<end; k++)
      {
         k1 = (k<end-1) ? k+1 : start;
         if ( Intersect( &v[i],&v[i1], &v[k],&v[k1] ) )  return true;
      }
   }
   return false;
}

/*----------------------------------------------------------------------------*/
int32 TriangleMesh::MarkInsideTriangles(bool nonconvex)
{
    int32 i, rtn=tmE_OK;
    tmTriangle *t;

    if ( nonconvex )
    {
      DeleteTriangle( &Triangles[1]);
      for ( i=0; i<holeCount; i++ )
      {
        t = FindVertex(  &Holes[i] );
        if ( t==NULL ) rtn = tmE_HOLES;
        else           DeleteTriangle(t);
      }
    }
    else
    {
      for ( i=0; i<triangleCount; i++ )
      {
        Triangles[i].inside = (
              (Triangles[i].v[0] - Vertices) >= 3
           && (Triangles[i].v[1] - Vertices) >= 3
           && (Triangles[i].v[2] - Vertices) >= 3   );
      }
    }
    return(rtn);
}


/*----------------------------------------------------------------------------*/
#define SetSegment(s,v0,v1)  { s->v[0] = v0; s->v[1] = v1; }

/*----------------------------------------------------------------------------*/
void TriangleMesh::InsertSegments()
{
    int32 i;
    tmVertex  *v0, *v1, *v;
    tmSegment *s,  *t;
    tmEdge    *e;
    bool inserting;

    do {

        inserting = false;
        for ( i=0; i<segmentCount; i++ )
        {
            s  = &Segments[i];
            v0 = s->v[0];
            v1 = s->v[1];

            e = GetEdge( v0, v1);
            if ( e==NULL )
            {
                v = AddVertex();
                if (v == NULL) return;
                t = AddSegment();
                SetSegment(s, v0, v);
                SetSegment(t, v, v1);
                GetSplitPosition( v, v0, v1);
                inserting = InsertVertex( v);
            }
            else if (    ContainsVertex(e->v[0], e->v[1], GetOppositeVertex(e, e->t[0]) )
                      || ContainsVertex(e->v[0], e->v[1], GetOppositeVertex(e, e->t[1]) )
                    )
            {
                inserting = SplitSegment(s);
            }
        }

        if ( vertexCount==maxVertexCount )
        {
          haveEnoughVertices = false;
          return;
        }

    } while ( inserting );

    haveEnoughVertices = true;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::CircumCenter(tmVertex *c, tmTriangle *t)
{
    float32 c0x, c0y;
    float32 c1x, c1y;
    float32 dx, dy, ex, ey, f, e2, d2;
    tmVertex *v;
    // center
    c0x = (t->v[0]->x + t->v[1]->x + t->v[2]->x)/3.0f;
    c0y = (t->v[0]->y + t->v[1]->y + t->v[2]->y)/3.0f;
    // deltas
    dx  = t->v[1]->x - t->v[0]->x;
    dy  = t->v[1]->y - t->v[0]->y;
    ex  = t->v[2]->x - t->v[0]->x;
    ey  = t->v[2]->y - t->v[0]->y;
    //
    f   = 0.5f / (ex*dy - ey*dx);
    e2  = ex*ex + ey*ey;
    d2  = dx*dx + dy*dy;
    c1x = t->v[0]->x + f * (e2*dy - d2*ey);
    c1y = t->v[0]->y + f * (d2*ex - e2*dx);
    // look if already existing
    for ( int32 i=0; i<20; i++ )
    {
        c->x = c1x;
        c->y = c1y;
        if ( FindVertex(c)!=NULL)
        {
          v = GetClosestVertex( c1x, c1y);
          if ( (v==t->v[0]) || (v==t->v[1]) || (v==t->v[2]) ) return;
        }
        c1x = c0x + 0.9f*(c1x-c0x);
        c1y = c0y + 0.9f*(c1y-c0y);
    }
    // center
    c->x = c0x;
    c->y = c0y;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::DeleteBadTriangles()
{
    int32       i;
    float32     angle;
    tmTriangle *t, *tBad=NULL;
    tmVertex    vc, *v;
    bool        isInside;

    while ( vertexCount<maxVertexCount )
    {
        angle = tmC_BIGNUMBER;

        for ( i=0; i<triangleCount; i++ )
        {
            t = &Triangles[i];
            if ( t->inside && ( t->angle<angle )  )  
            {
                angle  = t->angle;
                tBad   = t;
            }
        }

        if ( (options & tmO_GRADING) && (angle>=gradingLowerAngle) )
                   return;

        CircumCenter( &vc, tBad);

        isInside = false;
        for ( i=0; i<segmentCount; i++)
        {
            if ( ContainsVertex(Segments[i].v[0], Segments[i].v[1], &vc) )
            {
                if ( SplitSegment( &Segments[i]) )
                {
                   isInside = true;
                }
            }
        }

        if ( isInside==false )
        {
            v  = AddVertex();
            if ( v==NULL) return;
            *v = vc;
            InsertVertex( v );
        }
    }
}

/*----------------------------------------------------------------------------*/
// delete recursive 
void TriangleMesh::DeleteTriangle(tmTriangle *t)
{
    tmEdge *e;

    if ( t->inside==false ) return;

    /* */
    t->inside = false;
    for (int32 i=0; i<3; i++ )
    {
        e = t->e[i];
        if ( GetSegment( e->v[0], e->v[1])==NULL )
        {
            if      ( e->t[0]==t ) DeleteTriangle( e->t[1]);
            else if ( e->t[1]==t ) DeleteTriangle( e->t[0]);
            else    tmAssert( (e->t[0]==t) || (e->t[1]==t) )  ;
        }
    }
}

/*----------------------------------------------------------------------------*/
tmVertex* TriangleMesh::AddVertex()
{
    if ( vertexCount >= maxVertexCount)  return NULL;
    return &Vertices[vertexCount++];
}

/*----------------------------------------------------------------------------*/
tmVertex* TriangleMesh::GetClosestVertex(float32 x, float32 y)
{
    float32  dx, dy, d2;
    float32  dmin=0.0f;
    tmVertex *v=NULL;

    for (int32 i=0; i<vertexCount; i++ )
    {
        dx = Vertices[i].x - x;
        dy = Vertices[i].y - y;
        d2 = dx*dx + dy*dy;
        if ( (i==0) || (d2<dmin) )
        {
            dmin    = d2;
            v = &Vertices[i];
        }
    }
    return(v);
}

/*----------------------------------------------------------------------------*/
tmTriangle* TriangleMesh::FindVertex(tmVertex *v)
{
    tmTriangle *t;
    tmVertex   *v0, *v1;
    tmEdge     *e;

    /* initialize */
    t = lastTriangle;
    if ( t==NULL ) t = &Triangles[1];
    /* search */
repeat:
    for (int32 i=0; i<3; i++ )
    {
        v0 = t->v[i];
        v1 = t->v[(i==2) ? 0 : i+1];
        if ( GetVertexPosition( v0,v1,v )<0.0f )
        {
            e = t->e[i];
            if      ( e->t[0]==t )  t = e->t[1];
            else if ( e->t[1]==t )  t = e->t[0];
            else tmAssert( 0 );
            goto repeat;
        }
    }
    /* found */
    lastTriangle = t;
    return ( (t->inside) ? t : NULL );
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::ContainsVertex(tmVertex *v0, tmVertex *v1, tmVertex *v)
{
    float32 cx, cy, dx, dy, r2, d2;
    cx = 0.5f * (v0->x + v1->x);
    cy = 0.5f * (v0->y + v1->y);
    dx = v1->x - cx;
    dy = v1->y - cy;
    r2 = dx*dx + dy*dy;
    dx = v->x - cx;
    dy = v->y - cy;
    d2 = dx*dx + dy*dy;
    return ( (d2<r2) );
}

/*----------------------------------------------------------------------------*/
float32 TriangleMesh::GetVertexPosition(tmVertex *a, tmVertex *b, tmVertex *c)
{
    float32 d1, d2;
    if ( ( (c-Vertices)>=0 ) && ( (c-Vertices)<3 ) )
    {
        d1 = (b->x - a->x)*(c->y - a->y);
        d2 = (b->y - a->y)*(c->x - a->x);
    }
    else
    {
        d1 = (a->x - c->x)*(b->y - c->y);
        d2 = (a->y - c->y)*(b->x - c->x);
    }
    return (d1-d2);
}
/*----------------------------------------------------------------------------*/
bool TriangleMesh::InsertVertexAt(tmVertex *v, tmEdge *e)
{
    tmVertex   *v0, *v1, *v2, *v3;
    tmEdge     *e0, *e1, *e2, *e3, *f0, *f1, *f2;
    tmTriangle *t0, *t1, *t2, *t3;
    bool i0, i1, locked;

    t0 = e->t[0];
    t1 = e->t[1];
    v0 = e->v[0];
    v2 = e->v[1];
    GetAdjacentEdges(e, t0, &e2, &e3, &v3);
    GetAdjacentEdges(e, t1, &e0, &e1, &v1);

    t2 = AddTriangle();
    t3 = AddTriangle();

    f0 = AddEdge();
    f1 = AddEdge();
    f2 = AddEdge();

    i0     = t0->inside;
    i1     = t1->inside;
    locked = e->locked;

    SetTriangle( t0, v3, v0, v, e3, e, f2);
    SetTriangle( t1, v0, v1, v, e0, f0, e);
    SetTriangle( t2, v1, v2, v, e1, f1, f0);
    SetTriangle( t3, v2, v3, v, e2, f2, f1);

    SetEdge(e, v0, v, t0, t1);
    SetEdge(f0, v1, v, t1, t2);
    SetEdge(f1, v2, v, t2, t3);
    SetEdge(f2, v3, v, t3, t0);

    FixEdge(e1, t1, t2);
    FixEdge(e2, t0, t3);

    t0->inside = i0;
    t1->inside = i1;
    t2->inside = i1;
    t3->inside = i0;

    e->locked  = locked;
    f1->locked = locked;

    if ( i0 )
    {
        CheckEdge( e2);
        CheckEdge( e3);
    }
    if ( i1 )
    {
        CheckEdge( e0);
        CheckEdge( e1);
    }

    return(true);
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::InsertVertex(tmVertex *v)
{
    tmTriangle *t0, *t1, *t2;
    tmVertex *v0, *v1, *v2;
    tmEdge *e0, *e1, *e2, *f0, *f1, *f2;

    t0 = FindVertex( v);
    if ( t0==NULL ) return false;

    for (int32 i=0; i<3; i++ )
    {
        v0 = t0->v[i];
        v1 = t0->v[(i == 2) ? 0 : i+1];
        if ( GetVertexPosition(v0, v1, v)==0.0f )
        {
            return( InsertVertexAt( v, t0->e[i] ) );
        }
    }

    v0 = t0->v[0]; v1 = t0->v[1]; v2 = t0->v[2];
    e0 = t0->e[0]; e1 = t0->e[1]; e2 = t0->e[2];

    t1 = AddTriangle();
    t2 = AddTriangle();
    f0 = AddEdge();
    f1 = AddEdge();
    f2 = AddEdge();

    SetTriangle( t0, v0, v1, v, e0, f1, f0);
    SetTriangle( t1, v1, v2, v, e1, f2, f1);
    SetTriangle( t2, v2, v0, v, e2, f0, f2);

    SetEdge(f0, v0, v, t2, t0);
    SetEdge(f1, v1, v, t0, t1);
    SetEdge(f2, v2, v, t1, t2);

    FixEdge(e1, t0, t1);
    FixEdge(e2, t0, t2);

    CheckEdge( e0);
    CheckEdge( e1);
    CheckEdge( e2);

    return(true);
}

/*----------------------------------------------------------------------------*/
tmVertex* TriangleMesh::GetOppositeVertex(tmEdge *e, tmTriangle *t)
{
    if ( e==t->e[0]) return(t->v[2]);
    if ( e==t->e[1]) return(t->v[0]);
    if ( e==t->e[2]) return(t->v[1]);
    return(NULL);
}

/*----------------------------------------------------------------------------*/
tmEdge* TriangleMesh::AddEdge()
{
    tmAssert( edgeCount<maxEdgeCount ) ;
    return &Edges[edgeCount++];
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::SetEdge(tmEdge *e, tmVertex *v0, tmVertex *v1, tmTriangle *t0, tmTriangle *t1)
{
    e->v[0] = v0;  e->v[1] = v1;
    e->t[0] = t0;  e->t[1] = t1;
    e->locked      = false;
}

/*----------------------------------------------------------------------------*/
tmEdge* TriangleMesh::GetEdge(tmVertex *v0, tmVertex *v1)
{
    for ( int32 i=0; i<edgeCount; i++ )
    {
      if (   (v0==Edges[i].v[0]) && (v1==Edges[i].v[1])
          || (v0==Edges[i].v[1]) && (v1==Edges[i].v[0]) )
            return &Edges[i];
    }
    return NULL;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::FixEdge(tmEdge *e, tmTriangle *t0, tmTriangle *t1)
{
    tmAssert( (e->t[0]==t0) || (e->t[1]==t0) );

    if      ( e->t[0]==t0 )  e->t[0] = t1;
    else if ( e->t[1]==t0 )  e->t[1] = t1;
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::CheckEdge(tmEdge *e)
{
    tmVertex   *v0, *v1, *v2, *v3;
    tmEdge     *e0, *e1, *e2, *e3;
    tmTriangle *t0, *t1;
    int32   cCount,pCount;
    float32 cAngle,pAngle;
    float32 a0, a1, q0, q1, s;

    if ( e->locked ) return(false);
    t0 = e->t[0];  t1 = e->t[1];
    tmAssert( t0->inside==t1->inside );

    v0 = e->v[0];  v2 = e->v[1];
    GetAdjacentEdges(e, t0, &e2, &e3, &v3);
    GetAdjacentEdges(e, t1, &e0, &e1, &v1);
    if (    GetVertexPosition(  v1, v3, v2)>=0.0f
         || GetVertexPosition( v1, v3, v0)<=0.0f )   return(false);

    cCount = 0;
    if ( HasBoundingVertices( v0, v2, v3) ) cCount++;
    if ( HasBoundingVertices( v2, v0, v1) ) cCount++;
    a0 = t0->minAngle;
    a1 = t1->minAngle;
    cAngle = (a0 < a1) ? a0 : a1;

    pCount = 0;
    if ( HasBoundingVertices( v1, v3, v0) ) pCount++;
    if ( HasBoundingVertices( v3, v1, v2) ) pCount++;
    SetTriangleData( v1, v3, v0, &a0, &q0, &s);
    SetTriangleData( v3, v1, v2, &a1, &q1, &s);
    pAngle = (a0 < a1) ? a0 : a1;

    if ( (pCount<cCount) || (pAngle>cAngle) )
    {
        SetTriangle( t0, v1, v3, v0, e, e3, e0);
        SetTriangle( t1, v3, v1, v2, e, e1, e2);

        SetEdge( e, v1, v3, t0, t1);
        FixEdge( e0, t1, t0);
        FixEdge( e2, t0, t1);

        CheckEdge( e0);
        CheckEdge( e1);
        CheckEdge( e2);
        CheckEdge( e3);
        return(true);
    }
    return(false);
}

/*----------------------------------------------------------------------------*/
tmSegment* TriangleMesh::AddSegment()
{
    tmAssert( segmentCount<maxSegmentCount );
    return &Segments[segmentCount++];
}

/*----------------------------------------------------------------------------*/
tmSegment* TriangleMesh::GetSegment(tmVertex *v0, tmVertex *v1)
{
    tmVertex *x0, *x1;

    for (int32 i=0; i<segmentCount; i++)
    {
        x0 = Segments[i].v[0];
        x1 = Segments[i].v[1];
        if ( (v0==x0) && (v1==x1) || (v0==x1) && (v1==x0) )
            return &Segments[i];
    }
    return NULL;
}

/*----------------------------------------------------------------------------*/
tmTriangle* TriangleMesh::AddTriangle()
{
    tmAssert(triangleCount<maxTriangleCount);
    Triangles[triangleCount].userData = NULL;
    return &Triangles[triangleCount++];
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::SetTriangle(tmTriangle *t,
                               tmVertex *v0, tmVertex *v1, tmVertex *v2,
                               tmEdge *e0, tmEdge *e1, tmEdge *e2)
{
    t->v[0] = v0;  t->v[1] = v1;  t->v[2] = v2;
    t->e[0] = e0;  t->e[1] = e1;  t->e[2] = e2;
    SetTriangleData( v0, v1, v2, &t->minAngle, &t->angle, &t->area);
    t->inside = true;
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::SetTriangleData(tmVertex *v0,
                                   tmVertex *v1,
                                   tmVertex *v2,
                                   float32 *minAngle, float32 *angle, float32 *area)
{
    float32 d0x, d0y, d1x, d1y, d2x, d2y;
    float32 t0, t1, t2;
    float32 a0, a1, a2, amin,d;

    d0x = v1->x - v0->x;  d0y = v1->y - v0->y;
    d1x = v2->x - v1->x;  d1y = v2->y - v1->y;
    d2x = v0->x - v2->x;  d2y = v0->y - v2->y;

    t0 = ArcTan2(d0y, d0x);
    t1 = ArcTan2(d1y, d1x);
    t2 = ArcTan2(d2y, d2x);

    a0 = GetAngle(t2 + tmC_PI, t0);
    a1 = GetAngle(t0 + tmC_PI, t1);
    a2 = GetAngle(t1 + tmC_PI, t2);
    amin = (a0 < a1) ? a0 : a1;
    if ( a2 < amin ) amin = a2;
    *minAngle = amin*180.0f/tmC_PI;


    if ( IsOppositeVertex( v2, v0, v1) )  a0 = tmC_PI_3;
    if ( IsOppositeVertex( v0, v1, v2) )  a1 = tmC_PI_3;
    if ( IsOppositeVertex( v1, v2, v0) )  a2 = tmC_PI_3;
    amin = (a0 < a1) ? a0 : a1;
    if ( a2<amin ) amin = a2;

    if ( options & tmO_GRADING )
    {
        *angle = amin*180.0f/tmC_PI;
    }
    else
    {
        d =   sqrt( d0x*d0x + d0y*d0y )
            + sqrt( d1x*d1x + d1y*d1y )
            + sqrt( d2x*d2x + d2y*d2y );
        *angle = amin/d/d;
    }

    // actually not used
    if ( area )
    {
       *area   = 0.5f * (    v0->x*v1->y - v1->x*v0->y
                          -  v0->x*v2->y + v2->x*v0->y
                          +  v1->x*v2->y - v2->x*v1->y  );
       if ( *area<0.0f ) return(false);
    }

    return(true);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::GetAdjacentEdges(tmEdge *e, tmTriangle *t,
                                    tmEdge **e0, tmEdge **e1, tmVertex **v)
{
    tmAssert( (e==t->e[0])||(e==t->e[1])||(e==t->e[2]) );
    if      (e==t->e[0]) { *e0=t->e[1]; *e1=t->e[2]; *v=t->v[2]; }
    else if (e==t->e[1]) { *e0=t->e[2]; *e1=t->e[0]; *v=t->v[0]; }
    else if (e==t->e[2]) { *e0=t->e[0]; *e1=t->e[1]; *v=t->v[1]; }
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::IsOppositeVertex(tmVertex *v0, tmVertex *v1, tmVertex *v2)
{
    return (    ( (v1-Vertices) < inputVertexCount )
             && (  GetSegment(v0, v1) != NULL      )
             && (  GetSegment(v1, v2) != NULL      )  );
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::HasBoundingVertices(tmVertex *v0,tmVertex *v1,tmVertex *v2)
{
    return ( ((v0-Vertices) < 3) || ((v1-Vertices) < 3) ||
             ((v2-Vertices) < 3) ) ;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::GetSplitPosition(tmVertex *v, tmVertex *v0, tmVertex *v1)
{
    tmVertex *vt;
    float32 dx, dy, d, f;

    if ( (v1-Vertices) < inputVertexCount )
    {
        vt = v0; v0 = v1; v1 = vt;
    }

    if ( (v0-Vertices) < inputVertexCount )
    {
        dx = v1->x - v0->x;
        dy = v1->y - v0->y;
        d  = sqrt(dx*dx + dy*dy);
        // 1) p41
        f  = pow(2.0f, floor(tmC_SQRT2 * log(0.5f*d) + 0.5f) )/d;
        v->x   = v0->x + f*dx;
        v->y   = v0->y + f*dy;
    }
    else
    {
        v->x = 0.5f*(v0->x + v1->x);
        v->y = 0.5f*(v0->y + v1->y);
    }
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::SameVertex(tmVertex* v0, tmVertex* v1)
{
  //if ( v0==NULL || v1==NULL ) return(false);
  return (    tmAbs(v0->x - v1->x) < tmC_ZEROTOL
           && tmAbs(v0->y - v1->y) < tmC_ZEROTOL ) ;
}

/*----------------------------------------------------------------------------*/
bool TriangleMesh::SplitSegment(tmSegment *s)
{
    tmEdge *e;
    tmVertex *v0, *v1, *v;
    tmSegment *t;
    e = GetEdge( s->v[0], s->v[1]);
    tmAssert(e!=NULL);

    v0 = s->v[0];   v1 = s->v[1];

    if ( SameVertex(v0,v1) )  return(false);

    v = AddVertex();
    if ( v==NULL ) return false;

    t = AddSegment();
    SetSegment(s, v0, v);
    SetSegment(t, v,  v1);

    GetSplitPosition( v, v0, v1);
    InsertVertexAt( v, e);

    return(true);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::ConvexHull()
{
    tmSegment *s;
    int32 i0,i1,i2;
    for (int32 i=0; i<triangleCount; i++ )
    {
     // Check all combinations
     i0 = 0; i1 = 1; i2 = 2;
     if (   ( (Triangles[i].v[i0] - Vertices)>=3 )
         && ( (Triangles[i].v[i1] - Vertices)>=3 )
         && ( (Triangles[i].v[i2] - Vertices)< 3 )
         &&   ( GetSegment( Triangles[i].v[i0], Triangles[i].v[i1])==NULL )   )
     {
        s = AddSegment();
        SetSegment(s, Triangles[i].v[i0] , Triangles[i].v[i1]);
     }
     i0 = 1; i1 = 2; i2 = 0;
     if (   ( (Triangles[i].v[i0] - Vertices)>=3 )
         && ( (Triangles[i].v[i1] - Vertices)>=3 )
         && ( (Triangles[i].v[i2] - Vertices)< 3 )
         &&   ( GetSegment( Triangles[i].v[i0], Triangles[i].v[i1])==NULL )   )
     {
        s = AddSegment();
        SetSegment(s, Triangles[i].v[i0] , Triangles[i].v[i1]);
     }
     i0 = 2; i1 = 0; i2 = 1;
     if (   ( (Triangles[i].v[i0] - Vertices)>=3 )
         && ( (Triangles[i].v[i1] - Vertices)>=3 )
         && ( (Triangles[i].v[i2] - Vertices)< 3 )
         &&   ( GetSegment( Triangles[i].v[i0], Triangles[i].v[i1])==NULL )   )
     {
        s = AddSegment();
        SetSegment(s, Triangles[i].v[i0] , Triangles[i].v[i1] );
     }
    }
}

/*----------------------------------------------------------------------------
 *  Miscellaneous
 */

/*----------------------------------------------------------------------------*/
void *TriangleMesh::Alloc(size_t size)
{
    void *p;
    tmAssert(size>0);
    p = malloc(size);
    tmAssert(p!=NULL);
    return(p);
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::Reset()
{
    Vertices         = NULL;
    Edges            = NULL;
    Triangles        = NULL;
    Segments         = NULL;

    vertexCount      = 0;
    inputVertexCount = 0;
    edgeCount        = 0;
    triangleCount    = 0;
    segmentCount     = 0;
    holeCount        = 0;
    insideTriangleCount = 0;
}

/*----------------------------------------------------------------------------*/
void TriangleMesh::CheckNumber(float32 x)
{
    int32 c;
#if defined(_MSC_VER) || defined(__BORLANDC__)
    c =  _finite(x);
#else
    c =   finite(x);
#endif
    tmAssert(c!=0);
}

/*----------------------------------------------------------------------------*/
float32 TriangleMesh::ArcTan2(float32 x, float32 y)
{
    float32 a;
    CheckNumber(x);
    CheckNumber(y);
    a = (float32)atan2( (double)x, (double)y);
// TEST:  if ( tmAbs(a)<tmC_ZEROTOL )
//           fprintf( stderr, "angle: %G\n",(float)a );
    return( a ) ;
}

/*----------------------------------------------------------------------------*/
float32 TriangleMesh::GetAngle(float32 a1, float32 a0)
{
    float32 d = a1 - a0;
    CheckNumber(a0);
    CheckNumber(a1);
    while ( d >   tmC_PI )   d -= tmC_PIx2;
    while ( d <= -tmC_PI )   d += tmC_PIx2;
    return d;
}

/*----------------------------------------------------------------------------*/
#if defined( TRIANGLEMESH_TEST )

#include <time.h>
/* a test main program
 *
 */
int32 main( int32 argc, char *argv[] )
{
  int32 rtn;
 /* the geometry-boundary to mesh, points in length units.
  * a ring
  */
  tmVertex nodes[] = {
              { 5.00f,    0.00f}, //  1 outer boundary
              { 3.54f,    3.54f}, //  2
              { 0.00f,    5.00f}, //  3
              {-3.54f,    3.54f}, //  4
              {-5.00f,    0.00f}, //  5
              {-3.54f,   -3.54f}, //  6
              { 0.00f,   -5.00f}, //  7
              { 3.54f,   -3.54f}, //  8

              { 2.00f,    0.00f}, //  9 inner boundary
              { 1.41f,    1.41f}, // 10
              { 0.00f,    2.00f}, // 11
              {-1.41f,    1.41f}, // 12
              {-2.00f,    0.00f}, // 13
              {-1.41f,   -1.41f}, // 14
              { 0.00f,   -2.00f}, // 15
              { 1.41f,   -1.41f}  // 16
  };
  tmVertex holes[] =  {
              { 0.0f, 0.0f }
  };
  tmSegmentId segs[] = {
              { 9 , 10 },  // point indices (see nodes[]) starting at 1
              { 10, 11 },
              { 11, 12 },
              { 12, 13 },
              { 13, 14 },
              { 14, 15 },
              { 15, 16 },
              { 16,  9 }
  };
  // instead of nodes indices
  tmVertex segXY[] = {
            { 2.00f,    0.00f}, //  inner boundary
            { 1.41f,    1.41f},
            { 0.00f,    2.00f},
            {-1.41f,    1.41f},
            {-2.00f,    0.00f},
            {-1.41f,   -1.41f},
            { 0.00f,   -2.00f},
            { 1.41f,   -1.41f}
  };

  TriangleMesh md;

  // 1. possibility
  rtn = md.Mesh( nodes, sizeof(nodes)/sizeof(tmVertex),
                 segs,  sizeof(segs)/sizeof(tmSegmentId),
                 holes, sizeof(holes)/sizeof(tmVertex)    );
  tmVertex vc = md.PolygonCenter(nodes, 16, 8);
  fprintf(stdout, " PolygonCenter: [%G %G]\n", (float)vc.x,(float)vc.y ) ;
  fprintf(stdout, " %s [%d]\n",md.GetErrorMessage(rtn),rtn ) ;

  md.PrintData();
  md.FreeMemory();

  // 2. possibility
  rtn = md.Mesh( nodes, 8,
                segXY,  sizeof(segXY)/sizeof(tmVertex),
                holes, sizeof(holes)/sizeof(tmVertex)    );
  fprintf(stdout, " %s [%d]\n",md.GetErrorMessage(rtn),rtn ) ;
  md.PrintData();
  md.FreeMemory();

  return(0) ;
}

#endif  // TRIANGLEMESH_TEST

