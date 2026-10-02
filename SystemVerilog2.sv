module top (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic       Run,
    output logic [8:0] LEDs,
    output logic       Done
);

    logic [8:0] ADDR, DOUT, DIN;
    logic       W, mem_wr_en, led_wr_en;

    // 1. Khởi tạo Processor đã nâng cấp
    lab5 cpu (
        .Clock(Clock), 
        .Resetn(Resetn), 
        .Run(Run),
        .DIN(DIN),
        .ADDR(ADDR), 
        .DOUT(DOUT), 
        .W(W), 
        .Done(Done),
        .BusWires() // Bỏ trống nếu không cần debug ra ngoài
    );

    // 2. Khối Address Decoder (Giải mã địa chỉ)
    // Nếu A8A7 = 00 -> Ghi vào RAM
    // Nếu A8A7 = 01 -> Ghi ra LED
    assign mem_wr_en = W & (~ADDR[8]) & (~ADDR[7]);
    assign led_wr_en = W & (~ADDR[8]) & ADDR[7];

    // 3. Synchronous SRAM (Bộ nhớ 128 words x 9 bits)
    logic [8:0] memory [0:127];

    // Có thể load machine code vào RAM ở đây thông qua file .mif hoặc .txt
    // initial $readmemb("program.txt", memory);

    always_ff @(posedge Clock) begin
        if (mem_wr_en)
            memory[ADDR[6:0]] <= DOUT; // Ghi dữ liệu
            
        DIN <= memory[ADDR[6:0]];      // Đọc dữ liệu (SRAM luôn xuất data ứng với ADDR)
    end

    // 4. Thanh ghi xuất ra LEDs
    always_ff @(posedge Clock) begin
        if (!Resetn)
            LEDs <= 9'b0;
        else if (led_wr_en)
            LEDs <= DOUT;
    end

endmodule
