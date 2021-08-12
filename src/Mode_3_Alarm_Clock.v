/*
 * Version : REV 0.
 *
 * Written By : JU. Y.
 * Supervised By : JU. Y.
 *
 */

module mode_3(OBSERV_MODE,
              CLOCK_50,
              DigitalCrownData,
              ALARM_ALERT_SIG,
              ALARM_OFF_SIG,
              SETTING_INITIATE_SIG,
              SETTING_HOUR_DONE,
              SETTING_MINUTE_DONE,
              SETTING_SECOND_DONE,
              internalTime_H,
              internalTime_M,
              internalTime_S,
              hour__Data_2nd_Digit,
              hour__Data_1st_Digit,
              minuteData_2nd_Digit,
              minuteData_1st_Digit,
              secondData_2nd_Digit,
              secondData_1st_Digit,
              );
    
    parameter hour_DigitalCrown_gap    = 42;    // (1024 / (23+1))
    parameter minNsec_DigitalCrown_gap = 17;    // (1024 / (59+1))
    parameter DC_offset_HOUR           = 8; // total offset = 16
    parameter DC_offset_MINSEC         = 2; // total offset = 4
    parameter STATUS_OFF = 0, STATUS_ON_WAIT = 1, STATUS_ALERT = 2, STATUS_OK2OFF = 3;
    
    reg [2:0]STATUS_REG;
    input OBSERV_MODE, SETTING_INITIATE_SIG, SETTING_HOUR_DONE, SETTING_MINUTE_DONE, SETTING_SECOND_DONE;
    input CLOCK_50;
    input ALARM_OFF_SIG;
    input [9:0]DigitalCrownData;
    input [5:0]internalTime_H, internalTime_M, internalTime_S;
    output reg ALARM_ALERT_SIG;
    output [3:0]hour__Data_2nd_Digit, hour__Data_1st_Digit, minuteData_2nd_Digit, minuteData_1st_Digit, secondData_2nd_Digit, secondData_1st_Digit;
    wire   [5:0]hour__Data_DSP, minuteData_DSP, secondData_DSP;
    wire [5:0]CONVERT_DC_TO_H, CONVERT_DC_TO_MS;
    wire ALARM_ENABLE_WIRE;
    reg ALARM_ENABLE;
    reg isITSettingMode;
    reg [5:0]ALARM_TIME_H, ALARM_TIME_M, ALARM_TIME_S;
    reg ALARAM_TIME_COMPAROR;
    
    assign CONVERT_DC_TO_H  = (DigitalCrownData - DC_offset_HOUR) / hour_DigitalCrown_gap;
    assign CONVERT_DC_TO_MS = (DigitalCrownData - DC_offset_MINSEC) / minNsec_DigitalCrown_gap;
    
    assign hour__Data_DSP = (isITSettingMode) ? CONVERT_DC_TO_H: ALARM_TIME_H;
    assign minuteData_DSP = (SETTING_HOUR_DONE) ? CONVERT_DC_TO_MS: ALARM_TIME_M;
    assign secondData_DSP = (SETTING_MINUTE_DONE) ? CONVERT_DC_TO_MS: ALARM_TIME_S;
    
    assign hour__Data_2nd_Digit = hour__Data_DSP / 10;
    assign hour__Data_1st_Digit = hour__Data_DSP % 10;
    assign minuteData_2nd_Digit = minuteData_DSP / 10;
    assign minuteData_1st_Digit = minuteData_DSP % 10;
    assign secondData_2nd_Digit = secondData_DSP / 10;
    assign secondData_1st_Digit = secondData_DSP % 10;
    
    initial
    begin
        ALARM_ENABLE    = 0;
        ALARM_TIME_H    = 0;
        ALARM_TIME_M    = 0;
        ALARM_TIME_S    = 0;
        ALARM_ALERT_SIG = 0;
        isITSettingMode = 0;
        STATUS_REG      = 0;
    end
    
    always@(posedge SETTING_INITIATE_SIG or
    posedge SETTING_HOUR_DONE or
    posedge SETTING_MINUTE_DONE or
    posedge SETTING_SECOND_DONE)
    begin
        if (SETTING_INITIATE_SIG)
        begin
            isITSettingMode = 1;
            ALARM_TIME_M    = 0;
            ALARM_TIME_S    = 0;
        end
        else if (SETTING_HOUR_DONE)
        begin
            ALARM_TIME_H = CONVERT_DC_TO_H;
        end
        else if (SETTING_MINUTE_DONE)
        begin
            ALARM_TIME_M = CONVERT_DC_TO_MS;
        end
        else if (SETTING_SECOND_DONE)
        begin
            ALARM_TIME_S    = CONVERT_DC_TO_MS;
            isITSettingMode = 0;
        end
    end
        
    always@(posedge CLOCK_50)
    begin // STATUS_REG
        if (STATUS_REG == STATUS_OFF)
        begin
            if (OBSERV_MODE & DigitalCrownData[9] & (~isITSettingMode))
            begin
                STATUS_REG = STATUS_ON_WAIT;
            end
        end
        else if (STATUS_REG == STATUS_ON_WAIT)
        begin
            if (ALARAM_TIME_COMPAROR)
            begin
                STATUS_REG = STATUS_ALERT;
            end
        end
        else if (STATUS_REG == STATUS_ALERT)
            begin
                ALARM_ALERT_SIG = 1;
                if (ALARM_OFF_SIG)
                begin
                    STATUS_REG = STATUS_OK2OFF;
                end
            end
        else if (STATUS_REG == STATUS_OK2OFF)
        begin
            ALARM_ALERT_SIG = 0;
            if (~ALARAM_TIME_COMPAROR)
            begin
                STATUS_REG = STATUS_OFF;
            end
        end
    end
                
    always@(*)
    begin
        if (ALARM_TIME_H == internalTime_H && ALARM_TIME_M == internalTime_M && ALARM_TIME_S == internalTime_S)
        begin
            ALARAM_TIME_COMPAROR = 1;
        end
        else
        begin
            ALARAM_TIME_COMPAROR = 0;
        end
    end
                                
endmodule
// EOF

