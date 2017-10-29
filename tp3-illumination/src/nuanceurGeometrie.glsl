#version 410

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

layout (std140) uniform varsUnif
{
	// partie 1: illumination
	int typeIllumination;     // 0:Lambert, 1:Gouraud, 2:Phong
	bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
	bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
	bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
	// partie 3: texture
	int texnumero;            // numéro de la texture appliquée
	bool utiliseCouleur;      // doit-on utiliser la couleur de base de l'objet en plus de celle de la texture?
	int afficheTexelNoir;     // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
};

in Attribs {
	vec4 couleur;
	vec3 normal;
	vec3 lightDirection;
	vec3 obsDirection;
	vec4 gouraudIntensity;
	vec2 texCoord;
} AttribsIn[];

out Attribs {
	vec4 couleur;
	vec3 normal;
	vec3 lightDirection;
	vec3 obsDirection;
	vec3 faceNormal;
	vec3 faceObsDirection;
	vec4 gouraudIntensity;
	vec2 texCoord;
} AttribsOut;

void main()
{
	vec3 sumNormal = vec3(0.0), sumObsDirection = vec3(0.0);

	vec3 v1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position),
	     v2 = vec3(gl_in[2].gl_Position - gl_in[0].gl_Position),
	     normal = normalize(cross(v1, v2));

	for(int i = 0; i < gl_in.length(); ++i) {
		sumObsDirection += AttribsIn[i].obsDirection;
	}
	 vec3 meanObsDirection = sumObsDirection / gl_in.length();

	// émettre les sommets
	for ( int i = 0 ; i < gl_in.length() ; ++i )
	{
		gl_Position = matrProj * gl_in[i].gl_Position;

		AttribsOut.couleur = AttribsIn[i].couleur;
		AttribsOut.normal = AttribsIn[i].normal;
		AttribsOut.obsDirection = AttribsIn[i].obsDirection;

		AttribsOut.lightDirection = AttribsIn[i].lightDirection;
		AttribsOut.gouraudIntensity = AttribsIn[i].gouraudIntensity;

		AttribsOut.faceNormal = normal;
		AttribsOut.faceObsDirection = meanObsDirection;

		AttribsOut.texCoord = AttribsIn[i].texCoord;

		EmitVertex();
	}
}
