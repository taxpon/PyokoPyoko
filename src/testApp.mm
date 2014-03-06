#include "testApp.h"
#include "ofAppGlutWindow.h"

BOOL touched_flag[NUM_ROW][NUM_COL];
int last_touched_rectangle[NUM_FIN][2];
vector<int*> touched_rectangles;

bool interactive_mode = true;
bool locked = false;
int locked_time = 0;


//--------------------------------------------------------------
void testApp::setup(){	

    int window_width = ofGetWidth();
    int window_height = ofGetHeight();
    
    printf("%d, %d\n", window_width, window_height);
    
    // Initialization
    ofBackground(255, 255, 255);
    ofEnableAlphaBlending();
    
    
    // Make network connection
    udpConnect.Create();
    //udpConnect.Connect("192.168.11.4", 22518);
    //udpConnect.Connect("127.0.0.1", 22518);
    
    
    // Production
    //udpConnect.Connect("192.168.0.17", 6100);
    udpConnect.Connect("192.168.2.103", 6100);
    
    // Load Images
    titleImage.loadImage("title.png");
    blockImage.loadImage("block.png");
    btn1.loadImage("Animation1.png");
    btn2.loadImage("clear.png");
    interactive_btn.loadImage("interactive_mode.png");
    draw_btn.loadImage("draw_mode.png");
    
    // Initialization of Variables
    for (int i = 0; i < NUM_ROW; i++) {
        for (int j = 0; j < NUM_COL; j++) {
            touched_flag[i][j] = 0;
        }
    }

}

