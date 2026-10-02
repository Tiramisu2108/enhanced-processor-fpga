module top_module (

    input  logic CLOCK_50,

    input  logic [0:0] KEY,

    input  logic [9:9] SW,

    output logic [9:0] LEDR

);



    logic Clock, Resetn, Run_async, Run_sync1, Run_sync;

    assign Clock = CLOCK_50;

    assign Resetn = KEY[0];

    assign Run_async = SW[9];



    always_ff @(posedge Clock) begin

        if (!Resetn) begin

            Run_sync1 <= 1'b0;

            Run_sync  <= 1'b0;

        end else begin

            Run_sync1 <= Run_async;

            Run_sync  <= Run_sync1;

        end

    end



    logic [8:0] DIN, DOUT, ADDR, BusWires;

    logic W, Done;

    logic mem_wren, led_en;



    assign mem_wren = W & (~ADDR[8]) & (~ADDR[7]);

    assign led_en = W & (~ADDR[8]) & ADDR[7];



    lab5 processor (

        .DIN(DIN),

        .Resetn(Resetn),

        .Clock(Clock),

        .Run(Run_sync),

        .BusWires(BusWires),

        .ADDR(ADDR),

        .DOUT(DOUT),

        .W(W),

        .Done(Done)

    );



    ram128x9 memory (

        .address (ADDR[6:0]),

        .clock   (Clock),

        .data    (DOUT),

        .wren    (mem_wren),

        .q       (DIN)

    );



    always_ff @(posedge Clock) begin

        if (!Resetn)

            LEDR[8:0] <= 9'b0;

        else if (led_en)

            LEDR[8:0] <= DOUT;

    end

 

assign LEDR[9] = led_en;



endmodule
