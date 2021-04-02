/*
 * Version : REV 3.
 *
 * Written By 		: KM. K.
 * Modified By 	: JU. Y.
 * Supervised By 	: JU. Y.
 *
 */

module mode_4(clk_50MHz,
              En,
              B_S,
              B_L,
              sechun_10,
              sechun_1,
              sec_10,
              sec_1,
              min_10,
              min_1);
    //stopwatch
    
    parameter S0 = 1'b0, S1 = 1'b1;
    
    input clk_50MHz,
    En,
    B_S,
    B_L;	//B_S == Button_short, B_L == Button_long, potentiometer_1 == potentiometer from control circuit
    
    output wire [3:0] sechun_10,
    sechun_1,
    sec_10,
    sec_1,
    min_10,
    min_1;
    
    reg [25:0] sechun_counter = 0;
    reg [6:0]  sechun = 0,
    sec = 0,
    min = 0;
    reg state = S0;
    wire En1, En2;

    assign En1 = En & B_L;	//reset
    assign En2 = En & B_S;	//stop/start
    
    always@(posedge En2)
    begin
        case(state)
            S0: if (En2) state = S1; else state = S0;
            S1: if (En2) state = S0; else state = S1;
        endcase
    end
    
    
    always@(posedge clk_50MHz or posedge En1)
    begin
        if (En1)
        begin
            sechun_counter <= 0;
            sechun         <= 0;
            sec            <= 0;
            min            <= 0;
        end
        else //can work in En == 0 state
        begin
            if (state == S0)	//stop
            begin
                sechun_counter <= sechun_counter;
            end
            else if (state == S1)				//restart
            begin
                sechun_counter <= sechun_counter+1;
                if (sechun_counter == 26'd500000)
                begin
                    sechun_counter <= 0;
                    sechun         <= sechun+1;
                    if (sechun == 100)
                    begin
                        sechun <= 0;
                        sec    <= sec+1;
                    end
                    if (sec == 60)
                    begin
                        sec <= 0;
                        min <= min+1;
                    end
                    if (min == 100)
                    begin
                        sechun <= 0;
                        sec    <= 0;
                        min    <= 0;
                    end
                end
            end
        end
    end
    
    assign sechun_10	 = sechun / 10;
    assign sechun_1	  = sechun % 10;
    assign sec_10		   = sec		/ 10;
    assign sec_1		    = sec		% 10;
    assign min_10		   = min		/ 10;
    assign min_1		    = min		% 10;

endmodule
//EOF