//--------------------------------------------------------------
void testApp::update(){

    // unlock
    if (locked) {
        int cur_time = ofGetElapsedTimeMillis();
        if( (cur_time - locked_time) > 10000) {
            locked = !locked;
            printf("Contorol unlocked.\n");
        }
        
    }
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    
    // Draw title
    titleImage.draw(0, TITLE_OFFSET_Y);
    
    // Create Grid
    for (int i = 0; i < NUM_ROW; i++) {
        for (int j = 0; j < NUM_COL; j++) {
            
            int xpos;
            int ypos;
            
            ofSetColor(220, 220, 220);

            if(touched_flag[i][j] == true){
                ofSetColor(255, 255, 255);
            }
            
            xpos = OFFSET_X + (CELL_WIDTH  + MARGIN_X) * j;
            ypos = OFFSET_Y + (CELL_WIDTH + MARGIN_Y) * i;
            
            //printf("%d, %d\n", xpos, ypos);
            
            blockImage.draw(xpos, ypos);
            //ofRect(xpos, ypos, CELL_WIDTH, CELL_HEIGHT);
            
            if(interactive_mode){
                touched_flag[i][j] = false;
            }
        }
    }
    
    // Add Btn
    ofSetColor(220, 220, 220);
    btn1.draw(OFFSET_X, OFFSET_Y + (CELL_WIDTH + MARGIN_Y) * 8);
    btn2.draw(OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 4, OFFSET_Y + (CELL_WIDTH + MARGIN_Y) * 8);
    
    if(interactive_mode){
        
        interactive_btn.draw(OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 6, OFFSET_Y + (CELL_WIDTH + MARGIN_Y) * 8);
        
        for (int i = 0; i < NUM_FIN; i++) {
            touched_flag[last_touched_rectangle[i][0]][last_touched_rectangle[i][1]] = false;
        }
    } else {
        draw_btn.draw(OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 6, OFFSET_Y + (CELL_WIDTH + MARGIN_Y) * 8);
    }
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------

void testApp::send_info(){
    
    if(interactive_mode){
        send_interactive_info();
    } else {
        send_draw_info();
    }
}

void testApp::send_interactive_info(){
    string message = serialize_data();
    string reset_message = "s0,0,0,0,0,0,0,0\n";
    
    //printf("%c\n", message);
    cout << message << "," << message.length() << endl;
    int sent = udpConnect.Send(message.c_str(), message.length());
//    usleep(30000);
//    sent = udpConnect.Send(reset_message.c_str(), reset_message.length());
    
}

void testApp::send_draw_info(){
    string message = serialize_data();
    
    //printf("%c\n", message);
    cout << message << "," << message.length() << endl;
    int sent = udpConnect.Send(message.c_str(), message.length());
}



void testApp::send_specific_info(string str){
    
    int sent = udpConnect.Send(str.c_str(), str.length());
    
    locked = true;
    locked_time = ofGetElapsedTimeMillis();
    //printf("Contorol locked.\n");
}

void testApp::send_clear_bits(){
    
    // Send clear information
    string reset_message = "s0,0,0,0,0,0,0,0\n";
    udpConnect.Send(reset_message.c_str(), reset_message.length());
    
    // Clear internal infomation
    for (int i = 0; i < NUM_ROW; i++) {
        for (int j = 0; j < NUM_COL; j++) {
            touched_flag[i][j] = 0;
        }
    }
}

void testApp::toggle_mode(){
    interactive_mode = !interactive_mode;
}


string testApp::serialize_data(){
    
    string serialized_data = "s";
    int send_bits = 0;
    
    for (int i = 0; i < NUM_ROW; i++) {

        send_bits = 0;
        
        for (int j = 0; j < NUM_COL; j++) {

            send_bits += (int)touched_flag[i][j];
            
            if (j != NUM_COL -1) {
                send_bits = send_bits << 1;
            }

            //serialized_data += ofToString((int)touched_flag[i][j],0);
            //printf("%d, %d, %d\n", i, j, send_bits);
        }
        serialized_data += ofToString((int)send_bits,0);
        
        if(i != NUM_ROW -1){
            serialized_data += ",";
        }
    }
    
    return serialized_data;
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){

    if (locked) {
        return;
    }
    
    if ( touch.x < OFFSET_X || touch.x > OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 7 + CELL_WIDTH ||
         touch.y < OFFSET_Y || touch.y > OFFSET_Y + (CELL_HEIGHT  + MARGIN_Y) * 8 + CELL_HEIGHT ) {
        return;
    }
    
    if ( touch.y > OFFSET_Y + (CELL_HEIGHT  + MARGIN_Y) * 7 + CELL_HEIGHT ) {
        
        if (touch.x < (OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 3 + CELL_WIDTH)) {
            send_specific_info("a\n");
        
        } else if (touch.x < (OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 5 + CELL_WIDTH)){
            send_clear_bits();
            
        } else {
            toggle_mode();
        }
        
        return;
    }

    
    printf("%f, %f\n", touch.x, touch.y);
    
    // Check position
    int index_row = (int)((touch.y - OFFSET_Y)/(CELL_WIDTH + MARGIN_Y));
    int index_col = (int)((touch.x - OFFSET_X)/(CELL_WIDTH + MARGIN_X));

    //int touched_rectangle[3] = {10, index_row, index_col};
    
    //touched_rectangles.push_back(touched_rectangle);
    
    // Update Stateus of Touched rectangle
    touched_flag[index_row][index_col] = true;
    
    // Save the touched rectangle index
    last_touched_rectangle[touch.id][0] = index_row;
    last_touched_rectangle[touch.id][1] = index_col;
    
    send_info();
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){

    if (locked) {
        return;
    }
    
    if ( touch.x < OFFSET_X || touch.x > OFFSET_X + (CELL_WIDTH  + MARGIN_X) * 7 + CELL_WIDTH ||
        touch.y < OFFSET_Y || touch.y > OFFSET_Y + (CELL_HEIGHT  + MARGIN_Y) * 8 + CELL_HEIGHT ) {
        return;
    }
    
    printf("move %f, %f\n", touch.x, touch.y);
    int index_row = (int)((touch.y - OFFSET_Y)/(CELL_WIDTH + MARGIN_Y));
    int index_col = (int)((touch.x - OFFSET_X)/(CELL_WIDTH + MARGIN_X));

    touched_flag[index_row][index_col] = true;
    send_info();
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}
