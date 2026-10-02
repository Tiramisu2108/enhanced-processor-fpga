`timescale 1ns/1ps

module top_module_tb();
    logic CLOCK_50;
    logic [0:0] KEY;
    logic SW;
    logic [8:0] LEDR;

    logic [8:0] r0, r1, r2, r3, r4, r5, r6, pc;
    logic [8:0] addr, din, dout;
    logic w, done;

    top_module DUT (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR)
    );

    assign r0 = DUT.processor.R[0];
    assign r1 = DUT.processor.R[1];
    assign r2 = DUT.processor.R[2];
    assign r3 = DUT.processor.R[3];
    assign r4 = DUT.processor.R[4];
    assign r5 = DUT.processor.R[5];
    assign r6 = DUT.processor.R[6];
    assign pc = DUT.processor.R[7];
    
    assign addr = DUT.processor.ADDR;
    assign din  = DUT.processor.DIN;
    assign dout = DUT.processor.DOUT;
    assign w    = DUT.processor.W;
    assign done = DUT.processor.Done;

    always begin #2 CLOCK_50 = ~CLOCK_50; end

    initial begin
        KEY[0] = 1'b0;
        SW  = 1'b0;
		  CLOCK_50 = 1'b0;
        
        #25;
        KEY[0] = 1'b1;
        
        #40;
        SW  = 1'b1;
        
        #15000;
        $finish;
    end

endmodule
