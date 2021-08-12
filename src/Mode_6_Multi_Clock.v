/*
 * Version : REV 1.
 *
 * Written By 		: KM. K.
 * Modified By 	: JU. Y. (REV 1) -> Replaced T_S with Digital_Crown_Data
 * Supervised By 	: JU. Y.
 *
 */

module mode_6(	En,
              hour,
              DigitalCrownValue,
              hour_10,
              hour_1);
    // multi clock
    
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101, S6 = 3'b110, S7 = 3'b111;

    input [9:0]DigitalCrownValue;
    input En;
    input [4:0]hour;
    output [3:0]hour_10,hour_1;

    wire [4:0]dualhour;
    reg [2:0]state = S0;

    always@(*)
    begin
        if (En)
        begin
            case(DigitalCrownValue / 128)
                0: state = S1;
                1: state = S2;
                2: state = S3;
                3: state = S4;
                4: state = S5;
                5: state = S6;
                6: state = S7;
                7: state = S0;
            endcase
        end
    end

    assign dualhour = (state == S0) ? hour:
    (state == S1) ? ((hour + 23) % 24):
    (state == S2) ? ((hour + 18) % 24):
    (state == S3) ? ((hour + 16) % 24):
    (state == S4) ? ((hour + 15) % 24):
    (state == S5) ? ((hour + 10) % 24):
    (state == S6) ? ((hour + 7)  % 24): ((hour + 2)  % 24);

    /*
    S0: Seoul
    S1: Beijing (pakeng)
    S2: Moscow
    S3: Paris
    S4: London
    S5: NY
    S6: LA
    S7: Sydney
    */

    assign hour_10 = dualhour / 10;
    assign hour_1  = dualhour % 10;

endmodule
// EOF

