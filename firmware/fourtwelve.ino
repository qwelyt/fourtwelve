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
        {   Key::TAB    , Key::Q , Key::W , Key::E , Key::R , Key::T , Key::Y , Key::U , Key::I     , Key::O   , Key::P     , Key::OBRAKET  }
        , { Key:ESC     , Key::A , Key::S , Key::D , Key::F , Key::G , Key::H , Key::J , Key::K     , Key::L   , Key::COLON , Key::QUOTE    }
        , { Key::L_SHFT , Key::Z , Key::X , Key::C , Key::V , Key::B , Key::N , Key::M , Key::COMMA , Key::DOT , Key::SLASH , Key:BACKSPACE }
        , { Key::L_CTRL , Key::? , Key::L_SUPR , Key::L_ALT , Mod::Lower , Key::SPACE , Key::RETURN , Mod::Raise , Key::R_ALT , }
    }
    // 1 Lower
    , {
        {}
        , {}
        , {}
        , {}
    }
    // Raise
    , {
        {}
        , {}
        , {}
        , {}
    }
    // Both
    , {
        {}
        , {}
        , {}
        , {}
    }
};


/*********************
****    BEGIN!    ****
*********************/

void setup(){
}


void loop(){
}

