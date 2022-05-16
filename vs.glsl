#version 300 es
out vec3 glPosition;
in vec3 vPosition;

void main(void) {

    // gl_Position - специальная переменная вершинного шейдера,
    // которая отвечает за установку положения
    gl_Position = vec4(vPosition, 1.0);
    glPosition = vPosition;
}