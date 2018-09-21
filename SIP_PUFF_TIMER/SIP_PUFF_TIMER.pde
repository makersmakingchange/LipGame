import processing.serial.Serial;

static final int PORT_INDEX = 0, BR = 115200;

static final int _SIP_THD = 132; //532
static final int _PUFF_THD = 900; //183
static final int SIP_THD = int(map(_SIP_THD, 1023, 0, 128, 720 - 128)); // 720 is height
static final int PUFF_THD = int(map(_PUFF_THD, 1023, 0, 128, 720 - 128));

static final int NOM = 540;

String myString;
int current_mpxv;
int[] mpxv_array;
int window_size;

int text_size;
String myText;

String timeText = "";
int sip_timer_0 = 0, puff_timer_0 = 0;
int sip_timer = 0, puff_timer = 0;

void setup(){
  size(1280, 720);
  window_size = width - 10;
  strokeWeight(3);
  smooth();
  mpxv_array = new int[window_size];
  
  noLoop();
  final String[] ports = Serial.list();
  printArray(ports);
  new Serial(this, ports[PORT_INDEX], BR).bufferUntil(ENTER);
}

void draw(){
  background(55);
  current_mpxv = int(myString);
  current_mpxv = int(map(current_mpxv, 1023, 0, 0, 1023));
  if (abs(current_mpxv - NOM) <= 50){
    myText = "Rest";
    sip_timer_0 = millis();
    puff_timer_0 = millis();
    sip_timer = 0;
    puff_timer = 0;
  }
  else if (current_mpxv < (NOM - 50)){
    if (current_mpxv < _SIP_THD){
      sip_timer = millis() - sip_timer_0;
      int tmpSize = int(map(sip_timer % 1000, 0, 999, 1, 128));
      sip_timer /= 1000;
      sip_timer += 1;
      textSize(tmpSize);
      fill(220, 75, 255);
      text(str(sip_timer), width / 2, height / 2);
    }
    else{
      sip_timer_0 = millis();
      sip_timer = 0;
    }
    myText = "Sipping";
    sip_timer = 0;
  }
  else if (current_mpxv > (NOM + 50)){
    if (current_mpxv > _PUFF_THD){
      puff_timer = millis() - puff_timer_0;
      int tmpSize = int(map(puff_timer % 1000, 0, 999, 1, 128));
      puff_timer /= 1000;
      puff_timer += 1;
      textSize(tmpSize);
      fill(220, 75, 0);
      text(str(puff_timer), width / 2, height / 2);
    }
    else{
      puff_timer_0 = millis();
      puff_timer = 0;
    }
    myText = "Puffing";
  } 
  for (int i = 1; i < window_size; i ++){
    mpxv_array[i - 1] = mpxv_array[i];
  }

  stroke(220, 75, 255);
  strokeWeight(3);
  line(0, SIP_THD, window_size, SIP_THD);
  
  stroke(220, 75, 0);
  strokeWeight(3);
  line(0, PUFF_THD, window_size, PUFF_THD);
  
  current_mpxv = int(map(current_mpxv, 1023, 0, 128, height - 128));
  text_size = int(map(current_mpxv, 1023, 0, 32, 128));
  stroke(220, 75, current_mpxv - 128);
  strokeWeight(8);
  line(0, current_mpxv, window_size, current_mpxv);
  
  mpxv_array[window_size - 1] = current_mpxv;
  strokeWeight(12);
  for(int i = 1; i < window_size; i ++) {
      stroke(220, 75, mpxv_array[i] - 128);
      point(i, mpxv_array[i]);
  }
  
  textSize(text_size);
  fill(220, 75, current_mpxv - 128);
  text(myText, width / 2 - text_size, height / 2 - 256);
  //println(current_mpxv);
  
  //println("Sip Timer: " + sip_timer);
  //println("Puff Timer: " + puff_timer);
}

void serialEvent(final Serial s){
  myString = s.readString().trim();
  redraw = true;
}
