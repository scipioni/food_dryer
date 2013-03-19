#include <Wire.h>
#include <U8glib.h>
#include <HIH61x.h>

//#define DEBUG 

#ifdef DEBUG
  #define DEBUG_PRINT(x)     Serial.print (x)
  #define DEBUG_PRINTDEC(x)     Serial.print (x, DEC)
  #define DEBUG_PRINTLN(x)  Serial.println (x)
#else
  #define DEBUG_PRINT(x)
  #define DEBUG_PRINTDEC(x)
  #define DEBUG_PRINTLN(x)
#endif 



/* INTERRUPTS on UNO32 */
#define pinINT0 38
#define pinINT1 2
#define pinINT2 7
#define pinINT3 8
#define pinINT4 35
#define INT0 0
#define INT1 1
#define INT2 2
#define INT3 3
#define INT4 4
/* #################### */

/* DISPLAY Olimex LCD3110 */
#define PIN_SCE   2 // CS
#define PIN_RESET 6 // RES 
#define PIN_A0    5 // D/#C or A0
#define PIN_MOSI  4 // DN MOSI
#define PIN_SCLK  3 // SCK
#define LCD_CONTRAST 170


/* HIH6120 internal and external */
#define PIN_HIH_INT 8
#define REFRESH_INT 1000
#define PIN_HIH_EXT 9

#define PIN_MOTOR 11

#define DELTA_HUM 0.03 // g/m^3


/* display */
U8GLIB_TLS8204_84X48 u8g(PIN_SCLK, PIN_MOSI, PIN_SCE, PIN_A0, PIN_RESET);

HIH61x hih_int(PIN_HIH_INT, REFRESH_INT);
HIH61x hih_ext(PIN_HIH_EXT, REFRESH_INT);

unsigned long now;
bool motor_on=false;

void draw(void) {
  u8g.setFont(u8g_font_5x7);
  u8g.setPrintPos( 0, 10);
  u8g.print("T:");
  u8g.print(hih_int.temp);
  u8g.print("  ");
  u8g.print(hih_ext.temp);
  u8g.setPrintPos( 0, 20);
  u8g.print("H%:");
  u8g.print(hih_int.hum);
  u8g.print("  ");
  u8g.print(hih_ext.hum);
  u8g.setPrintPos( 0, 30);
  u8g.print("H:");
  u8g.print(hih_int.hum_abs);
  u8g.print("  ");
  u8g.print(hih_ext.hum_abs);
  u8g.setPrintPos( 0, 40);

  if (motor_on)
    u8g.print("ON");
  else
    u8g.print("OFF");
}

boolean check_signals(float hum1, float hum2) {
  if (hum1 - hum2 > DELTA_HUM) return true;
  return false; 
}



void setup()
{
    Serial.begin (115200);

    Wire.begin();

    pinMode(PIN_LED1, OUTPUT);
    pinMode(PIN_LED2, OUTPUT);
    
    pinMode(PIN_MOTOR, OUTPUT);
    digitalWrite(PIN_MOTOR, HIGH);
    
    u8g.setContrast(LCD_CONTRAST);
    hih_int.init();
    hih_ext.init();

}

void loop()
{
    now = millis();
    hih_int.fetch(now);
    
    if (hih_ext.fetch(now) != NOT_UPDATED) {

      u8g.firstPage();
        do {
        draw();
      } while( u8g.nextPage() );
    }
    
    motor_on = check_signals(hih_int.hum_abs, hih_ext.hum_abs);
    
    digitalWrite(PIN_MOTOR, motor_on ? LOW : HIGH);
       
    digitalWrite(PIN_LED1, ! digitalRead(PIN_LED1));
    DEBUG_PRINTLN(".");
    delay(500);  
}



    
