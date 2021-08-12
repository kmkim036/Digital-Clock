module FinalProj(CLOCK_50,
                 KEY,
                 GPIO_0,
                 LEDR,
                 HEX0,
                 HEX1,
                 HEX2,
                 HEX3,
                 HEX4,
                 HEX5);
    
    input CLOCK_50;
    input [1:0]KEY;
    input [9:0]GPIO_0;
    output [9:0]LEDR;
    output [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [3:0]HEX0_DATA, HEX1_DATA, HEX2_DATA, HEX3_DATA, HEX4_DATA, HEX5_DATA;
    wire [5:0]HEX_MODE, HEX_ENBL;
    
    FinalProj_Inside DCLK_Intnl(
    .CLOCK_50(CLOCK_50),
    .B_Trigger(!KEY[0]),
    // .B_Long_(!KEY[1]),
    .DIGITAL_CROWN_DATA(GPIO_0),
    .HEX0_DATA(HEX0_DATA),
    .HEX1_DATA(HEX1_DATA),
    .HEX2_DATA(HEX2_DATA),
    .HEX3_DATA(HEX3_DATA),
    .HEX4_DATA(HEX4_DATA),
    .HEX5_DATA(HEX5_DATA),
    .HEX_MODE(HEX_MODE),
    .HEX_ENBL(HEX_ENBL)
    );
    
    assign LEDR = GPIO_0;
    /*
     B_Length_DETECTOR(!KEY, CLOCK_50, B_Short, B_Long);
     reg reg0, reg1;
     wire B_Short, B_Long;
     initial
     begin
     reg0 = 0;
     reg1 = 0;
     end
     
     always@(posedge B_Long)
     begin
     reg1 = !reg1;
     end
     
     always@(posedge B_Short)
     begin
     reg0 = !reg0;
     end
     
     assign LEDR[0] = reg0;
     assign LEDR[1] = reg1;
    */
    
    sevenSegDecoder SSD0(
    .data(HEX0_DATA), 
    .HEX(HEX0), 
    .Enable(HEX_ENBL[0]), 
    .Mode(HEX_MODE[0])
    );

    sevenSegDecoder SSD1(
    .data(HEX1_DATA), 
    .HEX(HEX1), 
    .Enable(HEX_ENBL[1]), 
    .Mode(HEX_MODE[1])
    );

    sevenSegDecoder SSD2(
    .data(HEX2_DATA), 
    .HEX(HEX2), 
    .Enable(HEX_ENBL[2]), 
    .Mode(HEX_MODE[2])
    );

    sevenSegDecoder SSD3(
    .data(HEX3_DATA), 
    .HEX(HEX3), 
    .Enable(HEX_ENBL[3]), 
    .Mode(HEX_MODE[3])
    );

    sevenSegDecoder SSD4(
    .data(HEX4_DATA), 
    .HEX(HEX4), 
    .Enable(HEX_ENBL[4]), 
    .Mode(HEX_MODE[4])
    );

    sevenSegDecoder SSD5(
    .data(HEX5_DATA), 
    .HEX(HEX5), 
    .Enable(HEX_ENBL[5]), 
    .Mode(HEX_MODE[5])
    );

endmodule
    
module FinalProj_Inside(CLOCK_50,
                        B_Trigger,
                        DIGITAL_CROWN_DATA,
                        HEX0_DATA, 
                        HEX1_DATA, 
                        HEX2_DATA, 
                        HEX3_DATA, 
                        HEX4_DATA, 
                        HEX5_DATA,
                        HEX_MODE, 
                        HEX_ENBL);
        
    input CLOCK_50, B_Trigger;
    input [9:0]DIGITAL_CROWN_DATA;
    output [3:0]HEX0_DATA, HEX1_DATA, HEX2_DATA, HEX3_DATA, HEX4_DATA, HEX5_DATA;
    output wire [5:0]HEX_MODE, HEX_ENBL;
    wire LEDR_CTRL; // <- CHECK
    wire moduleEnables[6:1];
    wire [5:0]internalTime[2:0];
    wire [3:0]M1_CTRL_SIGS;
    wire [0:0]M2_CTRL_SIGS;
    wire [4:0]M3_CTRL_SIGS;
    wire [1:0]M4_CTRL_SIGS;
    wire [2:0]M5_CTRL_SIGS;
    wire [3:0]HEX0_wire[6:1];
    wire [3:0]HEX1_wire[6:1];
    wire [3:0]HEX2_wire[6:1];
    wire [3:0]HEX3_wire[6:1];
    wire [3:0]HEX4_wire[6:1];
    wire [3:0]HEX5_wire[6:1];
    wire [3:0]ALARM_DSP[5:0];   // for each seven segs.
    wire [3:0]TIMER_DSP[5:0];
    wire datePassageSig, M3_AlarmIsDONESIG;
    wire M5_timerIsDONESIg;
    wire [2:0]SevenSegMUX_CTRLR;
    
    ControllerCircuit CTRL(
    .B_Trigger(B_Trigger),
    .Clock_50MHz(CLOCK_50),
    .Module_1_En(moduleEnables[1]),
    .Module_2_En(moduleEnables[2]),
    .Module_3_En(moduleEnables[3]),
    .Module_4_En(moduleEnables[4]),
    .Module_5_En(moduleEnables[5]),
    .Module_6_En(moduleEnables[6]),
    .HEX_MODE(HEX_MODE),
    .HEX_ENBL(HEX_ENBL),
    .SevenSegMUX_CTRLR(SevenSegMUX_CTRLR),
    .M1_Begin_Sig(M1_CTRL_SIGS[3]),
    .M1_Ctrl_Sig(M1_CTRL_SIGS[2:0]),
    .M2_CTRL_SIGS(M2_CTRL_SIGS),
    .M3_CTRL_SIGS(M3_CTRL_SIGS),
    .M3_AlarmIsDONESIG(M3_AlarmIsDONESIG),
    .M4_CTRL_SIGS(M4_CTRL_SIGS),
    .M5_CTRL_SIGS(M5_CTRL_SIGS),
    .M5_timerIsDONESIg(M5_timerIsDONESIg),
    );
    
    assign HEX0_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[0]:
    (SevenSegMUX_CTRLR == 1) ? HEX0_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX0_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX0_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX0_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX0_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX0_wire[1]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[0]: 4'bxxxx;
    
    assign HEX1_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[1]:
    (SevenSegMUX_CTRLR == 1) ? HEX1_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX1_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX1_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX1_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX1_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX1_wire[1]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[1]: 4'bxxxx;
    
    assign HEX2_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[2]:
    (SevenSegMUX_CTRLR == 1) ? HEX2_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX2_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX2_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX2_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX2_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX2_wire[1]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[2]: 4'bxxxx;
    
    assign HEX3_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[3]:
    (SevenSegMUX_CTRLR == 1) ? HEX3_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX3_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX3_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX3_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX3_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX3_wire[1]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[3]: 4'bxxxx;
    
    assign HEX4_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[4]:
    (SevenSegMUX_CTRLR == 1) ? HEX4_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX4_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX4_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX4_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX4_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX4_wire[6]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[4]: 4'bxxxx;
    
    assign HEX5_DATA = (SevenSegMUX_CTRLR == 0) ? ALARM_DSP[5]:
    (SevenSegMUX_CTRLR == 1) ? HEX5_wire[1]:
    (SevenSegMUX_CTRLR == 2) ? HEX5_wire[2]:
    (SevenSegMUX_CTRLR == 3) ? HEX5_wire[3]:
    (SevenSegMUX_CTRLR == 4) ? HEX5_wire[4]:
    (SevenSegMUX_CTRLR == 5) ? HEX5_wire[5]:
    (SevenSegMUX_CTRLR == 6) ? HEX5_wire[6]:
    (SevenSegMUX_CTRLR == 7) ? TIMER_DSP[5]: 4'bxxxx;
    
    mode_1 AVRG_CLK(	
    .Enable(moduleEnables[1]),
    .CLOCK_50MHz(CLOCK_50),
    .settingTrigger(M1_CTRL_SIGS[3]),
    .settingSig_3bit(M1_CTRL_SIGS[2:0]),
    .DigitalCrownData(DIGITAL_CROWN_DATA),
    .hour__Data_2nd_Digit(HEX5_wire[1]),
    .hour__Data_1st_Digit(HEX4_wire[1]),
    .minuteData_2nd_Digit(HEX3_wire[1]),
    .minuteData_1st_Digit(HEX2_wire[1]),
    .secondData_2nd_Digit(HEX1_wire[1]),
    .secondData_1st_Digit(HEX0_wire[1]),
    .Day_Passage_Signal(datePassageSig),
    .internalTime_H(internalTime[2]),
    .internalTime_M(internalTime[1]),
    .internalTime_S(internalTime[0]),
    .itisPM()
    ); // Average Clock
    
    /*
    input Enable, CLOCK_50MHz, settingTrigger;
    input [2:0] settingSig_3bit;
    input [9:0] DigitalCrownData;
    output [3:0] hour__Data_2nd_Digit, hour__Data_1st_Digit, minuteData_2nd_Digit, minuteData_1st_Digit, secondData_2nd_Digit, secondData_1st_Digit;
    output reg Day_Passage_Signal;
    */
        
    mode_2 CALENDAR(	
    .En(moduleEnables[2]),
    .potentiometer_10(DIGITAL_CROWN_DATA),
    .B_L(M2_CTRL_SIGS),
    .daysignal(datePassageSig),
    .year_10(HEX5_wire[2]),
    .year_1(HEX4_wire[2]),
    .month_10(HEX3_wire[2]),
    .month_1(HEX2_wire[2]),
    .day_10(HEX1_wire[2]),
    .day_1(HEX0_wire[2])
    );
    
    /*
    input En, potentiometer_1, B_S, B_L, daysignal;
    //signal from mode_1, day changing
    input [9:0] potentiometer_10;         
    output wire [3:0] year_10, year_1, month_10, month_1, day_10, day_1;
    */
    
    mode_3 ALARM(	
    .OBSERV_MODE(moduleEnables[3]),
    .CLOCK_50(CLOCK_50),
    .DigitalCrownData(DIGITAL_CROWN_DATA),
    .ALARM_ALERT_SIG(),
    .ALARM_OFF_SIG(),
    .SETTING_INITIATE_SIG(),
    .SETTING_HOUR_DONE(),
    .SETTING_MINUTE_DONE(),
    .SETTING_SECOND_DONE(),
    .internalTime_H(internalTime[2]),
    .internalTime_M(internalTime[1]),
    .internalTime_S(internalTime[0]),
    .hour__Data_2nd_Digit(HEX5_wire[3]),
    .hour__Data_1st_Digit(HEX4_wire[3]),
    .minuteData_2nd_Digit(HEX3_wire[3]),
    .minuteData_1st_Digit(HEX2_wire[3]),
    .secondData_2nd_Digit(HEX1_wire[3]),
    .secondData_1st_Digit(HEX0_wire[3])
    );
    
    /*
    input OBSERV_MODE, SETTING_INITIATE_SIG, SETTING_HOUR_DONE, SETTING_MINUTE_DONE, SETTING_SECOND_DONE;
    input CLOCK_50;
    input ALARM_OFF_SIG;
    input [9:0]DigitalCrownData;
    input [5:0]internalTime_H, internalTime_M, internalTime_S;
    output reg ALARM_ALERT_SIG;
    output [3:0]hour__Data_2nd_Digit, hour__Data_1st_Digit, minuteData_2nd_Digit, minuteData_1st_Digit, secondData_2nd_Digit, secondData_1st_Digit;
    */
    
    mode_4 STOPWATCH(	
    .clk_50MHz(CLOCK_50),
    .En(moduleEnables[4]),
    .B_S(),
    .B_L(),
    .sechun_10(HEX5_wire[4]),
    .sechun_1(HEX4_wire[4]),
    .sec_10(HEX3_wire[4]),
    .sec_1(HEX2_wire[4]),
    .min_10(HEX1_wire[4]),
    .min_1(HEX0_wire[4])
    );
    
    /*
    input clk_50MHz, En, potentiometer_1, B_S, B_L;	
    //B_S == Button_short, B_L == Button_long, potentiometer_1 == potentiometer from control circuit 
    output wire [3:0] sechun_10, sechun_1, sec_10, sec_1, min_10, min_1;
    */
    
    mode_5 TIMER(
    .clk_50MHz(CLOCK_50),
    .En(moduleEnables[5]),
    .potentiometer_10(DIGITAL_CROWN_DATA),
    .B_S(M5_CTRL_SIGS[0]),
    .B_L(M5_CTRL_SIGS[1]),
    .sechun_10(HEX5_wire[5]),
    .sechun_1(HEX4_wire[5]),
    .sec_10(HEX3_wire[5]),
    .sec_1(HEX2_wire[5]),
    .min_10(HEX1_wire[5]),
    .min_1(HEX0_wire[5]),
    .stopsignal(M5_CTRL_SIGS[2]),
    .signal(M5_timerIsDONESIg)
    );
    // timer
    
    /*
        clk_50MHz,
        En,
        potentiometer_10,
        B_S,
        B_L,
        stopsignal,
        sechun_10,
        sechun_1,
        sec_10,
        sec_1,
        min_10,
        min_1,
        signal
    */
    
    
    /*
        parameter S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100,
        MAXVALUE = 10'b1111111100,
        MINVALUE = 10'b0011111111;
        //S0: normal state, timer stop. S1: timer start. S2: sechun set. S3: sec set. S3: min set
        input[9:0] potentiometer_10;
        input B_S, B_L, clk_50MHz, En, potentiometer_1;
        //B_S == Timer stop/start B_L == timer reset
        
        //while timer works(S1), you cannot set the time again. you only can set time in stop mode
        output reg signal = 0;	//timer end signal
        output wire [3:0] sechun_10,sechun_1,sec_10,sec_1,min_10,min_1;
    */
    
    
    mode_6 MULT_CLK(	
    .En(moduleEnables[6]),
    .DigitalCrownValue(DIGITAL_CROWN_DATA),
    .hour(internalTime[2][4:0]),
    .hour_10(HEX5_wire[6]),
    .hour_1(HEX4_wire[6])
    );
    
    /*
    input T_S,En;
    input [4:0]hour;
    input [5:0]min;
    input [5:0]sec;
    output [3:0]hour_10,hour_1,min_10,min_1,sec_10,sec_1;
    */

endmodule
// EOF

