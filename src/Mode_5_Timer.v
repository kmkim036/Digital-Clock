/*
 * Version : REV 1.
 *
 * Written By 		: KM. K.
 * Modified By 	: JU. Y.
 * Supervised By 	: JU. Y.
 *
 */

module mode_5(clk_50MHz,
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
              signal);
    //timer
    
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100;
    parameter minNsec_DigitalCrown_gap = 17, sechun_DigitalCrown_Gap = 10;
    
    //S0: normal state, timer stop. S1: timer start. S2: sechun set. S3: sec set. S3: min set
    input[9:0] potentiometer_10;
    input B_S, B_L, clk_50MHz, En, stopsignal;  //B_S == Timer stop/start B_L == timer reset
    
    //while timer works(S1), you cannot set the time again. you only can set time in stop mode
    output reg signal = 0;	//timer end signal
    output wire [3:0] sechun_10,sechun_1,sec_10,sec_1,min_10,min_1;
    reg [6:0] sechun = 0,sec = 0,min = 0;
    reg [25:0] sechun_counter;
    reg [2:0] state;
    integer i, j;
    
    wire En1, En2,En3;
    //reset set timer startstop
    
    assign En1 = En & B_L & potentiometer_10[9];	//reset
    assign En2 = En & B_S & potentiometer_10[9];	//start/stop
    assign En3 = En & B_L & (~potentiometer_10[9]);	//set
    
    always@(posedge En2 or posedge En3)
    begin
        case(state)
            S0: if (En2) state <= S1; else if (En3) state <= S2; else state <= S0;
            S1: if (En2) state <= S0; else state <= S1;
            S2: if (En3) state <= S3; else state <= S2;
            S3: if (En3) state <= S4; else state <= S3;
            S4: if (En3) state <= S0; else state <= S4;
        endcase
    end
    
    always@(posedge clk_50MHz or posedge En1 or posedge stopsignal)
    begin
        if (stopsignal)
        begin
            signal = 0;
        end
        else if (En1)
        begin
            sechun_counter <= 0;
            sechun         <= 0;
            sec            <= 0;
            min            <= 0;
        end
        else
        begin
            if (state == S0)	//stop
            begin
                sechun_counter <= sechun_counter;
                signal = 0;
            end
            else if (state == S1)	//start(restart)
            begin
                sechun_counter <= sechun_counter + 1;
                if (sechun_counter == 26'd500000)
                begin
                    sechun_counter <= 0;
                    sechun         <= sechun - 1;
                    if (sechun == -1)
                    begin
                        if (min == 0&&sec == 0)
                        begin
                            sechun <= 0;
                            signal = 1;
                        end
                        else
                        begin
                            sechun <= 99;
                            sec    <= sec - 1;
                        end
                    end
                    if (sec == -1)
                        begin
                            if (min == 0)
                                sec <= 0;
                            else
                            begin
                                sec <= 59;
                                min <= min - 1;
                            end
                        end
                    if (min == -1)
                        min <= 0;
                end
            end
            else if (state == S2)	//sechun set
            begin
                sechun = potentiometer_10 / sechun_DigitalCrown_Gap;
            end
            else if (state == S3)	//sec set
            begin
                sec = potentiometer_10 / minNsec_DigitalCrown_gap;
            end
            else if (state == S4)	//min set
            begin
                min = potentiometer_10 / minNsec_DigitalCrown_gap;
            end
        end
    end
            
    assign sechun_10  = sechun / 10;
    assign sechun_1	  = sechun % 10;
    assign sec_10	  = sec	/ 10;
    assign sec_1	  = sec	% 10;
    assign min_10	  = min	/ 10;
    assign min_1	  = min	% 10;
    
endmodule
//EOF

