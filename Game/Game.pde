
#include <IOShieldOled.h>


//TODO MAKE ENEMIES WORK xF



const int SysLED = 13;
const int LD1 =  70;     
const int LD2 =  71;     
const int LD3 =  72;
const int LD4 =  73;
const int LD5 =  74;
const int LD6 =  75;
const int LD7 =  76;
const int LD8 =  77;

const int BTN1 = 4;
const int BTN2 = 78;
const int BTN4 = 81;

const byte colorBLACK = 0x00;
const byte colorWHITE = 0xFF;



int BTN1_state = 0;
int BTN2_state = 0;  
int BTN4_state = 0; 

int activeBullets[128][32];
int playerPos[128][32];
int activeEnemies[128][32];
int screenSpace[128][32];

int pPosX = 0;
int pPosY = 0;

int canShoot = 8;








void setup() {

  pinMode(SysLED, OUTPUT);

  pinMode(LD1, OUTPUT);
  pinMode(LD5, OUTPUT); 
  pinMode(LD6, OUTPUT);  
  pinMode(LD7, OUTPUT);  
  pinMode(LD8, OUTPUT); 

  pinMode(BTN1, INPUT);
  pinMode(BTN2, INPUT);
  pinMode(BTN4, INPUT); 
  
  IOShieldOled.begin();  
  //IOShieldOled.setDrawMode(modeSet);
  IOShieldOled.clearBuffer();

  createBarriers();
  createInitialPlayerShip();

  drawScreen();

  IOShieldOled.updateDisplay();
} 

void loop() {


	IOShieldOled.clearBuffer();

	// Read state of buttons
	BTN1_state = digitalRead(BTN1); 
	BTN2_state = digitalRead(BTN2);
	BTN4_state = digitalRead(BTN4);

	if (BTN1_state == HIGH) { digitalWrite(LD5, HIGH);   } 
  	if (BTN1_state == LOW) { digitalWrite(LD5, LOW);   } 
	if (BTN2_state == HIGH) { digitalWrite(LD6, HIGH);   } 
	if (BTN2_state == LOW) { digitalWrite(LD6, LOW);   } 
	if (BTN4_state == HIGH) { digitalWrite(LD8, HIGH);   } 
	if (BTN4_state == LOW) { digitalWrite(LD8, LOW);   } 

	if (BTN1_state == 1) {
		drawPlayerShip(0);
		movePlayer(1);
	}
	if (BTN4_state == 1) {
		drawPlayerShip(0);
		movePlayer(-1);
	}
	if (BTN2_state == 1 && canShoot == 8) {
		canShoot = 0;
		createNewBullet();
	}
	if (canShoot < 8) {
		canShoot++;
	} 

	moveBullet();
	drawBullet();
	drawPlayerShip(1);

	
	drawScreen();
    IOShieldOled.updateDisplay();

    delay(50);                 
  

}





// Draw the Contents of screenSpace
void drawScreen() {

	for (int i = 0; i < 128; i++) {
		for (int j = 0; j < 32; j++) {
			
			IOShieldOled.moveTo(i,j);

			if (screenSpace[i][j] == 1) {
				IOShieldOled.setDrawColor(colorWHITE);
			} else {
				IOShieldOled.setDrawColor(colorBLACK);
			}

			IOShieldOled.drawPixel();

		}
	}
}

// Draw The player ship
void drawPlayerShip(int pixel) {

	screenSpace[pPosX][pPosY] = pixel;
	screenSpace[pPosX + 1][pPosY] = pixel;
    screenSpace[pPosX + 2][pPosY] = pixel;
	screenSpace[pPosX][pPosY + 1] = pixel;
	screenSpace[pPosX][pPosY + 2] = pixel;
    screenSpace[pPosX][pPosY - 1] = pixel;
	screenSpace[pPosX][pPosY - 2] = pixel;
}

void drawBullet() {
	int activeBulletsDebug = 0;
	for (int i = 0; i < 128; i++) {
		for (int j = 0; j < 32; j++) {
			if (activeBullets[i][j] == 1) {
				screenSpace[i][j] = 1;
				screenSpace[i -2][j] = 0;
				screenSpace[i -1][j] = 0;
				activeBulletsDebug = 1;
			}
			
		}
	}

	if (activeBulletsDebug == 1) {
		digitalWrite(LD1, HIGH);
	} else {
		digitalWrite(LD1, LOW);
	}

}

// Draw the Enemies
void drawEnemies() {

	//for (int i = 0; i < 128; i++)

}







// Detect if any bullets hit a target
void detectBulletHits(int x, int y) {

	if (activeEnemies[x][y] == 1 || activeEnemies[x][y + 1] == 1 || activeEnemies[x][y + 1] == 1) {

		activeEnemies[x][y + 1] = 0;
		activeEnemies[x][y] = 0;
		activeEnemies[x][y - 1] = 0;

		deleteEnemy(x,y);

	}

}

void deleteEnemy(int x, int y) {
	screenSpace[x][y] = 0;
	screenSpace[x + 1][y] = 0;
	screenSpace[x - 1][y] = 0;
	screenSpace[x][y + 1] = 0;
	screenSpace[x][y - 1] = 0;
	screenSpace[x + 1][y + 1] = 0;
	screenSpace[x - 1][y - 1] = 0;

}




void movePlayer(int direction) {

	if (direction == 1 && pPosY == 27) {
		return;
	}

	if (direction == 1 && pPosY == 4) {
		return;
	}

	pPosY += direction;

}


// loop through activeBullets and move any bullets 1 step forward
void moveBullet() {

	for (int i = 0; i < 128; i++) {
		for (int j = 0; j < 32; j++) {
			if (activeBullets[i][j] == 1) {

				if (i == 126) {
					activeBullets[i][j] = 0;
					return;
				}
				activeBullets[i + 2][j] = 1;
				activeBullets[i][j] = 0;
				i += 3;
			}
		}
	}



}


// Move Enemies Forward
void moveEnemies() {

}










//Creates the ceiling and the floor
void createBarriers() {
	for (int i = 0; i < 2; i++) {
		for (int j = 0; j < 128; j++) {
			screenSpace[j][i] = 1;
		}
	}
	for (int i = 30; i < 32; i++) {
		for (int j = 0; j < 128; j++) {
			screenSpace[j][i] = 1;
		}
	}
}

void createInitialPlayerShip() {
	pPosX = 20;
	pPosY = 16;
}

void createEnemies() {
	int rand = random(1000);
	if (rand % 33 == 0) {
		activeEnemies[124][random(5,29)] = 1;
	}
}

void createNewBullet() {
	activeBullets[pPosX + 2][pPosY] = 1;
}
