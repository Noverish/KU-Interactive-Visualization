#include "XWindow.h"

Display                 *dpy;
Window                  root, win;
GLint                   att[] = { GLX_RGBA, GLX_DEPTH_SIZE, 24, GLX_DOUBLEBUFFER, None };
XVisualInfo             *vi;
Colormap                cmap;
XSetWindowAttributes    swa;
GLXContext              glc;
XWindowAttributes       gwa;
XEvent					xev;

void display() {
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	
	glutSolidTeapot(0.5);

	glXSwapBuffers(dpy, win);
} 

void ExitProgram() {
	glXMakeCurrent(dpy, None, NULL);
	glXDestroyContext(dpy, glc);
	XDestroyWindow(dpy, win);
	XCloseDisplay(dpy);
	exit(0);
}

int main(int argc, char *argv[]) {
	
	
	dpy = XOpenDisplay(NULL);
	if(dpy == NULL) {
        printf("\n\tcannot connect to X server\n\n");
        exit(0);
	}       
	root = DefaultRootWindow(dpy);

	vi = glXChooseVisual(dpy, 0, att);
	if(vi == NULL) {
        printf("\n\tno appropriate visual found\n\n");
        exit(0);
	} 
	else {
        printf("\n\tvisual %p selected\n", (void *)vi->visualid); /* %p creates hexadecimal output like in glxinfo */
	}

	glutInit(&argc, argv);

	cmap = XCreateColormap(dpy, root, vi->visual, AllocNone);
	swa.colormap = cmap;
	win = XCreateWindow(dpy, root, 0, 0, 600, 600, 0, vi->depth, InputOutput, vi->visual, CWColormap | CWEventMask, &swa);
	XMapWindow(dpy, win);
	XStoreName(dpy, win, "2015410012 KIM HYUN SUB");
	glc = glXCreateContext(dpy, vi, NULL, GL_TRUE);
	glXMakeCurrent(dpy, win, glc);
	glEnable(GL_DEPTH_TEST); 
 
 
	while(1) {
       display();
	} 
} 

// g++ [fileName] -lGL -lglut -lX11 -o [outName]
