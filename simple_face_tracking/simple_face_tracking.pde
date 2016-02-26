/*
Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 
 KinectPV2, Kinect for Windows v2 library for processing
 
 Simple Face tracking, up-to 6 users with mode identifier
 */


/*

 */
import KinectPV2.*;

KinectPV2 kinect;

FaceData [] faceData;
KJoint[] joints;
boolean bored = false;

void setup() {
  size(1920, 1080, P2D);

  kinect = new KinectPV2(this);

  //for face detection based on the color Img
  kinect.enableColorImg(true);

  //for face detection base on the infrared Img
  kinect.enableInfraredImg(true);

  //enable face detection
  kinect.enableFaceDetection(true);
  //enable 3d  with (x,y,z) position
  kinect.enableSkeleton3DMap(true);

  kinect.init();
}

void draw() {
  background(0);

  kinect.generateFaceData();

  //draw face information obtained by the color frame
  pushMatrix();
  scale(0.5f);
  image(kinect.getColorImage(), 0, 0);
  getFaceMapColorData();
  popMatrix();


  //draw face information obtained by the infrared frame
  pushMatrix();
  translate(1920*0.5f, 0.0f);
  image(kinect.getInfraredImage(), 0, 0);
  getFaceMapInfraredData();
  popMatrix();


  fill(255);
  //text("frameRate "+frameRate, 50, 50);

  // skeleton
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();
  // Get the skeleton
  // This sketch assumes one skeleton
  if (skeletonArray.size() > 0) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0);

    if (skeleton.isTracked()) {
      joints = skeleton.getJoints();      

      //Set which joint is drawing
      // Get the index number for the joint
      //int trailingJointIndex = getTrailingJointIndex();
      //// Retrieve the joint using the index number
      //KJoint trailingJoint = joints[trailingJointIndex];
      //// Get the PVector containing the xyz position of the joint
      //PVector trailingJointPosition = trailingJoint.getPosition().copy();

      //// Add to trail array
      //trail.add(trailingJointPosition);

      // is one hand near head?
      PVector leftHand = joints[KinectPV2.JointType_HandLeft].getPosition().copy();
      PVector rightHand = joints[KinectPV2.JointType_HandRight].getPosition().copy();
      PVector head = joints[KinectPV2.JointType_Head].getPosition().copy();

      float left2Head = leftHand.dist(head);
      float right2Head = rightHand.dist(head);
      //println(left2Head);
      //println(right2Head);
      if (left2Head < 0.18 || right2Head < 0.18) {
        bored = true;
        textSize(60);
        fill(255, 0, 0);
        text("bored", 100, 100);
        //println("LEFT");
      } else {
        bored = false;
      }
      //if (right2Head < 0.18) {
      //  bored = true;
      //  textSize(60);
      //  fill(255, 0, 0);
      //  text("bored", 100, 100);
      //  //println("RIGHT");
      //}

      // is the person interested?
      PVector topOfSpine = joints[KinectPV2.JointType_SpineShoulder].getPosition().copy();
      PVector baseOfSpine = joints[KinectPV2.JointType_SpineBase].getPosition().copy();

      float leaning = baseOfSpine.z - topOfSpine.z;
      //println(leaning);
      if (leaning > 0.05 && !bored) {
        fill(0, 255, 0);
        text("interested", 100, 100);
      }


      //Draw joints
      stroke(255);
      strokeWeight(5);
      drawJoints();
    }
  }
}


public void getFaceMapColorData() {
  //get the face data
  ArrayList<FaceData> faceData =  kinect.getFaceData();

  for (int i = 0; i < faceData.size(); i++) {
    FaceData faceD = faceData.get(i);
    if (faceD.isFaceTracked()) {

      //obtain the face data from the colo frame
      PVector [] facePointsColor = faceD.getFacePointsColorMap();

      KRectangle rectFace = faceD.getBoundingRectColor();

      FaceFeatures [] faceFeatures = faceD.getFaceFeatures();

      //get the color of th user
      int col = faceD.getIndexColor();

      fill(col);

      //nose position
      PVector nosePos = new PVector();
      noStroke();

      //update the nose positions
      for (int j = 0; j < facePointsColor.length; j++) {
        if (j == KinectPV2.Face_Nose)
          nosePos.set(facePointsColor[j].x, facePointsColor[j].y);

        ellipse(facePointsColor[j].x, facePointsColor[j].y, 15, 15);
      }

      //head orientation
      float pitch = faceD.getPitch();
      float yaw   = faceD.getYaw();
      float roll  = faceD.getRoll();

      // println(pitch+" "+yaw+" "+roll);

      //Feature detection of the user
      if (nosePos.x != 0 && nosePos.y != 0)
        for (int j = 0; j < 8; j++) {
          int st   = faceFeatures[j].getState();
          int type = faceFeatures[j].getFeatureType();

          String str = getStateTypeAsString(st, type);

          fill(255);
          text(str, nosePos.x + 150, nosePos.y - 70 + j*25);
          //println("HERE");
        }
      stroke(255, 0, 0);
      noFill();
      rect(rectFace.getX(), rectFace.getY(), rectFace.getWidth(), rectFace.getHeight());
    }
  }
}

