module edgeDetector(signal_IN,
                    edgeDetection__BOTH,
                    edgeDetection_POSIT,
                    edgeDetection_NEGAT,
                    Clock_50MHz);
    
    input Clock_50MHz;
    input signal_IN;
    output edgeDetection__BOTH;
    output edgeDetection_POSIT;
    output edgeDetection_NEGAT;
    reg REG_POSEDGE;
    reg REG_NEGEDGE;
    wire posedgeDETECT;
    wire negedgeDETECT;
    
    //POSITIVE EDGE DETECTOR
    assign posedgeDETECT = (~REG_POSEDGE) & signal_IN;
    
    //NEGATIVE EDGE DETECTOR
    assign negedgeDETECT = REG_NEGEDGE & ~signal_IN;
    
    //REGISTERS SETUP
    initial
    begin
        REG_POSEDGE = 0;
        REG_NEGEDGE = 0;
    end
    
    always@(posedge Clock_50MHz)
    begin
        REG_POSEDGE = signal_IN;
        REG_NEGEDGE = signal_IN;
    end
    
    assign edgeDetection__BOTH = posedgeDETECT | negedgeDETECT;
    assign edgeDetection_POSIT = posedgeDETECT;
    assign edgeDetection_NEGAT = negedgeDETECT;
    
endmodule
    
    
    
module TickGenerator(CLK, 
                    Sig_In_TOGGLES, 
                    Tick_Out);
        
    input CLK, Sig_In_TOGGLES;
    output reg Tick_Out;
    wire ANY_EDGE;
    reg Count_Enable;
    reg [9:0]Countee;
        
    edgeDetector ED(
    .signal_IN(Sig_In_TOGGLES),
    .edgeDetection__BOTH(ANY_EDGE),
    .edgeDetection_POSIT(),
    .edgeDetection_NEGAT(),
    .Clock_50MHz(CLK)
    );
    
    initial
    begin
        Countee      = 0;
        Count_Enable = 0;
    end
    
    always@(posedge ANY_EDGE or posedge CLK)
    begin
        if (ANY_EDGE)
        begin
            Countee      = 10'b10000_00000;
            Count_Enable = 1;
            Tick_Out     = 1;
        end
        else
        begin
            if (Count_Enable)
            begin
                if (Countee == 1)
                begin
                    Tick_Out     = 0;
                    Count_Enable = 0;
                end
                else
                begin
                    Countee = {1'b0, Countee[9:1]};
                end
            end
        end
    end
        
endmodule
                
module B_Length_DETECTOR(B_Trigger, 
                        CLOCK_50MHz, 
                        B_Short, 
                        B_Long);
                        
    parameter OneSec = 50_000_000;
    input B_Trigger, CLOCK_50MHz;
    output wire B_Long;
    output wire B_Short;        
    reg START_COUNTING;
    reg timerFinSig;
    reg [32:0]timeCounter;
    reg B_Short_TOGGLE;
    reg B_Long_TOGGLE;        
    wire edgePulse_NEGA;
            
    edgeDetector EDC(
    .signal_IN(B_Trigger),
    .edgeDetection__BOTH(),
    .edgeDetection_POSIT(),
    .edgeDetection_NEGAT(edgePulse_NEGA),
    .Clock_50MHz(CLOCK_50MHz)
    );
            
    TickGenerator TG_SHORT(
    .CLK(CLOCK_50MHz),
    .Sig_In_TOGGLES(B_Short_TOGGLE),
    .Tick_Out(B_Short)
    );
            
    TickGenerator TG_LONG(
    .CLK(CLOCK_50MHz),
    .Sig_In_TOGGLES(B_Long_TOGGLE),
    .Tick_Out(B_Long)
    );

    initial
    begin
        START_COUNTING = 0;
        timeCounter    = 0;
        B_Short_TOGGLE = 0;
        B_Long_TOGGLE  = 0;
        timerFinSig    = 0;
    end
    
    always@(posedge CLOCK_50MHz)
    begin
        if (START_COUNTING)
        begin
            if (timeCounter ! = 50_000_000)
            begin
                timeCounter = timeCounter + 1;
            end
            else
            begin
                timerFinSig = 1;
            end
        end
        else
        begin
            timerFinSig = 0;
            timeCounter = 0;
        end
    end
            
    always@(posedge B_Trigger or posedge edgePulse_NEGA or posedge timerFinSig)
    begin
        if (B_Trigger)
        begin
            START_COUNTING = 1;
        end
        else if (edgePulse_NEGA)
        begin
            if (START_COUNTING) //It was still counting, which means B_SHort
            begin
                START_COUNTING = 0;
                B_Short_TOGGLE = ~B_Short_TOGGLE;
            end
        end
        else if (timerFinSig)
        begin
            START_COUNTING	 = 0;
            B_Long_TOGGLE   = ~B_Long_TOGGLE;
        end
    end

endmodule
//EOF

