import processing.serial.*;

Serial myPort; // Create a serial port object
float angleX, angleY, angleZ; // Variables to store gyro data
float positionX, positionY, positionZ; // Variables to store cube position
float scaleFactor = 0.5; // Scale factor for the animation

void setup() {
  size(800, 600, P3D); // Specify the P3D renderer for 3D
  positionX = 0; // Initial position of the cube
  positionY = 0;
  positionZ = 0;

  String portName = Serial.list()[0]; // Change the index as needed
  myPort = new Serial(this, portName, 9600);
  stroke(0); // Set stroke color to black
}

void draw() {
  background(220);

  // Read data from Arduino
  while (myPort.available() > 0) {
    String data = myPort.readStringUntil('\n');
    if (data != null) {
      data = data.trim();
      String[] gyroData = split(data, ' ');
      if (gyroData.length == 3) {
        angleX = float(gyroData[0]) * scaleFactor;
        angleY = float(gyroData[1]) * scaleFactor;
        angleZ = float(gyroData[2]) * scaleFactor;
      }
    }
  }

  // Update cube position based on gyro data
  positionX += angleX;
  positionY += angleY;
  positionZ += angleZ;
  
  // Display X, Y, and Z coordinates fixed on the screen
  fill(0);
  textSize(16);
  textAlign(LEFT);
  text("X: " + nf(positionX, 1, 2), 20, 20);
  text("Y: " + nf(positionY, 1, 2), 20, 40);
  text("Z: " + nf(positionZ, 1, 2), 20, 60);

  // Instructions
  textAlign(LEFT);
  text("Press 'q' to quit", 20, height - 20);
  // Display animated data
  translate(width / 2 + positionX, height / 2 + positionY, positionZ);
  rotateX(angleX);
  rotateY(angleY);
  rotateZ(angleZ);

  // Draw the X, Y, and Z axis lines
  strokeWeight(2); // Set stroke weight
  stroke(255, 0, 0); // Red color for X-axis
  line(0, 0, 0, 100, 0, 0); // X-axis
  text("X", 110, 0, 0); // Display X-axis label
  
  stroke(0, 255, 0); // Green color for Y-axis
  line(0, 0, 0, 0, 100, 0); // Y-axis
  text("Y", 0, 110, 0); // Display Y-axis label
  
  stroke(0, 0, 255); // Blue color for Z-axis
  line(0, 0, 0, 0, 0, 100); // Z-axis
  text("Z", 0, 0, 110); // Display Z-axis label

  // Draw the cube edges
  noFill(); // Do not fill the shape
  strokeWeight(2); // Set stroke weight to make edges more visible
  box(100);

}

void keyPressed() {
  if (key == 'q' || key == 'Q') {
    myPort.stop();
    exit();
  }
}
