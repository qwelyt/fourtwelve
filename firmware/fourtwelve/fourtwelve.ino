//#include "Keyboard.h"
#include "Key.h"

const byte numCols = 12;
const byte numRows = 4;

const byte layers = 4; // Normal, lower, raise, lower+raise
const byte scanRounds = 2;
const byte msDelayBetweenScans = 10;


int cols[numCols] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 16, 15, 14};
int rows[numRows] = {A2, A3, A4, A5};


typedef struct {
  byte row;
  byte col;
  byte val;
} ModPosition;

const ModPosition lower = {3, 4, 1};
const ModPosition raise = {3, 7, 2};
const byte numModifiers = 2;

ModPosition modifiers[numModifiers] = {lower, raise};

byte keys[layers][numRows][numCols] = {
  // 0 Normal
  {
    {   Key::TAB    , Key::Q     , Key::W      , Key::E     , Key::R     , Key::T     , Key::Y      , Key::U     , Key::I     , Key::O    , Key::P      , Key::OBRAKET   }
    , { Key::ESC    , Key::A     , Key::S      , Key::D     , Key::F     , Key::G     , Key::H      , Key::J     , Key::K     , Key::L    , Key::COLON  , Key::QUOTE     }
    , { Key::L_SHFT , Key::Z     , Key::X      , Key::C     , Key::V     , Key::B     , Key::N      , Key::M     , Key::COMMA , Key::DOT  , Key::SLASH  , Key::BACKSPACE }
    , { Key::L_CTRL , Key::NONE  , Key::L_SUPR , Key::L_ALT , MOD::Lower , Key::SPACE , Key::RETURN , MOD::Raise , Key::R_ALT , Key::MENU , Key::NONE   , Key::R_CTRL    }
  }
  // 1 Lower
  , {
    {   Key::GACC   , Key::K1    , Key::K2     , Key::K3    , Key::K4    , Key::K5    , Key::K6     , Key::K7    , Key::K8    , Key::K9   , Key::K0     , Key::NONE      }
    , { Key::ESC    , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_SHFT , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_CTRL , Key::NONE  , Key::L_SUPR , Key::L_ALT , MOD::Lower , Key::SPACE , Key::RETURN , MOD::Raise , Key::R_ALT , Key::MENU , Key::NONE   , Key::R_CTRL    }
  }
  // 2 Raise
  , {
    {   Key::F1     , Key::F2    , Key::F3     , Key::F4    , Key::F5    , Key::F6    , Key::F7     , Key::F8    , Key::F9    , Key::F10  , Key::F11    , Key::F12       }
    , { Key::ESC    , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_SHFT , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_CTRL , Key::NONE  , Key::L_SUPR , Key::L_ALT , MOD::Lower , Key::SPACE , Key::RETURN , MOD::Raise , Key::R_ALT , Key::MENU , Key::NONE   , Key::R_CTRL    }
  }
  // 3 Both
  , {
    {   Key::NONE   , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::ESC    , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_SHFT , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE  , Key::NONE   , Key::NONE  , Key::NONE  , Key::NONE , Key::NONE   , Key::NONE      }
    , { Key::L_CTRL , Key::NONE  , Key::L_SUPR , Key::L_ALT , MOD::Lower , Key::SPACE , Key::RETURN , MOD::Raise , Key::R_ALT , Key::MENU , Key::NONE   , Key::R_CTRL    }
  }
};


bool pressed[scanRounds][numRows][numCols] = {};
bool lastState[numRows][numCols] = {};
bool state[numRows][numCols] = {};
byte codes[numRows][numCols] = {Key::NONE};

const byte keyLimit = 6;
byte keyPlace = 0;
byte keyBuf[keyLimit];
byte meta = 0x0;

/*********************
****    BEGIN!    ****
*********************/

void setup() {
  for (byte b = 0; b < numRows; ++b) {
    setupRow(rows[b]);
  }

  for (byte b = 0; b < numCols; ++b) {
    setupCol(cols[b]);
  }
}

void setupRow(byte pin) {
  pinMode(pin, OUTPUT);
  digitalWrite(pin, HIGH);
}

void setupCol(byte pin) {
  pinMode(pin, INPUT_PULLUP);
}

///////////////////////////


void loop() {
  scan(scanRounds, numRows, numCols, rows, pressed, msDelayBetweenScans);
  readCurrentState(scanRounds, numRows, numCols, pressed, state);

  if (stateChanged(numRows, numCols, state, lastState)) {
    sendState(numRows, numCols, numModifiers, state, keys, (ModPosition *)modifiers);
    saveState(state, lastState, numRows, numCols);
  }
}

//////////
//  Scan
//////////

void scan( byte scanRounds, byte numRows, byte numCols, int *rows, bool *pressed, int msDelayBetweenScans) {
  for (byte scanRound = 0; scanRound < scanRounds; ++scanRound) {
    debounce(pressed, rows, scanRound, numRows, numCols);
    delay(msDelayBetweenScans);
  }
}

void debounce(bool *pressed, int *rows, byte scanRound, byte numRows, byte numCols) {
  for (byte row = 0; row < numRows; ++row) {
    digitalWrite(rows[row], LOW);
    for (byte col = 0; col < numCols; ++col) {
      pressed[(scanRound*numRows+row)*numCols+col] = readPin(cols[col]);
    }
    digitalWrite(rows[row], HIGH);
  }
}

bool readPin(byte pin) {
  if (!digitalRead(pin)) {
    return true;
  }
  return false;
}


//////////
// State
//////////

void readCurrentState(byte scanRounds, byte numRows, byte numCols, bool *pressed, bool *state) {
  for (byte row = 0; row < numRows; ++row) {
    for (byte col = 0; col < numCols; ++col) {
      bool isPressed = true;
      for (byte scanRound = 0; scanRound < scanRounds; ++scanRound) {
        isPressed = isPressed && pressed[(scanRound*numRows+row)*numCols+col];
      }
      state[row*numCols+col] = isPressed;
    }
  }
}

bool stateChanged(byte numRows, byte numCols, bool *currentState, bool *lastState) {
  for (byte row = 0; row < numRows; ++row) {
    for (byte col = 0; col < numCols; ++col) {
      if (lastState[row*numCols+col] != currentState[row*numCols+col]) {
        return true;
      }
    }
  }
  return false;
}

void saveState(bool *currentState, bool *lastState, byte numRows, byte numCols) {
  for (byte row = 0; row < numRows; ++row) {
    for (byte col = 0; col < numCols; ++col) {
      lastState[row*numCols+col] = currentState[row*numCols+col];
    }
  }
}


////////////
//// Key buffer
////////////

void sendState(byte numRows, byte numCols, byte numModifiers, bool *state, byte *keys, ModPosition *modifiers ) {
  byte layer = checkLayer(state, modifiers, numModifiers);

  for (byte row = 0; row < numRows; ++row) {
    for (byte col = 0; col < numCols; ++col) {
    if (state[row*numCols+col] == true) {
        addToBuffer(keys[(layer*numRows+row)*numCols+col]);
      }
    }
  }
}

byte checkLayer(bool *state, ModPosition *modifiers, byte numModifiers, byte numRows, byte numCols) {
  byte layer = 0;
  for (byte modifier = 0; modifier < numModifiers; ++modifier) {
    ModPosition mod = modifiers[modifier];
    layer += state[mod.col*mod.row] == true ? mod.val : 0;
  }
  return layer;
}

void addToBuffer(byte value) {

}


/* TODO:
  //    - send keybuffer
  //    - something...

*/
