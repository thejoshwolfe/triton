
#include <GL/gl.h>
#include <GL/glut.h>
#include <GL/glu.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>

#include <pthread.h>

#include <cstdlib>
#include <iostream>
#include <cstring>

template<typename T>
void _fail(T msg, int line_number) {
    std::cerr << "line " << line_number << ": " << msg << std::endl;
    std::exit(1);
}
#define fail(msg) _fail(msg, __LINE__)

float x, y, dx, dy;
float acceleration = 0.001;

int socket_fd;

void display() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glColor3ub(0xff, 0xb6, 0xc1);
    glRectf(x - 0.1f, y + 0.1f, x + 0.1f, y - 0.1f);

    glutSwapBuffers();
}

void* read_socket(void*_) {
    while (true) {
        char buffer[0x1000];
        int count = read(socket_fd, buffer, sizeof(buffer));
        if (count < 0)
            fail(count);
        if (count == 0)
            break;
        for (int i = 0; i < count; i++) {
            char c = buffer[i];
            std::cout << "accelerating: " << c << std::endl;
            switch (c) {
                case 'u':
                    dy += acceleration;
                    break;
                case 'd':
                    dy -= acceleration;
                    break;
                case 'l':
                    dx -= acceleration;
                    break;
                case 'r':
                    dx += acceleration;
                    break;
            }
        }
    }
    std::cout << "no more messages from the server" << std::endl;
}

void setup_socket() {
    socket_fd = socket(AF_INET, SOCK_STREAM, 0);
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

    pthread_t thread;
    int err = pthread_create(&thread, NULL, read_socket, NULL);
    if (err)
        fail(err);
}

const int update_interval = 1000 / 60;
void update(int _) {
    x += dx;
    y += dy;
    glutTimerFunc(update_interval, update, 0);
    glutPostRedisplay();
}

int main(int argc, char *argv[]) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_RGB | GLUT_DEPTH | GLUT_DOUBLE);
    glutInitWindowSize(800, 600);
    glutCreateWindow("Hello World");
    glClearColor(0, 0, 0, 0);

    glutDisplayFunc(display);
    glutTimerFunc(update_interval, update, 0);

    x = 0;
    y = 0;
    dx = 0;
    dy = 0;
    setup_socket();

    glutMainLoop();
    return 0;
}
