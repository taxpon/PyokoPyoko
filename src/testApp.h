#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxNetwork.h"


#define NUM_COL 8
#define NUM_ROW 8

#define CELL_WIDTH 80
#define CELL_HEIGHT 80

#define OFFSET_X 29
#define OFFSET_Y 157

#define TITLE_OFFSET_Y 40

#define MARGIN_X 10
#define MARGIN_Y 10

#define NUM_FIN 5

class testApp : public ofxiOSApp{
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
    
    private:
        void send_info();
        void send_interactive_info();
        void send_draw_info();
        void send_specific_info(string);
        void send_clear_bits();
        void toggle_mode();
        string serialize_data();
    
        ofImage titleImage;
        ofImage blockImage;
        ofImage btn1;
        ofImage btn2;
        ofImage interactive_btn;
        ofImage draw_btn;
    
        ofxUDPManager udpConnect;
        string msgTx, msgRx;
    
        float  counter;
        int connectTime;
        int deltaTime;
        bool weConnected;
    
        bool touched_flag[NUM_ROW][NUM_COL];
};


