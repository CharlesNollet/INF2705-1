#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform mat4 matrProj;
uniform int pointSize;
uniform int texnumero;

in Attribs {
	vec4 couleur;
	float tempsRestant;
	float sens; // du vol
} AttribsIn[];

out Attribs {
	vec4 couleur;
	vec2 texCoord;
} AttribsOut;

void main(void) {
	vec2 coins[4];
	coins[0] = vec2(-0.5,  0.5);
	coins[1] = vec2(-0.5, -0.5);
	coins[2] = vec2( 0.5,  0.5);
	coins[3] = vec2( 0.5, -0.5);
	mat2 matrRotation = mat2(1.0, 0.0,
	                         0.0, 1.0);
	mat2 matrSym = mat2(1.0, 0.0,
	                    0.0, 1.0);

	if(AttribsIn[0].sens < 0.0) {
		matrSym = mat2(-1.0, 0.0,
		                0.0, 1.0);
	}

	if(texnumero == 1) {
		float theta = 6.0*AttribsIn[0].tempsRestant ;
		matrRotation = mat2(cos(theta), -sin(theta),
		                    sin(theta), cos(theta));
	}

	for(int i = 0 ; i < 4 ; ++i) {
		float fact = 0.01 * pointSize;
		// on positionne successivement aux quatre coins
		vec2 decalage = matrRotation * matrSym * (fact * coins[i]);
		vec4 pos = vec4(gl_in[0].gl_Position.xy + decalage, gl_in[0].gl_Position.zw);

		// on termine la transformation débutée dans le nuanceur de sommets
		gl_Position = matrProj * pos;
		AttribsOut.couleur = AttribsIn[0].couleur;

		// on utilise coins[] pour définir des coordonnées de texture
		AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 );

		switch(texnumero) {
			case 2:
			case 3:
				AttribsOut.texCoord.x /= 16.0;
				AttribsOut.texCoord.x += floor(mod(16.0*AttribsIn[0].tempsRestant, 16.0)) / 16.0;
				break;
			default:
				break;
		}
		EmitVertex();
	}
}
