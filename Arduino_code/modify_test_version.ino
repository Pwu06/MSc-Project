#include "delay_x.h"

String command;
const int pause = 1595;

void setup() {
  DDRD = B11111111;
  //PORTD = B00100000;
  Serial.begin(9600);
}

void loop() {
  int message_length = 1; 
  char card_type = 'A';
  byte card_port = B00000000;
  byte trigger_port = B00000000;

  read_and_implement_command(card_type, message_length, card_port, trigger_port);
}

void read_and_implement_command(char &card_type, int &message_length, byte &card_port, byte trigger_port){
  if (Serial.available()) {
    command = Serial.readStringUntil('\n');
    card_type = command.charAt(0);
    card_type_selection(card_type, card_port);
    message_length = command.length()-3;
    byte message[message_length*4];
    message_encode(message_length, card_port, trigger_port, message);
    for (int j_=0; j_<message_length*4; j_++){
      PORTD = message[j_];
      //Serial.println(message[j_]);
      _delay_ns(pause);
    }
  }
}

void card_type_selection(char &type, byte &card_port){
  switch (type){
    case 'A': 
      card_port = B00000000;
      break;
    case 'B': 
      card_port = B10000000;
      break;
    default: 
      break;
  } 
}

void message_encode(int message_length, byte card_port, byte trigger_port, byte* message){
  int i_;
  int j_ = 0;
  for (i_=1;i_ <= message_length;i_++){
    //Serial.print("Character: ");
    //Serial.println(command.charAt(i_));
    if (i_ == message_length-1){
        trigger_port = B01000000;
    }
    else{
        trigger_port = B00000000;
    }
    switch (command.charAt(i_)){
      case 'X':
        message[j_] =   B00100000+card_port+trigger_port;
        message[j_+1] = B00100000+card_port+trigger_port;
        message[j_+2] = B00000000+card_port+trigger_port;
        message[j_+3] = B00100000+card_port+trigger_port;
        j_ = j_+4;
        break;
      case 'Y':
        message[j_] =   B00100000+card_port+trigger_port;
        message[j_+1] = B00100000+card_port+trigger_port;
        message[j_+2] = B00100000+card_port+trigger_port;
        message[j_+3] = B00100000+card_port+trigger_port;
        j_ = j_+4;
        break;
      case 'Z':
        message[j_] =   B00000000+card_port+trigger_port;
        message[j_+1] = B00100000+card_port+trigger_port;
        message[j_+2] = B00100000+card_port+trigger_port;
        message[j_+3] = B00100000+card_port+trigger_port;
        j_ = j_+4;
        break;
      case 'U':
        message[j_] =   B00000000+card_port+trigger_port;
        message[j_+1] = B00000000+card_port+trigger_port;
        message[j_+2] = B00000000+card_port+trigger_port;
        message[j_+3] = B00000000+card_port+trigger_port;
        j_ = j_+4;
        break;
      default: 
        break;
    }       
  }
}
