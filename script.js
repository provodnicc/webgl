var gl; // глобальная переменная для контекста WebGL
var program
var canvas
var rl = 0.0, fb = -4.0, ud = 0.0
var x = 1, y = 0
function test(e){
  if((e.key== "w")||(e.key== "W")||(e.key== "ц")||(e.key== "Ц")){
    fb += 0.1
  }else if((e.key == "s")||(e.key== "W")||(e.key== "ц")||(e.key== "Ц")){
    fb -= 0.1
  }else if((e.key == "a")||(e.key== "A")||(e.key== "ф")||(e.key== "Ф")){
    rl -= 0.1
  }else if((e.key == "d")||(e.key== "D")||(e.key== "в")||(e.key== "В")){
    rl += 0.1
  }else if((e.key == "q")||(e.key== "Q")||(e.key== "й")||(e.key== "Й")){
    ud += 0.1
  }else if((e.key == "e")||(e.key== "E")||(e.key== "у")||(e.key== "У")){
    ud -= 0.1
  }
  
  else if(e.key == "ArrowUp"){
    y += 0.1
  }else if(e.key == "ArrowDown"){
    y -= 0.1
  }else if(e.key == "ArrowLeft"){
    x -= 0.1
  }else if(e.key == "ArrowRight"){
    x += 0.1
  }
  console.log(e.key)
    start()
}

async function set_range(){
  input = document.getElementById("reflection_input")
  span = document.getElementById("reflection_value")
  span.textContent = input.value*100 + "%"
  await start()
}
    
async function start() {
    
    canvas = document.getElementById("glcanvas");
    gl = canvas.getContext("webgl2", {antialias:false});      // инициализация контекста GL
    program = await initShader()
    await draw()
    await initGl()
}
async function initGl(){
  gl.clearColor(0.2, 0.8, 0.5, 1.0);                      // установить в качестве цвета очистки буфера цвета чёрный, полная непрозрачность
  gl.enable(gl.DEPTH_TEST);                               // включает использование буфера глубины
  gl.depthFunc(gl.LEQUAL);                                // определяет работу буфера глубины: более ближние объекты перекрывают дальние
  gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);      // очистить буфер цвета и буфер глубины.
  gl.drawArrays(gl.POINTS, 4, 1)
  await draw()
}

async function draw(){

  var positionLocation = gl.getAttribLocation(program, "vPosition")
  var positionBuffer = gl.createBuffer()
  
  var reflectionLocation = gl.getUniformLocation(program, "reflection")  
  var rlLocation = gl.getUniformLocation(program, "rl")  
  var fbLocation = gl.getUniformLocation(program, "fb")   
  var udLocation = gl.getUniformLocation(program, "ud")   
  var xLocation = gl.getUniformLocation(program, "x")   
  var yLocation = gl.getUniformLocation(program, "y")   


  gl.uniform1f(reflectionLocation, Number(document.getElementById("reflection_input").value))
  gl.uniform1f(rlLocation, rl)
  gl.uniform1f(fbLocation, fb)
  gl.uniform1f(udLocation, ud)
  gl.uniform1f(xLocation,  x)
  gl.uniform1f(yLocation,  y)

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

async function getIMG(){
  img = new Image()
  img.src = url
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

async function getShader(id) {
  var shaderScript, shader;

  await fetch("http://localhost:5000/"+id
    ).then(k => k.json()).then( text =>{shaderScript = text})
  if (!shaderScript) {
    return null;
  }
  if (id == "frag"){
    shader = await createShader(gl, shaderScript, gl.FRAGMENT_SHADER);
  }else{
    shader = await createShader(gl, shaderScript, gl.VERTEX_SHADER);
  }
  // скомпилировать шейдерную программу
  gl.compileShader(shader);

  // Проверить успешное завершение компиляции
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      alert("An error occurred compiling the shaders: " + gl.getShaderInfoLog(shader));
      return null;
  }

  return shader;
}

async function createShader (gl, sourceCode, type) {
  // Compiles either a shader of type gl.VERTEX_SHADER or gl.FRAGMENT_SHADER
  var shader = gl.createShader( type );
  gl.shaderSource( shader, sourceCode );
  gl.compileShader( shader );

  if ( !gl.getShaderParameter(shader, gl.COMPILE_STATUS) ) {
    var info = gl.getShaderInfoLog( shader );
    throw 'Could not compile WebGL program. \n\n' + info;
  }
  return shader;
}

async function initShader(){
  var VS = await getShader('vert')
  var FS = await getShader('frag')
  var shaderProgram = gl.createProgram()

  gl.attachShader(shaderProgram, VS)
  gl.attachShader(shaderProgram, FS)
  gl.linkProgram(shaderProgram)
  gl.useProgram(shaderProgram)
  return shaderProgram
  
}