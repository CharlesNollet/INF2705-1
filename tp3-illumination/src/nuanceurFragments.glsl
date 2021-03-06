#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
	vec4 position;
	vec3 spotDirection;
	float spotExponent;
	float spotCutoff;            // ([0.0,90.0] ou 180.0)
	float constantAttenuation;
	float linearAttenuation;
	float quadraticAttenuation;
} LightSource[1];

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
	vec4 emission;
	vec4 ambient;
	vec4 diffuse;
	vec4 specular;
	float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
	vec4 ambient;       // couleur ambiante
	bool localViewer;   // observateur local ou à l'infini?
	bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

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

uniform sampler2D laTexture;

/////////////////////////////////////////////////////////////////

in Attribs {
	vec4 couleur;
	vec3 normal;
	vec3 lightDirection;
	vec3 obsDirection;
	vec3 faceNormal;
	vec3 faceObsDirection;
	vec4 gouraudIntensity;
	vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

float calculerSpot( in vec3 spotDir, in vec3 L )
{
	spotDir = normalize(spotDir);
	L = normalize(L);
	float cosGamma = dot(spotDir, -L),
	      innerCos = cos(LightSource[0].spotCutoff * 3.14159265/180.0);

	if(utiliseDirect) {
		// Spot Direct3D
		float outerCos = pow(innerCos, 1.01 + LightSource[0].spotExponent / 2);
		return smoothstep(outerCos, innerCos, cosGamma);
	} else {
		// Spot OpenGL
		if(cosGamma >= innerCos) {
			return pow(cosGamma, LightSource[0].spotExponent);
		}
	}
}

vec4 calculerIntensite(in vec3 lightDirection, in vec3 normal, in vec3 obsDirection) {
	vec4 ambient = FrontMaterial.emission +
		FrontMaterial.ambient * LightModel.ambient;

	ambient += FrontMaterial.ambient * LightSource[0].ambient;

	vec4 diffuse = FrontMaterial.diffuse *
		LightSource[0].diffuse *
		max(dot(lightDirection, normal), 0.0);

	float reflectionFactor;
	if(utiliseBlinn) {
		reflectionFactor = max(0.0, dot(normalize(lightDirection + obsDirection), normal));
	} else {
		reflectionFactor = max(0.0, dot(reflect(-lightDirection, normal), obsDirection));
	}

	vec4 specular = FrontMaterial.specular *
		LightSource[0].specular *
		pow(reflectionFactor, FrontMaterial.shininess);

	return clamp(ambient + diffuse + specular, 0.0, 1.0);
}

void main( void )
{
	vec3 normal;
	vec3 obsDirection;

	vec4 tex = texture(laTexture, AttribsIn.texCoord);

	if(typeIllumination == 0) {
		normal = normalize(AttribsIn.faceNormal);
		obsDirection = normalize(AttribsIn.faceObsDirection);
	} else {
		normal = normalize(AttribsIn.normal);
		obsDirection = normalize(AttribsIn.obsDirection);
	}

		if(typeIllumination == 1) {
			FragColor = AttribsIn.gouraudIntensity;
		} else {
			FragColor = calculerIntensite(normalize(AttribsIn.lightDirection), normal, obsDirection);
		}

	FragColor.a = 1;

	if(texnumero != 0) {

		float luma = (tex.r + tex.g + tex.b) / 3.0;

		if(afficheTexelNoir == 1) {

			FragColor *= (1 + tex) / 2;

		} else if(afficheTexelNoir == 2 && luma < 0.1) {
			discard;
		} else {
			FragColor *= tex;
		}

	}

	if(afficheNormales) {
		FragColor.rgb = 0.5 + 0.5 * normal;
	} else {
		FragColor.rgb *= calculerSpot(LightSource[0].spotDirection, AttribsIn.lightDirection);
	}
}
