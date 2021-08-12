module Clock_Generator(CLOCK,
                       RESET_N,
                       internalCounter,
                       generatedCLOCK,
                       COMPARAND,
                       Enable);
    
    parameter n = 32;   // 32bit System
    
    input [n-1:0]COMPARAND;
    input CLOCK, RESET_N, Enable;
    output reg [n-1:0]internalCounter;
    output reg generatedCLOCK;
    
    initial
    begin
        internalCounter = 0;
        generatedCLOCK  = 0;
    end
    
    always@(posedge CLOCK or negedge RESET_N)
    begin
        if (~RESET_N)
        begin
            internalCounter = 0;
            generatedCLOCK  = 0;
        end
        else
        begin
            if (Enable)
            begin
                if (internalCounter == COMPARAND)
                begin
                    internalCounter = 1;
                    generatedCLOCK  = 1;    // Duty  = 50%, works as clock
                end
                else
                begin
                    internalCounter = internalCounter + 1;
                    if (internalCounter == {1'b0, COMPARAND[n-1:1]})
                    begin
                        generatedCLOCK = 0 ;    // Duty = 50%, Falling Edge
                    end
                end
            end
        end
    end
    
endmodule
    // EOF

