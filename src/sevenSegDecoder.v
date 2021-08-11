module sevenSegDecoder(data,
                       HEX,
                       Enable,
                       Mode);

    // 0123456
    parameter SEG_0 = 7'b0000001,
    SEG_1 = 7'b1001111,
    SEG_2 = 7'b0010010,
    SEG_3 = 7'b0000110,
    SEG_4 = 7'b1001100,
    SEG_5 = 7'b0100100,
    SEG_6 = 7'b0100000,
    SEG_7 = 7'b0001101,
    SEG_8 = 7'b0000000,
    SEG_9 = 7'b0000100,
    SEG_A = 7'b0001000,
    SEG_b = 7'b1100000,
    SEG_C = 7'b0110001,
    SEG_d = 7'b1000010,
    SEG_E = 7'b0110000,
    SEG_F = 7'b0111000,
    SEG_Off = 7'b1111111,    
    SEG_g = 7'b0000100, /*Same with number 9*/
    SEG_H = 7'b1001000,
    SEG_i = 7'b1101111,
    SEG_J = 7'b0000111,
    SEG_L = 7'b1110001,
    SEG_n = 7'b1101010,
    SEG_o = 7'b1100010,
    SEG_P = 7'b0011000,
    SEG_q = 7'b0001100,
    SEG_r = 7'b1111010,
    SEG_S = 7'b0100100,/*Same with number 5*/
    SEG_t = 7'b1110000,
    SEG_u = 7'b1100011,
    SEG_Y = 7'b1000100,
    SEG_hyphen = 7'b1111110,
    SEG__ = 7'b1110111;
    
    parameter DAT_0 = 4'b0000,
    DAT_1 = 4'b0001,
    DAT_2 = 4'b0010,
    DAT_3 = 4'b0011,
    DAT_4 = 4'b0100,
    DAT_5 = 4'b0101,
    DAT_6 = 4'b0110,
    DAT_7 = 4'b0111,
    DAT_8 = 4'b1000,
    DAT_9 = 4'b1001,
    DAT_A = 4'b1010,
    DAT_b = 4'b1011,
    DAT_C = 4'b1100,
    DAT_d = 4'b1101,
    DAT_E = 4'b1110,
    DAT_F = 4'b1111,
    DAT_g = 4'b0000,
    DAT_H = 4'b0001,
    DAT_i = 4'b0010,
    DAT_J = 4'b0011,
    DAT_L = 4'b0100,
    DAT_n = 4'b0101,
    DAT_o = 4'b0110,
    DAT_P = 4'b0111,
    DAT_q = 4'b1000,
    DAT_r = 4'b1001,
    DAT_S = 4'b1010,
    DAT_t = 4'b1011,
    DAT_u = 4'b1100,
    DAT_Y = 4'b1101,
    DAT_hyphen = 4'b1110,
    DAT__ = 4'b1111;
    
    input [3:0] data;
    input Enable, Mode; //Enable turns on / off 7Seg Disp when it is HIGH. Mode changes from/to HEXADECIMAL(0~F)(1) to ALPHABETS(H~u)(0)
    output [6:0] HEX;
    wire [6:0]HEX_Wire, HEX_Wire_1, HEX_Wire_2;
    
    assign HEX_Wire_1 = (data == DAT_0) ? SEG_0:
    (data == DAT_1) ? SEG_1:
    (data == DAT_2) ? SEG_2:
    (data == DAT_3) ? SEG_3:
    (data == DAT_4) ? SEG_4:
    (data == DAT_5) ? SEG_5:
    (data == DAT_6) ? SEG_6:
    (data == DAT_7) ? SEG_7:
    (data == DAT_8) ? SEG_8:
    (data == DAT_9) ? SEG_9:
    (data == DAT_A) ? SEG_A:
    (data == DAT_b) ? SEG_b:
    (data == DAT_C) ? SEG_C:
    (data == DAT_d) ? SEG_d:
    (data == DAT_E) ? SEG_E:
    (data == DAT_F) ? SEG_F: SEG_Off;
    
    assign HEX_Wire_2 = (data == DAT_g) ? SEG_g:
    (data == DAT_H) ? SEG_H:
    (data == DAT_i) ? SEG_i:
    (data == DAT_J) ? SEG_J:
    (data == DAT_L) ? SEG_L:
    (data == DAT_n) ? SEG_n:
    (data == DAT_o) ? SEG_o:
    (data == DAT_P) ? SEG_P:
    (data == DAT_q) ? SEG_q:
    (data == DAT_r) ? SEG_r:
    (data == DAT_S) ? SEG_S:
    (data == DAT_t) ? SEG_t:
    (data == DAT_u) ? SEG_u:
    (data == DAT_Y) ? SEG_Y:
    (data == DAT_hyphen) ? SEG_hyphen:
    (data == DAT__) ? SEG__: SEG_Off;
    
    
    assign HEX_Wire = (Mode) ? HEX_Wire_2: HEX_Wire_1;
    
    assign HEX[0] = (Enable) ? HEX_Wire[6]: 1'b1;
    assign HEX[1] = (Enable) ? HEX_Wire[5]: 1'b1;
    assign HEX[2] = (Enable) ? HEX_Wire[4]: 1'b1;
    assign HEX[3] = (Enable) ? HEX_Wire[3]: 1'b1;
    assign HEX[4] = (Enable) ? HEX_Wire[2]: 1'b1;
    assign HEX[5] = (Enable) ? HEX_Wire[1]: 1'b1;
    assign HEX[6] = (Enable) ? HEX_Wire[0]: 1'b1;
    
endmodule
    
    //EOF

