/*
 Thomas Sanchez Lengeling.
 http://codigogenerativo.com/
 
 KinectPV2, Kinect for Windows v2 library for processing
 
 3D Skeleton.
 Some features a not implemented, such as orientation
 */

import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

KJoint[] joints;
int trailingJointIndex;
//ArrayList<PVector>trail = new ArrayList<PVector>();
boolean bored = false;

void setup() {
  size(1024, 768, P3D);

  kinect = new KinectPV2(this);

  //enable 3d  with (x,y,z) position
  kinect.enableSkeleton3DMap(true);
  kinect.enableColorImg(true);
  kinect.enableFaceDetection(true);

  kinect.init();
}

void draw() {
  background(0);

  //Translate the scene to the center 
  //Scale it x1000
  //Rotate it around the x-axis 180-degrees
  //pushMatrix();
  //translate(width/2, height/2, 0);
  //scale(1000);
  //rotateX(PI);

  image(kinect.getColorImage(), 0, 0);

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeleton3d();
  // get the face data as an ArrayList
  ArrayList<FaceData> faceData = kinect.getFaceData();

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
  for (int i=0; i < faceData.size(); i++) {
    FaceData faceD = faceData.get(i);
    if (faceD.isFaceTracked()) {
      // obtain the face data from the color frame
      PVector[] facePointsColor = faceD.getFacePointsColorMap();
      KRectangle rectFace = faceD.getBoundingRectColor();
      FaceFeatures[] faceFeatures = faceD.getFaceFeatures();

      // get the color of the user
      int col = faceD.getIndexColor();
      fill(col);

      // nose position
      PVector nosePos = new PVector();
      noStroke();

      // update the nose position
      for (int j=0; j < facePointsColor.length; j++) {
        if (j == KinectPV2.Face_Nose) {
          nosePos.set(facePointsColor[j].x, facePointsColor[j].y);
        }

        ellipse(facePointsColor[j].x, facePointsColor[j].y, 15, 15);
      }

      // display the face features and states
      for (int j=0; j < 8; j++) {
        int st = faceFeatures[j].getState();
        int type = faceFeatures[j].getFeatureType();

        String str = getStateTypeAsString(st, type);

        fill(255);
        text(str, nosePos.x + 150, nosePos.y - 70 + j*25);
      }

      // draw a rectangle around the face
      stroke(255, 0, 0);
      noFill();
      rect(rectFace.getX(), rectFace.getY(), rectFace.getWidth(), rectFace.getHeight());
    }
  }
  // Draw trail
  //stroke(255, 0, 0);
  //strokeWeight(10);      
  //for (PVector t : trail) {
  //  point(t.x, t.y, t.z);
  //}

  //popMatrix();
}

int getTrailingJointIndex() {

  //Bust
  //return KinectPV2.JointType_Head;
  //return KinectPV2.JointType_Neck;
  //return KinectPV2.JointType_SpineShoulder;

  //Torso
  //return KinectPV2.JointType_SpineMid;
  //return KinectPV2.JointType_SpineBase;

  // Right Arm    
  //return KinectPV2.JointType_ShoulderRight;
  //return KinectPV2.JointType_ElbowRight;
  //return KinectPV2.JointType_WristRight;
  //return KinectPV2.JointType_HandRight;
  //return KinectPV2.JointType_HandTipRight;
  //return KinectPV2.JointType_ThumbRight;

  // Left Arm
  //return KinectPV2.JointType_ShoulderLeft;
  //return KinectPV2.JointType_ElbowLeft;
  //return KinectPV2.JointType_WristLeft;
  return KinectPV2.JointType_HandLeft;
  //return KinectPV2.JointType_HandTipLeft;
  //return KinectPV2.JointType_ThumbLeft;

  // Right Leg
  //return KinectPV2.JointType_HipRight;
  //return KinectPV2.JointType_KneeRight;
  //return KinectPV2.JointType_AnkleRight;
  //return KinectPV2.JointType_FootRight;

  // Left Leg
  //return KinectPV2.JointType_HipLeft;
  //return KinectPV2.JointType_KneeLeft;
  //return KinectPV2.JointType_AnkleLeft;
  //return KinectPV2.JointType_FootLeft;
}

void drawJoint(int jointType) {
  pushMatrix();
  translate(width/2, height/2, 0);
  scale(1000);
  rotateX(PI);
  KJoint joint = joints[jointType];
  PVector jointPosition = joint.getPosition();
  point(jointPosition.x, jointPosition.y, jointPosition.z);
  //println("x position " + jointPosition.x);
  //println("y position " + jointPosition.y);
  //println("z position " + jointPosition.z);
  popMatrix();
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