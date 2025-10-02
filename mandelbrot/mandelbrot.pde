import processing.event.MouseEvent; // 👈 Necesario para usar getCount()

// Límites del plano complejo
float minX = -2.5, maxX = 1.5;
float minY = -2, maxY = 2;

// Parámetros de iteración
int maxIterations = 100;

// Variables para zoom
float dragStartX, dragStartY;
boolean isDragging = false;

// Paleta de colores (0-5)
int colorPalette = 0;

// Modo explorador automático
boolean explorerMode = false;
float explorerTime = 0;

// Variables para navegación
ArrayList<float[]> zoomHistory;

void setup() {
  size(800, 800);
  colorMode(HSB, 360, 100, 100);
  noLoop();
  
  zoomHistory = new ArrayList<float[]>();
  saveZoomState();
  
  drawMandelbrot();
}

void draw() {
  // Modo explorador: animación automática
  if (explorerMode) {
    explorerTime += 0.01;
    
    float zoomFactor = 1 + sin(explorerTime) * 0.5;
    float centerX = -0.5 + cos(explorerTime * 0.3) * 0.5;
    float centerY = sin(explorerTime * 0.4) * 0.5;
    
    float w = 3 / zoomFactor;
    float h = 3 / zoomFactor;
    
    minX = centerX - w / 2;
    maxX = centerX + w / 2;
    minY = centerY - h / 2;
    maxY = centerY + h / 2;
    
    if (frameCount % 30 == 0) {
      drawMandelbrot();
    }
  }
  
  // Dibujar caja de zoom si se está arrastrando
  if (isDragging) {
    loadPixels();
    drawMandelbrot();
    updatePixels();
    
    stroke(255, 100, 100);
    strokeWeight(2);
    noFill();
    rect(dragStartX, dragStartY, mouseX - dragStartX, mouseY - dragStartY);
  }
  
  displayInfo();
}

void drawMandelbrot() {
  loadPixels();
  
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      float a = map(x, 0, width, minX, maxX);
      float b = map(y, 0, height, minY, maxY);
      
      float ca = a;
      float cb = b;
      int n = 0;
      
      while (n < maxIterations) {
        float aa = a * a - b * b;
        float bb = 2 * a * b;
        a = aa + ca;
        b = bb + cb;
        
        if (a * a + b * b > 16) {
          break;
        }
        n++;
      }
      
      color col = getColor(n, maxIterations);
      int pix = x + y * width;
      pixels[pix] = col;
    }
  }
  
  updatePixels();
}

color getColor(int iterations, int maxIter) {
  if (iterations == maxIter) {
    return color(0, 0, 0);
  }
  
  float t = float(iterations) / maxIter;
  float smoothT = sqrt(t);
  
  switch(colorPalette) {
    case 0: return color(200 + smoothT * 160, 80, 60 + smoothT * 40); // clásico
    case 1: return color(0 + smoothT * 60, 100, 50 + smoothT * 50);   // fuego
    case 2: return color(160 + smoothT * 40, 80, 40 + smoothT * 60);  // océano
    case 3: return color(280 + smoothT * 80, 90, 40 + smoothT * 60);  // galaxia
    case 4: return color((smoothT * 360) % 360, 100, 80);             // psicodélico
    case 5: return color(0, 0, smoothT * 100);                        // monocromo
    default: return color(smoothT * 360, 80, 80);
  }
}

void displayInfo() {
  fill(0, 0, 0, 200);
  noStroke();
  rect(10, 10, 350, 150, 10);
  
  fill(0, 0, 100);
  textAlign(LEFT);
  textSize(14);
  text("🌌 CONJUNTO DE MANDELBROT", 20, 30);
  text("Iteraciones: " + maxIterations, 20, 55);
  text("Paleta: " + getPaletteName(), 20, 75);
  text("Zoom: " + nf((maxX - minX), 1, 6), 20, 95);
  text("Modo: " + (explorerMode ? "Explorador Activo" : "Manual"), 20, 115);
  
  textSize(11);
  text("Clic+Arrastrar: Zoom | Doble clic: Zoom rápido", 20, 135);
  text("P: Paleta | +/-: Iter. | E: Explorador | B: Volver", 20, 150);
}

String getPaletteName() {
  String[] names = {"Clásico", "Fuego", "Océano", "Galaxia", "Psicodélico", "Mono"};
  return names[colorPalette];
}

