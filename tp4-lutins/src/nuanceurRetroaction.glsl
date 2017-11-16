#version 410

uniform vec3 bDim, positionPuits;
uniform float temps, dt, tempsMax, gravite;

in vec3 position;
in vec3 vitesse;
in vec4 couleur;
in float tempsRestant;

out vec3 positionMod;
out vec3 vitesseMod;
out vec4 couleurMod;
out float tempsRestantMod;

// entre  0 et UINT_MAX
uint randhash(uint seed) {
    uint i=(seed^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u);
    i *= 2654435769u;
    i += (i<<5u)^(i>>12u);
    return i;
}

// entre  0 et 1
float myrandom(uint seed) {
    const float UINT_MAX = 4294967295.0;
    return float(randhash(seed)) / UINT_MAX;
}

void main( void ) {
    if (tempsRestant <= 0.0)
    {
        // se préparer à produire une valeur un peu aléatoire
        uint seed = uint(temps * 1000.0) + uint(gl_VertexID);
        // faire renaitre la particule au puits
        positionMod = positionPuits; 
        vitesseMod = vec3( myrandom(seed++)-0.5,       // entre -0.5 et 0.5
                myrandom(seed++)-0.5,       // entre -0.5 et 0.5
                myrandom(seed++)*0.5+0.5 ); // entre  0.5 et 1
        //vitesseMod = vec3( -0.8, 0., 0.6 );
        const float COULMIN = 0.2; // valeur minimale d'une composante de couleur lorsque la particule (re)naît
        const float COULMAX = 0.9; // valeur maximale d'une composante de couleur lorsque la particule (re)naît

        // nouveau temps de vie
        tempsRestantMod = myrandom(seed++) * tempsMax; // entre 0 et tempsMax secondes

        // interpolation linéaire entre COULMIN et COULMAX
        couleurMod = vec4(
				COULMIN + (COULMAX - COULMIN) * myrandom(seed++),
				COULMIN + (COULMAX - COULMIN) * myrandom(seed++),
				COULMIN + (COULMAX - COULMIN) * myrandom(seed++),
				1);
    }
    else
    {
        // avancer la particule
        positionMod = position;
        vitesseMod = vitesse;

        // diminuer son temps de vie
        tempsRestantMod = tempsRestant - dt;

        // garder la couleur courante
        couleurMod = couleur;

        // collision avec la demi-sphère ?
        vec3 descaledPos = vec3(
				position.x / bDim.x,
				position.y / bDim.y,
				position.z / bDim.z);
        if(length(descaledPos)>=1)
        {
            vitesseMod = reflect(vitesseMod, -normalize(position));
            couleurMod.a *= 0.5;
        }
        // collision avec le sol ?
        if(position.z<0)
        {
            vitesseMod.z *= -1;
        }

        // appliquer la gravité
        vitesseMod += vec3(0,0,-dt * gravite);

        positionMod += vitesseMod * dt;
    }
}
