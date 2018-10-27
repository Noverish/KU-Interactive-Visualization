
# lecture 04

# Drawing Primitives

```C++
glBegin(GL_TRIANGLES);
    glVertex3f(0.0f, 0.5f, 0.0f);
    ...
glEnd();
```

- Point
    - GL_POINTS
- Line
    - GL_LINES | GL_LINE_STRIP | GL_LINE_LOOP
- Polygon
    - GL_POLYGON
    - GL_TRIANGLES | GL_TRIANGLE_STRIP | GL_TRIANGLE_FAN
    - GL_QUADS | GL_QUAD_STRIP

`glColor3f(R, G, B);`

Point size

Line width

# Callback Functions
### void glutReshapeFunc(void(*func)(int width, int height))
- Called when the window size or shape is changed

### void glutIdleFunc(void(*func)(void))
- Called when there are no events to be processed

### void glutTimerFunc(unsigned int msecs, void (*func)(int value), value)
- Called in every msecs

### void glutKeyboardFunc(void(*func)(unsigned char key, int x, int y))
- Called when a key is pressed

### void glutMouseFunc(void(*func)(int button, int state, int x, int y))
- Called when a mouse button is pressed
  - button : GLUT_LEFT_BUTTON, GLUT_RIGHT_BUTTON, GLUT_MIDDLE_BUTTON
  - state : GLUT_DOWN, GLUT_UP
  - (x, y) : the coordinate of a mouse

### void glutMotionFunc(void(*func)(int x, int y))
- Called when a mouse is dragged

### void glutPassiveMotionFunc(void(*func)(int x, int y))
- Called when a mouse is moving without being pressed

# X Window Event handler

```C++
XSetWindowAttributes swa;
int main(int argc, char *argv[]) {
    /*Create Window Start */
    swa.event_mask = KeyPressMask | KeyReleaseMask;
    /*Create Window Cont.... */
    Xevent xev;
    while(1) { 
        display();
        XNextEvent(dpy, &xev);
        if(xev.type == KeyPress) { /*do something*/ }
        else if(xev.type == KeyRelease) { /*do something*/ }
        else if(xev.type == /*etc*/) { /*do something*/ }
    }
}
```

## Event Types

![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/image001.png)

## Event Masking

![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/image002.png)

## _XEvent union
- 모든 이벤트의 정보는 이 자료 구조를 통해 전달이 된다.

![](https://raw.githubusercontent.com/Noverish/KU-Interactive-Visualization/master/notes/images/image003.png)

## Window Event

### 1. XConfigureEvent
- Reported when window is moveed  or resized
- Contains [int x, y, width, height]
- Mask : StructureNotifyMask
- Type : ConfigureNotify

```C++
swa.event_mask = StructureNotifyMask;

XNextEvent(dpy, &xev);
if(xev.type == ConfigureNotify) {
    int x = xev.xconfigure.x;
    int y = xev.xconfigure.y;
    int width = xev.xconfigure.width;
    int height = xev.xconfigure.height;
}
```

### 2. XKeyEvent
- Reported when keyboard is pressed or released
- Contains [unsigned int keycode]
- Mask : KeyPressMask, KeyReleaseMask
- Type : KeyPress, KeyRelease

```C++
swa.event_mask = KeyPressMask | KeyReleaseMask;

XNextEvent(dpy, &xev);
if(xev.type == KeyPress) {
    char* s = XKeysymToString(XkbKeycodeToKeysym(dpy, xev.xkey.keycode, 0, 0));
} else if(xev.type == KeyRelease) {
    ...
}
```

- XkbKeycodeToKeysym의 첫번째 0 : Key Group, 두번째 0 : Shift Level(Pressed or not)

### 3. XButtonEvent
- Reported when mouse btn is pressed or released
- Contains [int x, y; unsigned int button]
- Mask : ButtonPressMask, ButtonReleaseMask
- Type : ButtonPress, ButtonRelease

```C++
swa.event_mask = ButtonPressMask | ButtonReleaseMask;

XNextEvent(dpy, &xev);
if(xev.type == ButtonPress) {
    int x = xev.xbutton.x;
    int y = xev.xbutton.y;
    unsigned int button = xev.xbutton.button;
} else if(xev.type == ButtonRelease) {
    ...
}
```

### 4. XMotionEvent
- Reported when mouse pointer is moved
- Contains [int x, y]
- Mask : PointerMotionMask
- Type : MotionNotify

```C++
swa.event_mask = PointerMotionMask;

XNextEvent(dpy, &xev);
if(xev.type == MotionNotify) {
    int x = xev.xmotion.x;
    int y = xev.xmotion.y;
}
```