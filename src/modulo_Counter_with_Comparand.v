/*
 * COMPARAND MUST BE "EXPECTED VALUE - 1"
 *
 *	E.G.) 0.5 Seconds -> COMPARAND = 25_000_000 - 1 = 24_999_999
 * 1hz clock -> COMPARAND = 100_000_000 - 1
 */

module modulo_Counter_with_Comparand(TICK,
                                     RESET_N,
                                     Q_OUT,
                                     Q_DIGIT_CHANGE,
                                     COMPARAND,
                                     Enable);
    
    parameter n = 32;
    input TICK, RESET_N, Enable;
    input [n-1:0] COMPARAND;
    output reg [n-1:0]Q_OUT;
    output reg Q_DIGIT_CHANGE;
    
    initial
    begin
        Q_OUT          = 0;
        Q_DIGIT_CHANGE = 0;
    end
    
    always@(posedge TICK or negedge RESET_N)
    begin
        if (~RESET_N)
        begin
            Q_OUT          = 0;
            Q_DIGIT_CHANGE = 0;
        end
        else
        begin //If Reset        
            if (Enable)
            begin
                if (Q_OUT == COMPARAND)
                begin
                    Q_OUT          = 0;
                    Q_DIGIT_CHANGE = 1; //Duty = 1/n%, Works as Clock
                end
                else
                begin
                    Q_OUT          = Q_OUT + 1;
                    Q_DIGIT_CHANGE = 0; //-_________-_________
                end
            end//End Enable            
        end //End Reset
    end
    
endmodule
//EOF

