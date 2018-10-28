
# lecture 09

# I. Texture
- Texture Mapping : 그 물체가 가지고 있는 텍스쳐 바탕으로 각 픽셀의 색상을 결정하는 과정
## 1. Wrapping Mode
### Clamping
- if (s,t > 1) 1 else 0
- `glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);`
### Repeating
- Use s,t modulo 1
- `glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);`

## 2. Filter Mode
### Magnification
- More than one texel can cover a pixel
### Minification
- more than one pixel can cover a texel

## 3. Filter Modes: Texture_Parameters
### Point Sampling
`glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);`
### Linear Filtering
`glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);`

## 4. Mipmapping
```C++
init() {
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 32, 32, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage32);
    glTexImage2D(GL_TEXTURE_2D, 1, GL_RGBA, 16, 16, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage16);
    glTexImage2D(GL_TEXTURE_2D, 2, GL_RGBA, 8, 8, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage8);
    glTexImage2D(GL_TEXTURE_2D, 3, GL_RGBA, 4, 4, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage4);
    glTexImage2D(GL_TEXTURE_2D, 4, GL_RGBA, 2, 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage2);
    glTexImage2D(GL_TEXTURE_2D, 5, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, mipmapImage1);
}

display() {
    glBegin(GL_QUADS);
    glTexCoord2f(0,0);
    glVertex3f(-2,-1,0);
    glTexCoord2f(0,8);
    glVertex3f(-2, 1,0);
    glTexCoord2f(8,8);
    glVertex3f(2000, 1,-6000);
    glTexCoord2f(8,0);
    glVertex3f(2000,-1,-6000);
    glEnd();
    glFlush();
}
```

# II. Texture Practice
#### Application
```C++
void main(int argc, char *argv[]) {
    /*Create Window*/
    initGL();
    initLight();
    initTexture();
    while(1){
        display();
        /*Event Handle*/
    }
}

void initGL() {} // same as lecture 7

void createProgram() {} // same as lecture 7

void initLight() // same as lecture 8

void initTexture () {
    glActiveTexture(GL_TEXTURE0); //Activating Texture 0
    glGenTextures(1, &textureID); //Generating Texture
    glBindTexture(GL_TEXTURE_2D, textureID); //Binding Texture
    //Add texture to Back side
    Bitmap bmp = Bitmap::bitmapFromFile("textures/texture.jpg");
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, bmp.width(), bmp.height(),
                 0, GL_RGB, GL_UNSIGNED_BYTE, bmp.pixelBuffer());
    //Set Filter and Wrapping
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    //transfer Texture index to glsl
    glUniform1i(glGetUniformLocation(program, "tex"),0);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void display() {
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glUseProgram(program);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity();
    glBindTexture(GL_TEXTURE_2D, textureID);
    glOrtho (-1.0, 1.0, -1.0, 1.0, -10.0, 10.0);
    glMatrixMode(GL_MODELVIEW); glLoadIdentity();
    glRotatef(40.0, 1.0, -1.0, 1.0);
    glShadeModel(GL_SMOOTH);
    glutSolidTeapot(0.5f);
    glUseProgram(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glXSwapBuffers(dpy, win);
}
```

#### Vertex Shader
```GLSL
#version 130
varying vec3 normal, lightDir, halfVector;
void main() {
    normal = normalize(gl_NormalMatrix*gl_Normal);
    /* vertex normal to fragment shader */
    lightDir = normalize(gl_LightSource[0].position.xyz);
    /* Light Direction Vector to Fragment shader */
    halfVector = normalize(gl_LightSource[0].halfVector.xyz);
    /* half Vector to Fragment shader */
    gl_Position = gl_ModelViewProjectionMatrix*gl_Vertex;
    /* Projected Position to Fragment shader */
    gl_TexCoord[0] = gl_MultiTexCoord0;
    /* texture coordinate to Fragment Shader */
}
```

#### Fragment Shader
```GLSL
#version 130
varying vec3 normal, lightDir, halfVector;
uniform sampler2D tex; //set 2D Texture@Fragment Shader
void main() {
    vec3 n, h;
    float NdotL, NdotH;
    vec4 color = gl_FrontMaterial.ambient * gl_LightSource[0].ambient +
                 gl_FrontMaterial.ambient * gl_LightModel.ambient;
    n = normalize(normal);
    NdotL = max(dot(n,lightDir),0.0);
    if (NdotL > 0.0) {
        color += gl_FrontMaterial.diffuse * gl_LightSource[0].diffuse * NdotL;
        h = normalize(halfVector);
        NdotH = max(dot(n,h),0.0);
        color = color*texture2D(tex,gl_TexCoord[0].st); //load Texture Color and compute with Light
        color += gl_FrontMaterial.specular * gl_LightSource[0].specular *
                 pow(NdotH, gl_FrontMaterial.shininess);
    }
    gl_FragColor = color;
}
```

# III. Fog
#### Application
```C++
void initFog() {
    float fog_color[] = {1.0, 1.0, 1.0, 1.0};
    glEnable(GL_FOG); glFogfv(GL_FOG_COLOR, fog_color);
    glFogf(GL_FOG_START, 0.48f);
    glFogf(GL_FOG_END, 0.55f);
}
```

#### Vertex Shader
위의 Texture Vertex Shader에 아래의 코드를 추가
```GLSL
gl_ClipVertex = gl_ModelViewMatrix*gl_Vertex;
/* vertex position on Clipping Space to Fragment Shader */
```

#### Fragment Shader
```GLSL
#version 130
varying vec3 normal, lightDir, halfVector;
uniform sampler2D tex; //set 2D Texture@Fragment Shader
void main() {
    vec4 color;
    /* Compute Light */
    color = color*texture2D(tex,gl_TexCoord[0].st);
    float z = gl_FragCoord.z / gl_FragCoord.w; /*Compute depth*/
    float fogFactor = (gl_Fog.end - z) / (gl_Fog.end - gl_Fog.start); /*Compute fogfactor*/
    fogFactor = clamp(fogFactor, 0.0, 1.0);
    gl_FragColor = mix(gl_Fog.color, color, fogFactor); /*mix color with fog*/
    /* mix color with fog: gl_Fog.colr*(1-fogFactor)+color*fogFactor */
}
```

# IV. Normal Mapping
- Perturbs surface normal vectors
  - Normal Calculation : normal = (2*color)-1 // on each component
    - normal calculated from normal map in fragment shader
- TBN Transformation
  - Computing Tangent Bitangent at Shaders
- Color Calculation based on Lighting Model