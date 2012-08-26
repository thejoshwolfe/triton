
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glu.h>


#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>

#include <cstdlib>
#include <iostream>
#include <cstring>

template<typename T>
void _fail(T msg, int line_number) {
    std::cerr << "line " << line_number << ": " << msg << std::endl;
    std::exit(1);
}
#define fail(msg) _fail(msg, __LINE__)

float x, y;

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glColor3ub(0xff, 0xb6, 0xc1);
    glRectf(x - 0.1f, y + 0.1f, x + 0.1f, y - 0.1f);

    glutSwapBuffers();
}

void setup_socket() {
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (socket_fd < 0)
        fail(socket_fd);

    hostent *server = gethostbyname("localhost");
    if (server == NULL)
        fail("ERROR, no such host");

    sockaddr_in serv_addr;
    std::memset((void*)&serv_addr, 0, sizeof(sockaddr_in));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr, (char *)&serv_addr.sin_addr.s_addr, server->h_length);
    serv_addr.sin_port = htons(26874);
    if (connect(socket_fd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) 
        fail("ERROR connecting");

    std::cout << "connected to server:" << std::endl;

    char buffer[0x1000];
    int count = read(socket_fd, buffer, sizeof(buffer));
    std::cout << std::string(buffer, count) << std::endl;
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
    setup_socket();

    glutMainLoop();
    return 0;
}
