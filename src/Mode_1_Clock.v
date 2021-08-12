/*
 * Version : REV 0.
 *
 * Written By : JU. Y.
 * Supervised By : JU. Y.
 *
 */

module mode_1(Enable,
              CLOCK_50MHz,
              settingTrigger,
              settingSig_3bit,
              DigitalCrownData,
              hour__Data_2nd_Digit,
              hour__Data_1st_Digit,
              minuteData_2nd_Digit,
              minuteData_1st_Digit,
              secondData_2nd_Digit,
              secondData_1st_Digit,
              Day_Passage_Signal,
              internalTime_H,
              internalTime_M,
              internalTime_S,
              itisPM
            );

    parameter hour_DigitalCrown_gap    = 42;    // (1024 / (23+1))
    parameter minNsec_DigitalCrown_gap = 17;    // (1024 / (59+1))
    parameter DC_offset_HOUR           = 8;     // total offset = 16
    parameter DC_offset_MINSEC         = 2;     // total offset = 4
    parameter numberOfTimeData = 3, HOUR_DATA = 2, MIN__DATA = 1, SEC__DATA = 0, WIDTH_OF_TIMEDATA_EACH = 5;

    input Enable, CLOCK_50MHz, settingTrigger;
    input [2:0] settingSig_3bit;
    input [9:0] DigitalCrownData;
    output [3:0] hour__Data_2nd_Digit, hour__Data_1st_Digit, minuteData_2nd_Digit, minuteData_1st_Digit, secondData_2nd_Digit, secondData_1st_Digit;
    output [WIDTH_OF_TIMEDATA_EACH : 0] internalTime_H, internalTime_M, internalTime_S;
    reg [WIDTH_OF_TIMEDATA_EACH : 0] internalTimeData [numberOfTimeData-1 : 0];

    assign internalTime_H = internalTimeData[2];
    assign internalTime_M = internalTimeData[1];
    assign internalTime_S = internalTimeData[0];

    output reg 	 Day_Passage_Signal;
    output reg   itisPM;

    // 1Hz (1pps) clock
    wire OneHertzPulse;

    // 1pps clock genetator control signals
    reg timer_1Hz_Enable;
    reg timer_1Hz_Reset;

    // 12<->24 display type control signal
    reg Disp_Type_Toggle;

    // 24 -> 12 /w AM or PM indicator converted Data
    reg [5:0]hourData_converted2AM_PM_type;

    // 1pps clock generator
    Clock_Generator PulseGen_1Hz(
    .CLOCK(CLOCK_50MHz),
    .RESET_N(timer_1Hz_Reset),
    .internalCounter(/*NC*/),
    .generatedCLOCK(OneHertzPulse),
    .COMPARAND(50_000_000),
    .Enable(timer_1Hz_Enable)
    );

    // 7Seg Displaying Purpose Data Out Pins (6 Digit BCD Sigs)
    wire [5:0]hour__Data_wire;
    assign hour__Data_wire      = (Disp_Type_Toggle) ? hourData_converted2AM_PM_type: internalTimeData[HOUR_DATA];
    assign hour__Data_2nd_Digit = hour__Data_wire / 10;
    assign hour__Data_1st_Digit = hour__Data_wire % 10;
    assign minuteData_2nd_Digit = internalTimeData[MIN__DATA] / 10;
    assign minuteData_1st_Digit = internalTimeData[MIN__DATA] % 10;
    assign secondData_2nd_Digit = internalTimeData[SEC__DATA] / 10;
    assign secondData_1st_Digit = internalTimeData[SEC__DATA] % 10;

    // Changes display type only when mode1 is in displayied status
    always@(Enable)
    begin
        Disp_Type_Toggle <= DigitalCrownData[9];
    end

    // 12<->24 conversion
    always@(*)
    begin
        if (internalTimeData[HOUR_DATA] > 12)
        begin
            hourData_converted2AM_PM_type = internalTimeData[HOUR_DATA] - 12;
            itisPM                        = 1;
        end
        else
        begin
            hourData_converted2AM_PM_type = internalTimeData[HOUR_DATA] - 0;
            itisPM                        = 0;
        end    
    end

    initial
    begin
        Disp_Type_Toggle            = 0;
        Day_Passage_Signal          = 0;
        timer_1Hz_Enable            = 1;
        timer_1Hz_Reset             = 1;
        internalTimeData[SEC__DATA] = 0;
        internalTimeData[MIN__DATA] = 0;
        internalTimeData[HOUR_DATA] = 0;
    end

    always@(posedge settingTrigger or
            posedge settingSig_3bit[2] or
            posedge settingSig_3bit[1] or
            posedge settingSig_3bit[0] or
            posedge OneHertzPulse)
    begin
        if(settingTrigger)
        begin
            if (Enable)
            begin
                timer_1Hz_Enable = 0;
                timer_1Hz_Reset  = 0;
            end
        end
        else if (settingSig_3bit[2])
        begin
            internalTimeData[HOUR_DATA] = (DigitalCrownData - DC_offset_HOUR) / hour_DigitalCrown_gap;
        end
        else if (settingSig_3bit[1])
        begin
            internalTimeData[MIN__DATA] = (DigitalCrownData - DC_offset_MINSEC) / minNsec_DigitalCrown_gap;
        end
        else if (settingSig_3bit[0])
        begin
            internalTimeData[SEC__DATA] = (DigitalCrownData - DC_offset_MINSEC) / minNsec_DigitalCrown_gap;
            timer_1Hz_Reset  = 1;
            timer_1Hz_Enable = 1;
        end
        else if (OneHertzPulse)
        begin
            if (internalTimeData[SEC__DATA] != 59)
            begin
                internalTimeData[SEC__DATA] = internalTimeData[SEC__DATA] + 1;
            end
            else
            begin
                internalTimeData[SEC__DATA] = 0;
                if (internalTimeData[MIN__DATA] ! = 59)
                begin
                    internalTimeData[MIN__DATA] = internalTimeData[MIN__DATA] + 1;
                end
                else
                begin
                    if (internalTimeData[HOUR_DATA] != 23)
                    begin
                        if (Day_Passage_Signal) 
                        begin 
                            Day_Passage_Signal = 0; 
                        end
                        internalTimeData[HOUR_DATA] = internalTimeData[HOUR_DATA] + 1;
                    end
                    else
                    begin
                        internalTimeData[HOUR_DATA] = 0;
                        Day_Passage_Signal          = 1;
                    end
                end
            end
        end
    end

endmodule
// EOF

