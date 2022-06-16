import gab.opencv.*;
import processing.video.*;
import processing.sound.*;
import java.awt.Rectangle;

ArrayList<Ball> ball;

Capture cam;
OpenCV opencv;
Rectangle[] faces;

AudioIn in;
Amplitude amp;

FFT fft;
int COUNT = 64;
float[] spectrum = new float[COUNT];

int ballColor;

// drawing settings
int thickness = 1000;
int opacity = 120;
int colorCoef = 80;  // How easily red color appears

void setup() {
  size(640,480);
  noStroke();
  ball = new ArrayList<Ball>();
  
  // Camera
  String[] cameras = Capture.list();
  
  for (int i=0; i<cameras.length; i++) {
    println("[" + i + "] " + cameras[i]);
  }
  
  cam = new Capture(this, cameras[0]);
  cam.start();
  
  // Sound
  in = new AudioIn(this);
  in.start();
  amp = new Amplitude(this);
  amp.input(in);
  
  fft = new FFT(this, COUNT);
  fft.input(in);
  
}

void draw() {
  if (cam.available() == true) {
    cam.read();
    image(cam,0,0);
    
    // Determine the radius according to the volume
    float a = amp.analyze();
    float size = a * thickness;
    
    // Determine the color according to the pitch
    fft.analyze(spectrum);
    float fftMax = max(spectrum);
    for (int i=0; i<COUNT; i++) {
      if (fftMax == spectrum[i]) {
        ballColor = i * colorCoef;
        println(ballColor);
      }
    }   
    
    // Detect the mouth position
    opencv = new OpenCV(this, cam);
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
    faces = opencv.detect();
    
    for (int i=0; i<faces.length; i++) {
      // stroke(#ff0000);
      // noFill();
      // rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
      
      // Approximate the mouth position from the face position
      float mouthX = faces[i].x + faces[i].width/2;
      float mouthY = faces[i].y + faces[i].height*7/9;
      point(mouthX, mouthY);
      ball.add(new Ball(mouthX, mouthY, size, ballColor));
    }
    
    // Draw circles at the mouth
    for (int i=0; i<ball.size(); i++) {
      ball.get(i).display();
    }
  }
}

// Click to reset the canvas
void mousePressed() {
  ball.clear();
}

class Ball{
  float pose_x, pose_y, r, c;
  
  Ball(float pose_x, float pose_y, float r, int c) {
    this.pose_x = pose_x;
    this.pose_y = pose_y;
    this.r = r;
    this.c = c;
  }
  
  void display() {
    fill(c, 128, 128, opacity);
    circle(pose_x, pose_y, r);
  }
}
