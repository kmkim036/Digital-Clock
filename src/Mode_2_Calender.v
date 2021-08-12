/*
 * Version : REV 1.
 *
 * Written By 		: KM. K.
 * Modified By		: JU. Y.
 * Supervised By  : JU. Y.
 *
 */

module mode_2(	En,
              potentiometer_10,
              B_L,
              daysignal,
              year_10,
              year_1,
              month_10,
              month_1,
              day_10,
              day_1);
    // calendar

    parameter S0 = 2'b00,
    S1 = 2'b01,
    S2 = 2'b10,
    S3 = 2'b11,
    year_DigitalCrown_Gap = 1,	// 1024/12
    month_DigitalCrown_Gap = 85,
    day_DigitalCrown_Gap_31 = 33,
    day_DigitalCrown_Gap_30 = 34,
    day_DigitalCrown_Gap_29 = 35,
    day_DigitalCrown_Gap_28 = 36;

    // S0 == normal state S1 == year set S2 == month set S3 == day set
    input En, B_L, daysignal;
    // signal from mode_1, day changing
    input [9:0] potentiometer_10;
    output wire [3:0] year_10, year_1, month_10, month_1, day_10, day_1;
    reg [1:0]state = S0;
    reg leapyear;   // leapyear == 1(year%4 == 0)
    reg [1:0]checkmonth;    // 0 = >31 1 = >30 2 = >28 3 = >29
    reg [4:0]year,month,day;

    initial
    begin
        year  <= 5'b00000;
        month <= 5'b00000;
        day   <= 5'b00000;
    end

    // 2000 <= year <= 2999
    wire En1,En2;

    assign En1 = En & potentiometer_10[9] & B_L;	// reset
    assign En2 = En & (~potentiometer_10[9]) & B_L;	// set

    always@(posedge En2)
    begin
        case(state)
            S0: if (En2) state <= S1; else state <= S0;
            S1: if (En2) state <= S2; else state <= S1;
            S2: if (En2) state <= S3; else state <= S2;
            S3: if (En2) state <= S0; else state <= S3;
        endcase
    end

    always@(En)
    begin
        if (En1)
        begin
            year <= 5'b00000;  
            month <= 5'b00000;  
            day <= 5'b00000;
        end        
        else
        begin
            if (state == S1)	// year set
            begin
            // year = 2000~2999
                year = potentiometer_10 / year_DigitalCrown_Gap;
                if (year % 4 == 0) 
                    leapyear< = 1;
                else 
                    leapyear <= 0;
            end
            else if (state == S2)	// month set
            begin
                month = potentiometer_10 / month_DigitalCrown_Gap;
            end
            else if (state == S3)	// day set  max: 31 or 30 or 29 or 28
            begin
                if(leapyear == 1)	// leapyear
                begin
                    if(month == 2)	// Feb in leapyear
                    begin
                        day = potentiometer_10 / day_DigitalCrown_Gap_29;
                        checkmonth <= 3;
                    end
                    else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
                    begin           
                        day = potentiometer_10 / day_DigitalCrown_Gap_31;
                        checkmonth <= 0;
                    end
                    else	// max 30
                    begin
                        day = potentiometer_10 / day_DigitalCrown_Gap_30;
                        checkmonth <= 1;
                    end
                end
                else					// not leapyear
                begin
                    if(month == 2)	// Feb in ~leapyear
                    begin
                        day = potentiometer_10 / day_DigitalCrown_Gap_28;
                    checkmonth <= 2;
                    end
                    else if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)	// max 31
                    begin
                    day = potentiometer_10 / day_DigitalCrown_Gap_31;
                    checkmonth <= 0;
                    end
                    else	// max 30
                    begin
                    day = potentiometer_10 / day_DigitalCrown_Gap_30;
                    checkmonth <= 1;
                    end
                end
            end
            else if (daysignal)
            begin
                day <= day + 1;
                if(day == 32 && checkmonth == 0)
                begin
                    month <= month + 1;
                    day   <= 1;
                    if (month == 13)
                    begin
                        year  <= year + 1;
                        month <= 1;
                    end
                end
                else if (day == 31 && checkmonth == 1)
                begin
                    month <= month + 1;
                    day   <= 1;
                    if (month == 13)
                    begin
                        year  <= year + 1;
                        month <= 1;
                    end
                end
                else if (day == 29 && checkmonth == 2)
                begin
                    month <= month + 1;
                    day   <= 1;
                    if (month == 13)
                    begin
                        year  <= year + 1;
                        month <= 1;
                    end
                end
                else if (day == 30 && checkmonth == 3)
                begin
                    month <= month + 1;
                    day   <= 1;
                    if (month == 13)
                    begin
                        year  <= year + 1;
                        month <= 1;
                    end
                end
            end
        end
    end
        
    assign year_10  = year / 10;
    assign year_1   = year % 10;
    assign month_10 = month / 10;
    assign month_1  = month % 10;
    assign day_10   = day / 10;
    assign day_1    = day % 10;

endmodule
// EOF

