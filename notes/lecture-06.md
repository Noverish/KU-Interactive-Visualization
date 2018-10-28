
# lecture 06

# I. Scene Graph

## 1. Node
```C++
class Node {
    virtual void glRender() = 0;
}
```

## 2. Group
```C++
class Group: public Node {
    void glRender();
    void addChild(Node * n);
    vector<Node*> children;

    float trans[3];
    float angle, axis[3];
    float scale[3];
}

void Group::glRender() {
    glPushMatrix();
    glPushAttrib(...);
    glTranslate(Trans);
    glRotate(anlge, axis);
    glScale(scale);

    for each child i
        children[i]->glRedner();

    glPopAttrib(...);
    glPopMatrix();
}
```

## 3. Camera
```C++
class Camera: public Node {
    void glRedner();

    float position[3];
    float lookat[3], up[3];
    float viewAngle;
    float zNear, zFar;
}

void Camera::glRender() {
    int w = getViewPortWidth();
    int h = getViewPortHeight();
    glMatrixMode(GL_PROJECTION);
    glLOADIdentity();
    gluPerspective(...);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(...);
}
```

### Retrieving Current Viewport State
```C++
GLint viewport[4];
glGetIntergerv(GL_VIEWPORT, viewport); viewport[0]; // x
viewport[1]; // y
viewport[2]; // width
viewport[3]; // height

float aspectRatio = viewport[2]/float(viewport[3]);
```

### Modified Resize Callback Function
```C++
void resize(GLint w, GLint h) {
    glViewport(0,0,w,h);
    // no matrix manipulation in here
}
```

## 4. Light
```C++
class Light: public Node {
    void glRedner();

    float ambient[4];
    float diffuse[4];
    float specular[4];
    float position[4];
}

void Light::glRender() {
    glLight(GL_LIGHT0, GL_AMBIENT, ambient);
    glLight(GL_LIGHT0, GL_DIFFUSE, ambient);
    glLight(GL_LIGHT0, GL_SPECULAR, ambient);
    glLight(GL_LIGHT0, GL_POSITION, position);
}
```

## 5. Shader
```C++
class Shader: public Node {
    void glRedner();

    float ambient[4];
    float diffuse[4];
    float specular[4];
    float shininess;
}
```

## 6. Texture
```C++
class Texture: public Node {
    void glRedner();

    GLuint texID;
}

void Texture::glRender() {
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texID);
}
```

## 7. Triangles
```C++
class Triangles: public Node {
    void glRedner();

    size_t nTriangles;
    float* vertices;
    float* normals;
    float* texCoords;
}

void Triangles::glRender() {
    for each triangle i
    glTexCoords(texCoords[2*i], texCoords[2*i+1]);
    glNormal(vertices[3*i], vertices[3*i+1], vertices[3*i+2]);
    glVertex(vertices[3*i], vertices[3*i+1], vertices[3*i+2]);
}
```
# II. Scene Graph
## init
```C++
Group root; int init(...) {
  Camera* camNode = new Camera(...);
  Light* lightNode = new Light(...);
  Triangles* triNode = new Triangles(...);
  root.addChild(camNode);
  root.addChild(lightNode);
  root.addChild(triNode);
}
```

## display
```C++
void display() {
    glClear(...);
    root.glRender();
    glFlush();
    glXSwapBuffers();
}
```