public void getFaceMapInfraredData() {

  ArrayList<FaceData> faceData =  kinect.getFaceData();

  for (int i = 0; i < faceData.size(); i++) {
    FaceData faceD = faceData.get(i);

    if (faceD.isFaceTracked()) {
      //get the face data from the infrared frame
      PVector [] facePointsInfrared = faceD.getFacePointsInfraredMap();

      KRectangle rectFace = faceD.getBoundingRectInfrared();

      FaceFeatures [] faceFeatures = faceD.getFaceFeatures();

      //get the color of th user
      int col = faceD.getIndexColor();

      //for nose information
      PVector nosePos = new PVector();
      noStroke();

      fill(col);
      for (int j = 0; j < facePointsInfrared.length; j++) {
        //obtain the position of the nose
        if (j == KinectPV2.Face_Nose)
          nosePos.set(facePointsInfrared[j].x, facePointsInfrared[j].y);

        ellipse(facePointsInfrared[j].x, facePointsInfrared[j].y, 15, 15);
      }

      //Feature detection of the user
      if (nosePos.x != 0 && nosePos.y != 0)
        for (int j = 0; j < 8; j++) {
          int st   = faceFeatures[j].getState();
          int type = faceFeatures[j].getFeatureType();

          String str = getStateTypeAsString(st, type);

          fill(255);
          textSize(30);
          text(str, nosePos.x + 150, nosePos.y - 70 + j*40);
        }
      stroke(255, 0, 0);
      noFill();
      rect(rectFace.getX(), rectFace.getY(), rectFace.getWidth(), rectFace.getHeight());
    }
  }
}


//Face properties
// Happy
// Engaged
// LeftEyeClosed
// RightEyeClosed
// LookingAway
// MouthMoved
// MouthOpen
// WearingGlasses
// Each one can be  
//      Unknown
//      Yes
//      No
String getStateTypeAsString(int state, int type) {
  String  str ="";
  switch(type) {
  case KinectPV2.FaceProperty_Happy:
    str = "Happy";
    break;

  case KinectPV2.FaceProperty_Engaged:
    str = "Engaged";
    break;

  case KinectPV2.FaceProperty_LeftEyeClosed:
    str = "LeftEyeClosed";
    break;

  case KinectPV2.FaceProperty_RightEyeClosed:
    str = "RightEyeClosed";
    break;

  case KinectPV2.FaceProperty_LookingAway:
    str = "LookingAway";
    break;

  case KinectPV2.FaceProperty_MouthMoved:
    str = "MouthMoved";
    break;

  case KinectPV2.FaceProperty_MouthOpen:
    str = "MouthOpen";
    break;

  case KinectPV2.FaceProperty_WearingGlasses:
    str = "WearingGlasses";
    break;
  }

  switch(state) {
  case KinectPV2.DetectionResult_Unknown:
    str += ": Unknown";
    break;
  case KinectPV2.DetectionResult_Yes:
    str += ": Yes";
    break;
  case KinectPV2.DetectionResult_No:
    str += ": No";
    break;
  }

  return str;
}

void drawJoints() {
  //Bust
  drawJoint(KinectPV2.JointType_Head);
  drawJoint(KinectPV2.JointType_Neck);
  drawJoint(KinectPV2.JointType_SpineShoulder);

  //Torso
  drawJoint(KinectPV2.JointType_SpineMid);
  drawJoint(KinectPV2.JointType_SpineBase);

  // Right Arm    
  drawJoint(KinectPV2.JointType_ShoulderRight);
  drawJoint(KinectPV2.JointType_ElbowRight);
  drawJoint(KinectPV2.JointType_WristRight);
  drawJoint(KinectPV2.JointType_HandRight);
  drawJoint(KinectPV2.JointType_HandTipRight);
  drawJoint(KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawJoint(KinectPV2.JointType_ShoulderLeft);
  drawJoint(KinectPV2.JointType_ElbowLeft);
  drawJoint(KinectPV2.JointType_WristLeft);
  drawJoint(KinectPV2.JointType_HandLeft);
  drawJoint(KinectPV2.JointType_HandTipLeft);
  drawJoint(KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawJoint(KinectPV2.JointType_HipRight);
  drawJoint(KinectPV2.JointType_KneeRight);
  drawJoint(KinectPV2.JointType_AnkleRight);
  drawJoint(KinectPV2.JointType_FootRight);

  // Left Leg
  drawJoint(KinectPV2.JointType_HipLeft);
  drawJoint(KinectPV2.JointType_KneeLeft);
  drawJoint(KinectPV2.JointType_AnkleLeft);
  drawJoint(KinectPV2.JointType_FootLeft);
}

void drawJoint(int jointType) {
  pushMatrix();
  translate(1500, 1080/2, 0);
  scale(10);
  rotateX(PI);
  KJoint joint = joints[jointType];
  PVector jointPosition = joint.getPosition();
  point(jointPosition.x, jointPosition.y, jointPosition.z);
  //println("x position " + jointPosition.x);
  //println("y position " + jointPosition.y);
  //println("z position " + jointPosition.z);
  popMatrix();
}