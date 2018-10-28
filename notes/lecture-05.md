
# lecture 05

# I. Transformations

## 1. Homogeneous Coordinates
- x, y, z, w가 3D의 한 점을 나타냄
- x, y, z, 0은 벡터를 나타냄
- 4x4 행렬을 이용하여 homogeneous vector를 변형

## 2. Modelview & Projection matrix
- Modelview Matrix
  - 물체와 카메라간의 변환
- Projection Matrix
  - Clipping volume (viewing frustum)
  - Projection to screen

# II. Modeling Transformation (Object movement)

## 1. Translation : glTranslatef(x, y, z)
```C
// moving a cube from (0,0,0) to (5,5,5)
glTranslatef(5.0, 5.0, 5.0);
renderCube();
```

## 2. Rotation : glRotatef(angle, axis_x, axis_y, axis_z)
```C
glRotatef(90.0f, 1.0f, 1.0f, 1.0f); // around axis (1, 1, 1)
```

## 3. Scaling : glScalef (sx, sy, sz)
```C
glScalef(2.0f, 1.0f, 1.0f); // doubling only along x direction
```

## 4. The Order of Transformation
- 행렬이 오른쪽에 곱해진다.
```C++
glMatrixMode(GL_MODELVIEW);
glLoadIdentity(); // C = I
glMultMatrixf(N); // C = N
glMultMatrixf(M); // C = NM
glVertex3f(v);     // NMv
```

## 5. Example

```C
void display() {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT); glClearColor(1.0, 1.0, 1.0, 0.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1.0, 1.0, -1.0,1.0, 0.1, 50.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(0.5, 0.0, -2.0);
    glRotatef(45.0, 1.0, 1.0, 1.0);
    glScalef(0.5, 1.2, 0.5);
    glColor3f(0.0,0.0,0.0);
    glutWireCube(1.0f );
    glXSwapBuffers(dpy, win);
}
```

- glMatrixMode(GL_PROJECTION) : tells that we modify the projection matrix.
- glMatrixMode(GL_MODELVIEW) : tells that we modify the modelview matrix.
- glLoadIdentity() : replaces the current matrix with the identity matrix.
- glOrtho(l,r,b,t,zn,zf) : sets the clipping space orthographically. This changes. the projection matrix.
- glClear(...) : clears video buffers.
- glViewport(x,y,w,h) : sets the screen space.
- glTranslatef(), glRotatef(), and glScalef() : change the modelview matrix.

## 6. Matrix Stack
- Transformation matrix의 현재 상태 저장
- 다른 Transformation 수행
- 저장된 Transformation matrix를 불러옴
- 가장 위의 행렬 : 현재 사용중인 Transformation matrix
- glPushMatrix() : Push by duplicating the current top matrix
- glPopMatrix() : Pop out the top matrix, the second top matrix

# III. Viewing Transformation (Camera movement)
- gluLookAt(eyex,eyey,eyez, atx,aty,atz, upx,upy,upz)
- gluLookAt(0,0,2, 0,0,0, 0,1,0) = glTranslatef(0,0,-2)

# IV. Projection Transformation
- Projection matrix can be defined by giving
  - Projection type (orthographic or perspective)
  - Frustum (clipping volume)

## 1. Orthographic Projection
- `glOrtho(left, right, bottom, top, near, far)`    
![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/lecture05-001.png)

- `gluOrtho2D(left, right, bottom, top)`    
![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/lecture05-002.png)

## 2. Perspective Projection
- `gluPerpective(field of view, aspect(=w/h), near, far)`    
![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/lecture05-003.png)

- `glFrustumleft, right, bottom, top, near, far)`    
![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/lecture05-004.png)

# V. Referencing & Applying the Matrix
- `glGetFloatv(GL_MODELVIEW_MATRIX, mat)`
- `glGetFloatv(GL_PROJECTION_MATRIX, mat)`
- `glMultMatrixf(mat)`
  - Multiply the current matrix with the specified matrix.

# VI. Viewport Transformation
- glViewport(x,y,w,h)