
#ifdef WIN32
 //remove MFC overhead from windows.h witch can cause slowness
 #define WIN32_LEAN_AND_MEAN
 #define WIN32_EXTRA_LEAN

 #include <windows.h>
#endif


#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glu.h>

void display() { /* empty function   required as of glut 3.0 */ }

int main(int argc, char *argv[])
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH | GLUT_DOUBLE);
    glutInitWindowSize(800,600);
    glutCreateWindow("Hello World");
    glutDisplayFunc(display);
    glutMainLoop();
    return 0;
}
