#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 matrProj;
uniform int pointSize;

in Attribs {
   vec4 couleur;
   float tempsRestant;
   //float sens; // du vol
} AttribsIn[];

out Attribs {
   vec4 couleur;
} AttribsOut;

void main()
{
   vec2 coins[4];
   coins[0] = vec2( -0.5,  0.5 );
   coins[1] = vec2( -0.5, -0.5 );
   coins[2] = vec2(  0.5,  0.5 );
   coins[3] = vec2(  0.5, -0.5 );
   for( int i = 0 ; i < 4 ; ++i )
  { 
      float fact = 0.01*pointSize;
      vec2 decalage = coins[i]; // on positionne successivement aux quatre coins
      vec4 pos = vec4( gl_in[0].gl_Position.xy + fact*decalage, gl_in[0].gl_Position.zw );

      gl_Position = matrProj * pos;    // on termine la transformation dÃ©butÃ©e dans le nuanceur de sommets
      AttribsOut.couleur = AttribsIn[0].couleur;
      //AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 ); // on utilise coins[] pour dÃ©finir des coordonnÃ©es de texture
      EmitVertex();
   } 
}
