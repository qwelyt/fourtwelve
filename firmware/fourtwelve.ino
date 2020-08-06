#include "Keyboard.h"
#include "Key.h"

const byte numCols = 12;
const byte numRows = 4;

const byte layers 4; // Normal, lower, raise, lower+raise
const byte scanRounds = 2;
const byte msDelayBetweenScans = 10;


int cols[numCols] = {2,3,4,5,6,7,8,9,10,16,15,14};
int rows[numRows] = {A2,A3,A4,A5};


struct ModPosition {
    byte row;
    byte col;
    byte val;
};

const ModPosition lower = {3,4,1};
const ModPosition raise = {3,7,2};

uint8_t keys[layers][numRows][numCols] = {
    // 0 Normal
    {
        {   Key::TAB    , Key::Q  , Key::W      , Key::E     , Key::R     , Key::T     , Key::Y      , Key::U     , Key::I     , Key::O    , Key::P     , Key::OBRAKET   }
        , { Key::ESC    , Key::A  , Key::S      , Key::D     , Key::F     , Key::G     , Key::H      , Key::J     , Key::K     , Key::L    , Key::COLON , Key::QUOTE     }
        , { Key::L_SHFT , Key::Z  , Key::X      , Key::C     , Key::V     , Key::B     , Key::N      , Key::M     , Key::COMMA , Key::DOT  , Key::SLASH , Key::BACKSPACE }
        , { Key::L_CTRL , Key::NONE  , Key::L_SUPR , Key::L_ALT , Mod::Lower , Key::SPACE , Key::RETURN , Mod::Raise , Key::R_ALT , Key::MENU , Key::NONE   , Key::R_CTRL    }
    }
    // 1 Lower
    , {
        {   Key::GACC     , Key::K1 , Key::K2     , Key::K3    , Key::K4    , Key::K5    , Key::K6     , Key::K7    , Key::K8    , Key::K9   , Key:K0     , Key::??? }
        , { Key::ESC }
        , { Key::L_SHFT }
        , { Key::L_CTRL , Key::?  , Key::L_SUPR , Key::L_ALT , Mod::Lower , Key::SPACE , Key::RETURN , Mod::Raise , Key::R_ALT , Key::MENU , Key::???   , Key::R_CTRL    }
    }
    // 2 Raise
    , {
        {   Key::F1     , Key::F2 , Key::F3     , Key::F4    , Key::F5    , Key::F6     , Key::F7    , Key::F8    , Key::F9   , Key:F10 , Key::F11 , Key::F12 }
        , { Key::ESC }
        , { Key::L_SHFT }
        , { Key::L_CTRL , Key::?  , Key::L_SUPR , Key::L_ALT , Mod::Lower , Key::SPACE , Key::RETURN , Mod::Raise , Key::R_ALT , Key::MENU , Key::???   , Key::R_CTRL    }
    }
    // 3 Both
    , {
        {}
        , { Key::ESC }
        , { Key::L_SHFT }
        , { Key::L_CTRL , Key::?  , Key::L_SUPR , Key::L_ALT , Mod::Lower , Key::SPACE , Key::RETURN , Mod::Raise , Key::R_ALT , Key::MENU , Key::???   , Key::R_CTRL    }
    }
};


bool pressed[scanRounds][numRows][numCols] = {};
bool lastState[numRows][numCols] = {};
bool state[numRows][numCols] = {};
uint8_t codes[numRows][numCols] = {Key::NON;

/*********************
****    BEGIN!    ****
*********************/

void setup() {
	for(byte b = 0; b < numRows; ++b) {
		setupRow(row[b]);
	}

	for(byte b = 0; b < numCols; ++b) {
		setupCol(cols[b]);
	}
}

void setupRow(byte pin) {
	pinMode(pin, OUTPUT);
	digitileWrite(pin, HIGH);
}

void setupCol(byte pin) {
	pinMode(pin, INPUT_PULLUP);
}

///////////////////////////


void loop() {
	scan();
	if(stateChanged()){
		buildState();
		send();
		save();
	}
}

//////////
//  Scan
//////////

void scan() {
	for(byte b = 0; b < scanRounds; ++b) {
		debounce(b, &pressed);
		delay(msDelayBetweenScans);
	}
	readState(&state);
}

void debounce(byte scanRound, bool *pressed) {
	for(byte row = 0; row < numRows; ++row) {
		digitalWrite(rows[row], LOW);
		for(byte col = 0; col < numCols; ++col) {
			pressed[scanRound][row][col] = readPin(cols[col]);
		}
		digitalWrite(rows[row], HIGH);
	}
}

bool readPin(byte pin) {
	if(!digitalRead(pin)) {
		return true;
	}
	return false;
}

void readState(bool *state) {
	for(byte row = 0; row < numRows; ++row) {
		for(byte col = 0; col < numCols; ++col) {
			bool isPressed = true;
			for(byte scanRound = 0; scanRound < scanRounds; ++scanRound) {
				isPressed = isPressed && pressed[scanRound][row][col];
			}
			state[row][col] = isPressed;
		}
	}
}

//////////
// State
//////////

bool stateChanged(bool lastState[numRows][numCols], bool currentState[numRows][numCols]) {
	for(byte row=0; row < numRows; ++row){
		for(byte col=0; col < numCols; ++col){
			if(lastState[row][col] != currentState[row][col]) {
				return true;
			}
		}
	}
	return false;
}

void saveState(bool state[numRows][numCols]) {
	for(byte row=0; row < numRows; ++row){
		for(byte col=0; col < numCols; ++col){
			lastState[row][col] = state[row][col];
		}
	}
}
