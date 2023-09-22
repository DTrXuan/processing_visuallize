import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port

float ax, ay, az, gx, gy, gz; // Global variables for accelerometer and gyroscope data

float mouseX = 200;  // Initial X-coordinate for the point (mouse)
float mouseY = 200;  // Initial Y-coordinate for the point (mouse)

float sensitivity = 10.0;  // Sensitivity factor for mouse movement
float lastUpdateTime;  // Time of the last sensor update
float timeoutDuration = 2.0;  // Time in seconds to consider the sensor inactive

void setup() {
  size(500, 500);  // Set the size of the canvas
  background(255); // Set the background to white

  lastUpdateTime = millis(); // Initialize the last update time

  // Automatically detect the correct COM port for the Arduino
  String[] portList = Serial.list();
  for (String port : portList) {
    println("Trying port: " + port);
    myPort = new Serial(this, port, 9600);
    delay(1000);  // Wait for a moment to establish the connection

    if (myPort.available() > 0) {
      // Successfully connected to the Arduino
      println("Connected to: " + port);
      break;
    } else {
      // Close the port and try the next one
      myPort.stop();
    }
  }

  if (myPort == null || !myPort.active()) {
    println("No connection established. Make sure your Arduino is connected.");
    exit();  // Exit the sketch if no connection is established
  }
}

void draw() {
  background(255); // Clear the screen

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

        // Parse Rotation data
        gx = float(data[3]);
        gy = float(data[4]);
        gz = float(data[5]);
      }
    }
  }
  
  // Draw a semi-transparent ellipse at the previous mouse position
  fill(0, 0, 0, 70); // Set fill color to red with 50% opacity
  ellipse(mouseX, mouseY, 10, 10); // Adjust the size of the shadow ellipse as needed

  // Calculate the time elapsed since the last sensor update
  float currentTime = millis();
  
  // Check if the cursor should be updated based on sensor data
  if (abs(gx) > 5 || abs(gy) > 5) {
    // Map Gyroscope values to mouse movement
    float moveX = map(gx, -9, 9, -40, 40);
    float moveY = map(gy, -9, 9, -40, 40);

    // Update mouse position
    mouseX = constrain(mouseX + moveX, 0, width);
    mouseY = constrain(mouseY + moveY, 0, height);

    // Update the last update time
    lastUpdateTime = currentTime;
  }

  // Display MPU6050 data as text on the screen
  textSize(16);
  fill(0); // Set text color to black
  text("Accelerometer (m/s^2):", 20, 30);
  text("X: " + ax, 40, 60);
  text("Y: " + ay, 40, 80);
  text("Z: " + az, 40, 100);

  text("Gyroscope (degrees/s):", 20, 130);
  text("X: " + gx, 40, 160);
  text("Y: " + gy, 40, 180);
  text("Z: " + gz, 40, 200);

  // Display the "mouse" point on the screen
  fill(255, 0, 0); // Set point color to red
  ellipse(mouseX, mouseY, 10, 10); // Draw a point (mouse) at the current X and Y coordinates
  
}
