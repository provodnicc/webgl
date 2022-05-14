attribute vec4 a_position;
varying vec4 glPosition;

void main() {

    // gl_Position - специальная переменная вершинного шейдера,
    // которая отвечает за установку положения
    gl_Position = a_position;
    glPosition = gl_Position;
}