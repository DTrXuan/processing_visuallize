import processing.serial.*;

Serial myPort; // Create a serial port object
String val;     // Data received from the serial port

float ax, ay, az, gx, gy, gz; // Global variables for accelerometer and gyroscope data
float positionX, positionY, positionZ; // Variables to store cube position
float scaleFactor = 0.5; // Scale factor for the animation
float roll, pitch, yaw, rollDegrees, pitchDegrees, yawDegrees;

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
    val = myPort.readStringUntil('\n'); // Read the data from the serial port
    if (val != null) {
      val = val.trim(); // Remove any leading/trailing white space
      String[] data = split(val, ' '); // Split the data into an array

      if (data.length == 6) {
        // Parse accelerometer data
        ax = float(data[0]);
        ay = float(data[1]);
        az = float(data[2]);

        // Parse gyroscope data
        gx = float(data[3]);
        gy = float(data[4]);
        gz = float(data[5]);

        // Calculate yaw (rotation around the Z-axis)
        yaw = atan2(ax, sqrt(ay * ay + az * az));
        yawDegrees = degrees(yaw);
        // Calculate roll (rotation around the X-axis)
        roll = atan2(ay, az);
        rollDegrees = degrees(roll);
        // Calculate pitch (rotation around the Y-axis)
        pitch = atan2(-ax, sqrt(ay * ay + az * az));
        pitchDegrees = degrees(pitch);
        // Update cube position based on gyro data
        positionX = roll;
        positionY = pitch;
        positionZ = yaw;
      }
    }
  }

  // Display X, Y, and Z coordinates fixed on the screen
  fill(0);
  textSize(16);
  textAlign(LEFT);
  text("X: " + nf(positionX, 1, 2), 20, 20);
  text("Y: " + nf(positionY, 1, 2), 20, 40);
  text("Z: " + nf(positionZ, 1, 2), 20, 60);

  textSize(16);
  fill(0); // Set text color to black
  text("Accelerometer (m/s^2):", 20, 80);
  text("X: " + ax, 20, 100);
  text("Y: " + ay, 20, 120);
  text("Z: " + az, 20, 140);

  text("Gyroscope (degrees/s):", 20, 160);
  text("X: " + gx, 20, 180);
  text("Y: " + gy, 20, 200);
  text("Z: " + gz, 20, 220);
  
  text("Roll(x)  " + rollDegrees, 20, 260);
  text("Pitch(y) " + pitchDegrees, 20, 280);
  text("Yaw(z)   " + yawDegrees, 20, 300);  
  // Instructions
  textAlign(LEFT);
  text("Press 'q' to quit", 20, height - 20);

  // Display animated data
  // Display the coordinate grid
  // Vẽ trục X (đỏ)
  translate(width / 2 + positionX, height / 2 + positionY, positionZ);
  stroke(255, 0, 0,30);
  line(-200, 0, 200, 0);
  text("X", 200, 0, 0); // Display X-axis label
  
  // Vẽ trục Y (xanh lá cây)
  stroke(0, 255, 0,30);
  line(0, -200, 0, 200);
  
  // Vẽ trục Z (xanh dương)
  stroke(0, 0, 255,30);
  line(0, 0, 0, 0, 0, 200);
  
  //translate(width / 2 + positionX, height / 2 + positionY, positionZ);
  rotateX(-positionX + PI/2);
  rotateY(positionY);
  rotateZ(positionZ);

  /*Draw Gyro box*/  
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
  box(60,100,20);
}

void keyPressed() {
  if (key == 'q' || key == 'Q') {
    myPort.stop();
    exit();
  }
}