// ======================
//   INTERACCIÓN RATÓN
// ======================
void mousePressed() {
  if (mouseButton == RIGHT) {
    zoomOut();
  } else {
    dragStartX = mouseX;
    dragStartY = mouseY;
    isDragging = true;
  }
}

void mouseReleased() {
  if (isDragging && mouseButton == LEFT) {
    float x1 = min(dragStartX, mouseX);
    float y1 = min(dragStartY, mouseY);
    float x2 = max(dragStartX, mouseX);
    float y2 = max(dragStartY, mouseY);
    
    if (abs(x2 - x1) > 5 && abs(y2 - y1) > 5) {
      saveZoomState();
      zoomToArea(x1, y1, x2, y2);
    }
  }
  isDragging = false;
  redraw();
}

// 👇 Ahora recibe MouseEvent correctamente
void mouseClicked(MouseEvent event) {
  if (event.getCount() == 2) {
    saveZoomState();
    zoomIn(mouseX, mouseY);
  }
}

// ======================
//   FUNCIONES DE ZOOM
// ======================
void zoomIn(float mx, float my) {
  float zoomFactor = 0.5;
  float centerX = map(mx, 0, width, minX, maxX);
  float centerY = map(my, 0, height, minY, maxY);
  
  float newWidth = (maxX - minX) * zoomFactor;
  float newHeight = (maxY - minY) * zoomFactor;
  
  minX = centerX - newWidth / 2;
  maxX = centerX + newWidth / 2;
  minY = centerY - newHeight / 2;
  maxY = centerY + newHeight / 2;
  
  drawMandelbrot();
  redraw();
}

void zoomToArea(float x1, float y1, float x2, float y2) {
  float newMinX = map(x1, 0, width, minX, maxX);
  float newMaxX = map(x2, 0, width, minX, maxX);
  float newMinY = map(y1, 0, height, minY, maxY);
  float newMaxY = map(y2, 0, height, minY, maxY);
  
  minX = newMinX;
  maxX = newMaxX;
  minY = newMinY;
  maxY = newMaxY;
  
  drawMandelbrot();
  redraw();
}

void zoomOut() {
  float centerX = (minX + maxX) / 2;
  float centerY = (minY + maxY) / 2;
  float newWidth = (maxX - minX) * 2;
  float newHeight = (maxY - minY) * 2;
  
  minX = centerX - newWidth / 2;
  maxX = centerX + newWidth / 2;
  minY = centerY - newHeight / 2;
  maxY = centerY + newHeight / 2;
  
  drawMandelbrot();
  redraw();
}

// ======================
//   HISTORIAL DE ZOOM
// ======================
void saveZoomState() {
  float[] state = {minX, maxX, minY, maxY};
  zoomHistory.add(state);
}

void restoreLastZoom() {
  if (zoomHistory.size() > 1) {
    zoomHistory.remove(zoomHistory.size() - 1);
    float[] state = zoomHistory.get(zoomHistory.size() - 1);
    minX = state[0];
    maxX = state[1];
    minY = state[2];
    maxY = state[3];
    drawMandelbrot();
    redraw();
  }
}

// ======================
//   TECLAS
// ======================
void keyPressed() {
  if (key == 'p' || key == 'P') {
    colorPalette = (colorPalette + 1) % 6;
    drawMandelbrot();
    redraw();
  }
  if (key == '+' || key == '=') {
    maxIterations = min(maxIterations + 20, 500);
    drawMandelbrot();
    redraw();
  }
  if (key == '-' || key == '_') {
    maxIterations = max(maxIterations - 20, 50);
    drawMandelbrot();
    redraw();
  }
  if (key == 'e' || key == 'E') {
    explorerMode = !explorerMode;
    if (explorerMode) loop(); else { noLoop(); redraw(); }
  }
  if (key == 'b' || key == 'B') restoreLastZoom();
  if (key == 'r' || key == 'R') {
    minX = -2.5; maxX = 1.5; minY = -2; maxY = 2;
    maxIterations = 100;
    zoomHistory.clear();
    saveZoomState();
    drawMandelbrot();
    redraw();
  }
  if (key == 's' || key == 'S') {
    saveFrame("mandelbrot-####.png");
    println("Imagen guardada!");
  }
}
