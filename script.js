var gl; // глобальная переменная для контекста WebGL
var url = (`
https://sun9-52.userapi.com/impf/iM70UsbECdxTqxxAwS8HDDUstIwavW0s8oMoRQ/We26P54GzRs.jpg?size=0x0&quality=90&proxy=1&sign=91bfa1e9a9046ade9c764620cfdbb0d6&c_uniq_tag=gxtCjuEqjkPwC6BdlpcdN6OM156otVQo7dyCeU2Xvbo&type=video_thumb
`)

var program
var canvas
// var cubeVertices = [
//   -1, -1, -1,
//    1, -1, -1,
//    1,  1, -1,
//   -1,  1
// ]

function start() {

  // try{
    canvas = document.getElementById("glcanvas");
    gl = canvas.getContext("webgl", {antialias:false});      // инициализация контекста GL

    program = initShader()

    draw()
  
    // setAttr()

    initGl()
    // getIMG()

    // console.log("script already working")
  // }catch(e){
    // console.log("script does not started, because you monkey")
  // }

}

function setAttr(){
  let pos = gl.getAttribLocation(shaderProgram, 'pos')
  gl.vertexAttrib3f(pos, )
}

function load_shaders(){

}

function initGl(){
  gl.clearColor(0.2, 0.8, 0.5, 1.0);                      // установить в качестве цвета очистки буфера цвета чёрный, полная непрозрачность
  gl.enable(gl.DEPTH_TEST);                               // включает использование буфера глубины
  gl.depthFunc(gl.LEQUAL);                                // определяет работу буфера глубины: более ближние объекты перекрывают дальние
  gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);      // очистить буфер цвета и буфер глубины.
  gl.drawArrays(gl.POINTS, 4, 1)
  draw()
}

function draw(){
  console.log(program)

  var positionLocation = gl.getAttribLocation(program, "a_position")
  var texcoordLocation = gl.getAttribLocation(program, "a_texCoord")

  var positionBuffer = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  // три двумерных точки
  var positions = [
    -1, -1, 
    -1, 1,
    
    1, -1,

    1, 1,
    -1, 1,

    1, -1,
  ];

  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);
  
  
  gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);
  
  gl.enableVertexAttribArray(positionLocation);
  // Привязываем буфер положений
  // gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  
  // var texcoordBuffer = gl.createBuffer();

  // var texcoords = [
  //   0.0,  0.0,
  //   1.0,  0.0,
  //   0.0,  1.0,
  //   0.0,  1.0,
  //   1.0,  0.0,
  //   1.0,  1.0,
  // ]

  // gl.bindBuffer(gl.ARRAY_BUFFER, texcoordBuffer);
  // gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(texcoords), gl.STATIC_DRAW)





  // Указываем атрибуту, как получать данные от positionBuffer (ARRAY_BUFFER)
  var size = 2;          // 2 компоненты на итерацию
  var type = gl.FLOAT;   // наши данные - 32-битные числа с плавающей точкой
  var normalize = false; // не нормализовать данные
  var stride = 0;        // 0 = перемещаться на size * sizeof(type) каждую итерацию для получения следующего положения
  var offset = 0;        // начинать с начала буфера
  gl.vertexAttribPointer(
    positionLocation, size, type, normalize, stride, offset
  )

  var primitiveType = gl.TRIANGLES;
  var offset = 0;
  var count = positions.length/2;
  gl.drawArrays(primitiveType, offset, count);

}



function getIMG(){
  img = new Image()
  img.src = url
  console.log(img)
  img.webGLtexture = false
  img.crossOrigin = "anonymous"
  img.onload = (e) => {
    var texture = gl.createTexture()
    gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true)
    gl.bindTexture(gl.TEXTURE_2D, texture)
    gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        gl.RGBA,
        gl.RGBA,
        gl.UNSIGNED_BYTE,
        img
    )

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR)

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

    gl.generateMipmap(gl.TEXTURE_2D)
    gl.bindTexture(gl.TEXTURE_2D, null)

    img.webGLtexture = texture
  }
  return img
}

function getShader(id) {
  var shaderScript, theSource, currentChild, shader;

  shaderScript = document.getElementById(id);

  if (!shaderScript) {
    return null;
  }

  theSource = "";
  currentChild = shaderScript.firstChild;

  while(currentChild) {
    if (currentChild.nodeType == currentChild.TEXT_NODE) {
      theSource += currentChild.textContent;
    }

    currentChild = currentChild.nextSibling;
  }
  if (shaderScript.type == "x-shader/x-fragment") {
    shader = gl.createShader(gl.FRAGMENT_SHADER);
  } else if (shaderScript.type == "x-shader/x-vertex") {
    shader = gl.createShader(gl.VERTEX_SHADER);
  } else {
     // неизвестный тип шейдера
     return null;
  }
  gl.shaderSource(shader, theSource);

  // скомпилировать шейдерную программу
  gl.compileShader(shader);

  // Проверить успешное завершение компиляции
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      alert("An error occurred compiling the shaders: " + gl.getShaderInfoLog(shader));
      return null;
  }

  return shader;
}

function initShader(){

  var VS = getShader('shader-vs')
  var FS = getShader('shader-fs')
  var shaderProgram = gl.createProgram()

  gl.attachShader(shaderProgram, VS)
  gl.attachShader(shaderProgram, FS)
  gl.linkProgram(shaderProgram)
  gl.useProgram(shaderProgram)
  return shaderProgram
  
}