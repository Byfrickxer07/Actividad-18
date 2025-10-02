import processing.event.MouseEvent; // 👈 Necesario para mouseWheel()

// Profundidad máxima de la recursividad
int depth = 5;

// Altura del triángulo
float triangleHeight;

// Puntos de los vértices del triángulo principal
PVector p1, p2, p3;

// Variables para animación
float rotationAngle = 0; // 👈 cambié el nombre
float rotationSpeed = 0.01;
boolean animating = true;

// Variables para colores
int colorMode = 0; // 0: arcoíris, 1: gradiente, 2: monocromático
float saturation = 80;
float hueOffset = 0;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100, 100);
  
  triangleHeight = sqrt(3) / 2 * width * 0.8;
  p1 = new PVector(width / 2, height * 0.1);
  p2 = new PVector(width * 0.1, height * 0.1 + triangleHeight);
  p3 = new PVector(width * 0.9, height * 0.1 + triangleHeight);
}

void draw() {
  background(240, 10, 98);
  
  // Aplicar rotación si está animando
  pushMatrix();
  translate(width / 2, height / 2);
  if (animating) {
    rotationAngle += rotationSpeed;
    hueOffset += 0.5; // Animación de colores
  }
  rotate(rotationAngle);
  translate(-width / 2, -height / 2);
  
  // Dibujar el fractal
  noStroke();
  drawTriangle(depth, p1, p2, p3, 0);
  
  popMatrix();
  
  // Mostrar información en pantalla
  displayInfo();
}

void drawTriangle(int d, PVector v1, PVector v2, PVector v3, int level) {
  if (d == 0) {
    // Calcular color según el modo seleccionado
    float hue, brightness;
    
    switch(colorMode) {
      case 0: // Arcoíris animado
        hue = (level * 40 + hueOffset) % 360;
        brightness = 85;
        break;
      case 1: // Gradiente por profundidad
        hue = map((float)level, 0, (float)depth, 200, 320);
        brightness = map((float)level, 0, (float)depth, 60, 90);
        break;
      case 2: // Monocromático
        hue = 280;
        brightness = map((float)level, 0, (float)depth, 40, 95);
        break;
      default:
        hue = 0;
        brightness = 50;
    }
    
    fill(hue, saturation, brightness, 90);
    triangle(v1.x, v1.y, v2.x, v2.y, v3.x, v3.y);
    
  } else {
    // Calcular puntos medios
    PVector mid1 = new PVector((v1.x + v2.x) / 2, (v1.y + v2.y) / 2);
    PVector mid2 = new PVector((v2.x + v3.x) / 2, (v2.y + v3.y) / 2);
    PVector mid3 = new PVector((v1.x + v3.x) / 2, (v1.y + v3.y) / 2);
    
    // Recursión en los tres subtriángulos
    drawTriangle(d - 1, v1, mid1, mid3, level + 1);
    drawTriangle(d - 1, mid1, v2, mid2, level + 1);
    drawTriangle(d - 1, mid3, mid2, v3, level + 1);
  }
}

void displayInfo() {
  // Panel de información
  fill(0, 0, 0, 70);
  noStroke();
  rect(10, 10, 300, 140, 10);
  
  fill(0, 0, 100);
  textAlign(LEFT);
  textSize(14);
  text("TRIANGULO DE SIERPINSKI", 20, 30); // 👈 saqué el emoji
  text("Profundidad: " + depth, 20, 55);
  text("Modo Color: " + getModeText(), 20, 75);
  text("Estado: " + (animating ? "Animando" : "Pausado"), 20, 95);
  
  textSize(11);
  text("↑/↓: Cambiar profundidad", 20, 120);
  text("ESPACIO: Pausar | C: Cambiar color | R: Reset", 20, 135);
}

String getModeText() {
  switch(colorMode) {
    case 0: return "Arcoíris";
    case 1: return "Gradiente";
    case 2: return "Monocromático";
    default: return "Desconocido";
  }
}

void keyPressed() {
  // Control de profundidad con flechas
  if (keyCode == UP) {
    depth = min(depth + 1, 8);
  } else if (keyCode == DOWN) {
    depth = max(depth - 1, 0);
  }
  
  // Pausar/reanudar animación
  if (key == ' ') {
    animating = !animating;
  }
  
  // Cambiar modo de color
  if (key == 'c' || key == 'C') {
    colorMode = (colorMode + 1) % 3;
  }
  
  // Reiniciar
  if (key == 'r' || key == 'R') {
    rotationAngle = 0;
    depth = 5;
    rotationSpeed = 0.01;
    saturation = 80;
    colorMode = 0;
    hueOffset = 0;
  }
  
  // Control de velocidad de rotación
  if (key == '+' || key == '=') {
    rotationSpeed = min(rotationSpeed + 0.005, 0.1);
  } else if (key == '-' || key == '_') {
    rotationSpeed = max(rotationSpeed - 0.005, 0);
  }
  
  // Control de saturación
  if (key == 's' || key == 'S') {
    saturation = (saturation + 20) % 100;
  }
}

void mouseWheel(MouseEvent event) {
  // Control de profundidad con rueda del mouse
  float e = event.getCount();
  if (e > 0) {
    depth = max(depth - 1, 0);
  } else {
    depth = min(depth + 1, 8);
  }
}
