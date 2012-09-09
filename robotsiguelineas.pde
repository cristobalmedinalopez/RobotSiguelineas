/*
 * Fecha: 12/12/2012
 * Autor: Cristóbal Medina López
 * Licencia:
 * Este Software está distribuido bajo la licencia general pública de GNU, GPL. Puedes encontrar esta licencia completa en http://www.gnu.org.
 * Es gratuito, puedes copiar y utlizar el código libremente sin cargo alguno. Tienes derecho a modificar
 * el código fuente y a distribuirlo por tu cuenta, siempre informando de la procedencia original.
 *
*/

#include "Ultrasonic.h" //Include de la función para manejar el sensor de ultrasonido
#define CENTER_RANGE 5 //Rango central para los motores

Ultrasonic ultrasonic(8,7); //Inicio de los pines 8 y 7 para el ultrasonido

int cnyI = 2; //sensor cny izquierda
int cnyD = 3; //sensor sny derecha
int motorD=10; //motor derecha
int motorI=11; //motor izquierda
int luzGiroD=4; 
int luzGiroI=5;
int luzError=6;
int luzVision=9;
int luz=3; //entrada sensor luminosidad
int muestra1=0; 
int muestra2=0;
int altavoz=12;
int paradoI=0;
int paradoD=0;

//Función para poner en movimiento el motor derecho
void goDrh(int power)
{
  paradoD=0;
  apagar(luzGiroD);
  analogWrite(motorD,(power>CENTER_RANGE || power<-CENTER_RANGE) ? map(-power,-100,100,135,225):0);
} 

//Función para poner en movimiento el motor izquierdo
void goIzq(int power)
{
  paradoI=0;
  apagar(luzGiroI);
  power=-power;
  analogWrite(motorI,(power>CENTER_RANGE || power<-CENTER_RANGE) ? map(-power,-100,100,135,225):0);
} 

//Función para detener el motor derecho
void stopDrh(){
  paradoD=1;
  encender(luzGiroD);
  analogWrite(motorD,0);
}

//Función para detener el motor derecho
void stopIzq(){
  paradoI=1;
  encender(luzGiroI);
  analogWrite(motorI,0);
}

//Función para encender un led pasado por parametro
void encender(int luz){
   digitalWrite(luz,HIGH); 
}

//Función para apagar un led pasado por parametro
void apagar(int luz){
   digitalWrite(luz,LOW); 
}

//Función para emitir una frecuencia durante un tiempo
//similar a tone()
void buzz(int targetPin, long frequency, long length) {
  long delayValue = 1000000/frequency/2; 
  long numCycles = frequency * length/ 1000; 
 for (long i=0; i < numCycles; i++){ 
    digitalWrite(targetPin,HIGH); 
    delayMicroseconds(delayValue);
    digitalWrite(targetPin,LOW); 
    delayMicroseconds(delayValue); 
  }
}
  
void error(){
  
  stopDrh();
  stopIzq();
  apagar(luzGiroD);
  apagar(luzGiroI);
  
  for (int i=0;i<10;i++){
    encender(luzError);
    buzz(12, 2500, 500); 
    apagar(luzError);
    delay(300);
  }
  
  goDrh(100); 
  goIzq(100); 
}

//Función encargada de detectar si hay algún obstáculo en el camino
boolean obstaculo(){
  muestra1=ultrasonic.Ranging(CM);
  delay(10);
  muestra2=ultrasonic.Ranging(CM);
  if (muestra1==muestra2){
      if (muestra1<= 10){
         return true;
      }else{
        return false;
      }
  }else{
    return false;
  }  
}

//Función para detener los motores durante 3 segúndos
void parada(){
  stopDrh();
  stopIzq();
  delay(3000);
  
  for (int i=0;i<2000;i++){
    goDrh(100); 
    goIzq(100); 
  }
}

//iniciar pines
void setup() {
pinMode(cnyI, INPUT);
pinMode(cnyD, INPUT);
pinMode(luzGiroI, OUTPUT);
pinMode(luzGiroD, OUTPUT);
pinMode(luzError, OUTPUT);
pinMode(luzVision, OUTPUT);
pinMode(altavoz,OUTPUT);
Serial.begin(9600);
}

void loop() {
  
//si en marcha encuentra en un obstaculo...
if ((paradoD==0)&&(paradoI==0)){
  if (obstaculo()==true){
    error();
  }
}

//si ambos cny se encuentran sobre la linea blanca...
if ((digitalRead(cnyI) == LOW)&&(digitalRead(cnyD) == LOW)){
   parada();
}

if (digitalRead(cnyI) == HIGH){
 goIzq(100); 
}else{
 stopIzq();
}
if (digitalRead(cnyD) == HIGH){
  goDrh(100); 
}else{
 stopDrh();
}

//si la luminosidad es baja..
if (analogRead(luz)>1000){
  encender(luzVision);
}else{
  apagar(luzVision);
}

}
