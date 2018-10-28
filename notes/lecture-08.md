
# lecture 08

# Shading
- the process of altering the color of an object/surface/polygon in the 3D scene, based on its angle to lights and its distance from lights to create a photorealistic effect.
- Shading is performed during the rendering process by a program called a shader.
- OpenGL provides very basic shading models.
  - OpenGL is focused on real-time applications.

## 1. Flat Shading
- `glShadeModel(GL_FLAT);`
- Selects the computed color of just one vertex and assigns it to all the pixel fragments of the polygon
- 특징
  - Inexpensive to compute
  - Less pleasant for smooth surfaces
  - Not pleasant even for flat surfaces

## 2. Gouraud Shading
- `glShadeModel(GL_SMOOTH);`
- Calculate color at each vertex
- Interpolate the vertex color for the interior
- 특징
  - Better image
  - More expensive to calculate

### Process
- (1) One radiance calculation per vertex
- (2) Bilinearly interpolate colors at vertices

## 3. Phong Shading
- Not yet supported by OpenGL/DirectX
- Interpolate normals rather than colors
    - Can capture subtle illumination effects in polygon interiors

### Process
- (1) One radiance calculation per pixel
- (2) Bilinearly interpolate surface normals at vertices


# II. Example

## 1. [GL_FLAT Shading] and [GL_SMOOTH Shading wihtout GLSL]
```C++
void display() {
    /*initialize*/
    /*Set Shading Model*/
    glShadeModel(GL_FLAT or GL_SMOOTH);
    glutSolidSphere(0.5f,10,10);
    glXSwapBuffers(dpy, win);
}
```

## 2. GL_SMOOTH Shading with GLSL
```C++
GLuint program, vertShader, fragShader = 0;

void main(int argc, char *argv[]) {
    /*Create Window*/
    initGL();
    initLight();
    while(1){
        display();
        /*Event Handle*/
    }
}

void initGL() {} // same as lecture 7

void createProgram() {} // same as lecture 7

void initLight() {
    /*Set Light and Material Properties with Array*/
    /*Set light properties*/
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightKa);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightKd);
    glLightfv(GL_LIGHT0, GL_SPECULAR, lightKs);
    glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
    /*Set material properties*/
    glMaterialfv(GL_FRONT, GL_AMBIENT, matKa);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, matKd);
    glMaterialfv(GL_FRONT, GL_SPECULAR, matKs);
    glMaterialfv(GL_FRONT, GL_SHININESS, &matShininess);
    /*Enable Light*/
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_DEPTH_TEST);
}

void display() {
    ...
    glUseProgram(program);
    glShadeMode(GL_SMOOTH);

    /*Draw Call*/

    glUseProgram(0);
    ...
}
```

## 3. Phong Shading
### (1) Without Strip
pass
### (2) Strip after light
pass
### (3) Strip before light
#### Fragment Shader
```GLSL
varying vec3 normal, lightDir, halfVector;
varying float x;
void main() {
    ...
    float stripe = sin(10.0*x);
    if (stripe < 0.0) stripe = 0.25;
    else stripe = 1.0;
    /*Compute Ambient*/
    /*Compute Diffuse*/
    color *= stripe;
    /*Compute Specular*/ gl_FragColor = color;
}
```

## 4. Stripped Teapot
#### Vertex Shader
```GLSL
#version 130
varying float x;
void main() {
    /*compute light per vertex*/
    x = gl_Vertex.x;
}
```
#### Fragment Shader
```GLSL
#version 130
varying float x;
void main() {
    float stripe = sin(10.0*x);
    if (stripe < 0.0) stripe = 0.25;
    else stripe = 1.0;
    gl_FragColor = stripe*gl_Color;
}
```

# Light Model @ Shader

#### Vertex Shader (공통)
```GLSL
gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
pos = gl_ModelViewMatrix * gl_Vertex;
normal = normalize(gl_NormalMatrix * gl_Normal);
lightDir 또는 lightPos = gl_LightSource[0].position.xyz;
```

## 1. Directional light
#### application
```C++
GLfloat light_position[] = {0.0, 0.0, 10.0, 1.0};
glLightfv(GL_LIGHT0, GL_POSITION, light_position);
```
#### Fragment Shader
```GLSL
vec3 L1 = normalize((lightDir).xyz);
float NdotL = max(dot(normalize(normal), L1), 0.0); 
loat intensity = NdotL;
color += vec3(intensity);
```

## 2. Point light
#### application
```C++
GLfloat light_position[] = {0.0, 0.0, 1.0, 0.0};
glLightfv(GL_LIGHT0, GL_POSITION, light_position);
```
#### Fragment Shader
```GLSL
vec3 L1 = normalize((pos - lightPos).xyz);
float NdotL = max(dot(normalize(normal), L1), 0.0); 
loat intensity = NdotL;
color += vec3(intensity);
```

## 3. Spot light
#### application
```C++
GLfloat sd[] = {0.0, 0.0, 1.0};
glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, sd);
glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 45.0);
glLightf(GL_LIGHT0, GL_SPOT_EXPONENT, 2.0);
```
#### Fragment Shader
```GLSL
vec3 L1=normalize((pos - lightPos).xyz);
float NdotL = max(dot(normalize(normal), L1), 0.0);
float cut = dot(-L1, gl_LightSource[0].spotDirection);
if(cut >= gl_LightSource[0].spotCosCutoff) {
    float intensity = NdotL;
    color += vec3(intensity * pow(cut, gl_LightSource[0].spotExponent));
}
```