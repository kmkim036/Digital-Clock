module ControllerCircuit(B_Trigger,
                         Clock_50MHz,
                         PotentiometerValue,
                         Module_1_En,
                         Module_2_En,
                         Module_3_En,
                         Module_4_En,
                         Module_5_En,
                         Module_6_En,
                         HEX_MODE,
                         HEX_ENBL,
                         SevenSegMUX_CTRLR,
                         M1_Begin_Sig,
                         M1_Ctrl_Sig,
                         M2_CTRL_SIGS,
                         M3_CTRL_SIGS,
                         M3_AlarmIsDONESIG,
                         M4_CTRL_SIGS,
                         M5_CTRL_SIGS,
                         M5_timerIsDONESIg);
    
    //I/O Configuration
    input B_Trigger, Clock_50MHz;
    input [9:0]PotentiometerValue;
    output [5:0]HEX_MODE, HEX_ENBL;
    output [2:0]SevenSegMUX_CTRLR;
    output Module_1_En, Module_2_En, Module_3_En, Module_4_En, Module_5_En, Module_6_En;
    output reg M1_Begin_Sig;
    output reg [2:0]M1_Ctrl_Sig;
    output reg M2_CTRL_SIGS;	//long
    output reg [4:0]M3_CTRL_SIGS;	//4: Alarm off, 3: settin_initiate, 2:setting_hour_done, 1:setting_min_done, 0:setting_sec_done
    output reg [1:0]M4_CTRL_SIGS;	//1: long, 0: short
    output reg [2:0]M5_CTRL_SIGS; //2: stop, 1 : long, 0 : short
    input M5_timerIsDONESIg,M3_AlarmIsDONESIG;
    
    //x-plane of State Diagram
    parameter Mode1 = 6'b000001; //Clock
    parameter Mode2 = 6'b000010; //Calender
    parameter Mode3 = 6'b000100; //Alarm CLock
    parameter Mode4 = 6'b001000; //Stop watch
    parameter Mode5 = 6'b010000; //Timer
    parameter Mode6 = 6'b100000; //multiClock
    
    
    // y-plane of State diagram
    parameter M_ObservMode        = 0;         //Observation Mode
    parameter M1_SettingMode_Hour = 1;  //hour    setting
    parameter M1_SettingMode_Min  = 2;   //minuite setting
    parameter M1_SettingMode_Sec  = 3;   //second  setting
    parameter M3_SettingMode_Hour = 1, M3_SettingMode_Min = 2, M3_SettingMode_Sec = 3;
    parameter M5_SettingMode_Hour = 1, M5_SettingMode_Min = 2, M5_SettingMode_Sec = 3;
    
    //Control Signals
    //FSM Registers
    reg [5:0] modeStateReg;
    wire[5:0] modeStateReg_NEXT;
    reg [3:0] modeSettingSTATE_Reg;
    
    //Reset Signal Reg
    reg RESET_N;
    
    //Button Edge (Rising & Falling) Detexion
    wire B_Short, B_Long;
    
    assign HEX_MODE          = 0;
    assign HEX_ENBL          = 1;
    assign SevenSegMUX_CTRLR = (modeStateReg == Mode1) ? 1:
 	(modeStateReg == Mode2) ? 2: 
	(modeStateReg == Mode3) ? 3: 
	(modeStateReg == Mode4) ? 4: 
	(modeStateReg == Mode5) ? 5: 
	(modeStateReg == Mode6) ? 6: 
	1;
    //(modeStateReg == Mode) ? :
    
    //Enable Configuration
    assign Module_1_En = modeStateReg[0];
    assign Module_2_En = modeStateReg[1];
    assign Module_3_En = modeStateReg[2];
    assign Module_4_En = modeStateReg[3];
    assign Module_5_En = modeStateReg[4];
    assign Module_6_En = modeStateReg[5];
    
    //Shifting current state to next. Not adding 1, shifted due to shifting requires way short time to do so.
    assign modeStateReg_NEXT[0] = modeStateReg[5];
    assign modeStateReg_NEXT[1] = modeStateReg[0];
    assign modeStateReg_NEXT[2] = modeStateReg[1];
    assign modeStateReg_NEXT[3] = modeStateReg[2];
    assign modeStateReg_NEXT[4] = modeStateReg[3];
    assign modeStateReg_NEXT[5] = modeStateReg[4];
    
    TickGenerator(CLK, Sig_In_TOGGLES, Tick_Out);
    TickGenerator(CLK, Sig_In_TOGGLES, Tick_Out);
    
    B_Length_DETECTOR ButtonLengthDetector(.B_Trigger(B_Trigger),
    .CLOCK_50MHz(Clock_50MHz),
    .B_Short(B_Short),
    .B_Long(B_Long)
    );
    
    //Init.
    initial
    begin
        modeStateReg         = Mode1;
        modeSettingSTATE_Reg = M_ObservMode;
        RESET_N              = 1;
        //M1 CTRL SIGs Init
        M1_Begin_Sig = 0;
        M1_Ctrl_Sig  = 0;
    end
    
    always@(posedge B_Short or posedge B_Long)
    begin
        if (B_Short) //short release
        begin
            //Short input, Mode 1 (Clock)
            if (modeStateReg == Mode1)
            begin
                if (modeSettingSTATE_Reg == M_ObservMode)
                begin
                    //observ. mode -> short button input. Chagne MODE into Mode 2
                    modeStateReg = modeStateReg_NEXT;
                end
                else if (modeSettingSTATE_Reg == M1_SettingMode_Hour)
                begin
                    //setting mode -> short button input. Chagne setting from hour to min
                    modeSettingSTATE_Reg = M1_SettingMode_Min;
                    M1_Ctrl_Sig[2]       = 1;
                end
                    else if (modeSettingSTATE_Reg == M1_SettingMode_Min)
                    begin
                    //setting mode -> short button input. Chagne setting from min to sec
                    modeSettingSTATE_Reg = M1_SettingMode_Sec;
                    M1_Ctrl_Sig[1]       = 1;
                    end
                    else if (modeSettingSTATE_Reg == M1_SettingMode_Sec)
                    begin
                    //setting mode -> short button input. Chagne mode from setting to observ.
                    modeSettingSTATE_Reg = M_ObservMode;
                    M1_Ctrl_Sig[0]       = 1;
                    M1_Begin_Sig         = 0;
                    end
                else
                begin
                    //Error-proofing.
                    modeSettingSTATE_Reg = M_ObservMode;
                    M1_Begin_Sig         = 0;
                    M1_Ctrl_Sig          = 0;
                end
            end
            //Short input, Mode 2 (Calender)
            else if (modeStateReg == Mode2)
            begin
                //observ. mode -> short button input. Chagne MODE into Mode 3
                modeStateReg = modeStateReg_NEXT;
            end
            //Short input, Mode 3 (Alarm Clock)
            else if (modeStateReg == Mode3)
            begin
                if (modeSettingSTATE_Reg == M_ObservMode)
                begin
                    //observ. mode -> short button input. Chagne MODE into Mode 4
                    modeStateReg = modeStateReg_NEXT;
                end
                else if (modeSettingSTATE_Reg == M3_SettingMode_Hour)
                begin
                    //setting mode -> short button input. Chagne setting from hour to min
                    modeSettingSTATE_Reg = M3_SettingMode_Min;
                end
                else if (modeSettingSTATE_Reg == M3_SettingMode_Min)
                begin
                    //setting mode -> short button input. Chagne setting from min to sec
                    modeSettingSTATE_Reg = M3_SettingMode_Sec;
                end
                else if (modeSettingSTATE_Reg == M3_SettingMode_Sec)
                begin
                    //setting mode -> short button input. Chagne mode from setting to observ.
                    modeSettingSTATE_Reg = M_ObservMode;
                end
                else
                begin
                    //Error-proofing.
                    modeSettingSTATE_Reg = M_ObservMode;
                end
            end
            //Short input, Mode 4 (Stop Watch)
            else if (modeStateReg == Mode4)
            begin
                if (PotentiometerValue < 10'b10000_00000)
                begin
                    //observ. mode -> short button input. Chagne MODE into Mode 5
                    modeStateReg = modeStateReg_NEXT;
                end
                else
                begin
                    /* ctrlSig = ~ctrlSig*/
                end
            end
            //Short input, Mode 5 (Timer)
            else if (modeStateReg == Mode5)
            begin
                if (PotentiometerValue < 10'b10000_00000)
                begin
                    //observ. mode -> short button input. Chagne MODE into Mode 6
                    modeStateReg = modeStateReg_NEXT;
                end
                else
                begin
                    if (modeSettingSTATE_Reg == M_ObservMode)
                    begin
                        /*Enable / Disable Signal.*/
                        //Start / Stop Sig. (Operate_Sig = ~Operate_Sig;)
                    end
                    else if (modeSettingSTATE_Reg == M5_SettingMode_Hour)
                    begin
                        modeSettingSTATE_Reg = M5_SettingMode_Min;
                    end
                    else if (modeSettingSTATE_Reg == M5_SettingMode_Min)
                    begin
                        modeSettingSTATE_Reg = M5_SettingMode_Sec;
                    end
                    else if (modeSettingSTATE_Reg == M5_SettingMode_Sec)
                    begin
                        modeSettingSTATE_Reg = M_ObservMode;
                    end
                end
            end
            //Short input, Mode 6 (Dual Clock)
            else if (modeStateReg == Mode6)
            begin
                //observ. mode -> short button input. Chagne MODE into Mode 6
                modeStateReg = modeStateReg_NEXT;
            end
        end
        else if (B_Long) //long one.
        begin
            //Long input, Mode 1 (Clock)
            if (modeStateReg == Mode1)
            begin
                if (modeSettingSTATE_Reg == M_ObservMode)
                begin
                    //observ. mode -> long button input. Chagne MODE into setting from observ.
                    modeSettingSTATE_Reg = M1_SettingMode_Hour;
                    M1_Begin_Sig         = 1;
                    M1_Ctrl_Sig          = 0;
                end
            end
            //Short input, Mode 2 (Calender)
            else if (modeStateReg == Mode2)
            begin
                if (modeSettingSTATE_Reg == M_ObservMode)
                begin
                    //observ. mode -> long button input. Chagne MODE into setting from observ.
                    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                end
            end
            //Short input, Mode 3 (Alarm Clock)
            else if (modeStateReg == Mode3)
            begin
                if (modeSettingSTATE_Reg == M_ObservMode)
                begin
                    //observ. mode -> long button input. Chagne MODE into setting from observ.
                    modeSettingSTATE_Reg = M3_SettingMode_Hour;       
                end
            end
            //Short input, Mode 4 (Stop Watch)
            else if (modeStateReg == Mode4)
            begin
                /*Clear Sig*/
            end
            //Short input, Mode 5 (Timer)
            else if (modeStateReg == Mode5)
            begin
                if (PotentiometerValue < 10'b10000_00000)
                begin
                    //observ. mode -> short button input. Chagne MODE into Mode 6
                    modeStateReg = modeStateReg_NEXT;        
                end
                else
                begin
                end
            end
            //Short input, Mode 6 (Dual Clock)
            else if (modeStateReg == Mode6)
            begin
                //observ. mode -> short button input. Chagne MODE into Mode 6
                modeStateReg = modeStateReg_NEXT;
            end
        end
    end
endmodule
//EOF

