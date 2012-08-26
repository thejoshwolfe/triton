
#ifdef WIN32
 //remove MFC overhead from windows.h witch can cause slowness
 #define WIN32_LEAN_AND_MEAN
 #define WIN32_EXTRA_LEAN

 #include <windows.h>
#endif


#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glu.h>

float x, y;

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glColor3ub(0xff, 0xb6, 0xc1);
    glRectf(x - 0.1f, y + 0.1f, x + 0.1f, y - 0.1f);

    glutSwapBuffers();
}

int main(int argc, char *argv[]) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH | GLUT_DOUBLE);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Hello World");
    glutDisplayFunc(display);

    glClearColor(0, 0, 0, 0);

    x = 0;
    y = 0;
    glutMainLoop();
    return 0;
}
