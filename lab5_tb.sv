`timescale 1ns/1ps

module lab5_tb();
    // 1. Khai báo các tín hiệu kết nối
    logic [8:0] DIN;
    logic       Resetn, Clock, Run;
    logic [8:0] BusWires;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic       W;
    logic       Done;

    // 2. Khởi tạo module lab5 (Device Under Test)
    lab5 uut (
        .DIN(DIN),
        .Resetn(Resetn),
        .Clock(Clock),
        .Run(Run),
        .BusWires(BusWires),
        .ADDR(ADDR),
        .DOUT(DOUT),
        .W(W),
        .Done(Done)
    );

    // 3. Tạo Clock (Chu kỳ 10ns)
    always #5 Clock = ~Clock;

    // 4. Khởi tạo RAM ảo (Mock RAM) để test
    logic [8:0] RAM [0:31];

    initial begin
        // Làm sạch RAM
        for (int i = 0; i < 32; i++) RAM[i] = 9'b0;

        // =========================================================
        // NẠP CHƯƠNG TRÌNH TEST VÀO RAM ẢO
        // =========================================================
        // Lệnh 0: mvi R1, #8 (Nạp giá trị 8 vào R1)
        RAM[0] = 9'b001_001_000; 
        RAM[1] = 9'd8;           // Dữ liệu #D = 8
        
        // Lệnh 2: mvi R2, #25 (Nạp địa chỉ 25 vào R2 dùng làm con trỏ)
        RAM[2] = 9'b001_010_000; 
        RAM[3] = 9'd25;          // Dữ liệu #D = 25
        
        // Lệnh 4: st R1, [R2] (Ghi dữ liệu từ R1(8) vào ô nhớ RAM[25])
        RAM[4] = 9'b101_001_010; 
        
        // Lệnh 5: mvi R1, #0 (Xóa R1 về 0 để chứng minh lệnh load lát nữa hoạt động đúng)
        RAM[5] = 9'b001_001_000;
        RAM[6] = 9'd0;
        
        // Lệnh 7: ld R3, [R2] (Đọc dữ liệu từ ô nhớ RAM[25] nạp vào R3. Kỳ vọng R3 = 8)
        RAM[7] = 9'b100_011_010; 
        
        // Lệnh 8: Kết thúc, lặp tại chỗ (mv R7, R7)
        RAM[8] = 9'b000_111_111; 
    end

    // 5. Logic của RAM ảo (Đọc và Ghi)
    logic [4:0] mem_addr;
    always_comb begin
        // Thay vì lấy từ BusWires, ta đọc thẳng giá trị của R7 (Program Counter)
        if (uut.control_unit.present_state == 5'd1 || uut.control_unit.present_state == 5'd4)
            mem_addr = uut.R[7][4:0];  // <--- SỬA LẠI THÀNH DÒNG NÀY
        else
            mem_addr = ADDR[4:0];
            
        DIN = RAM[mem_addr];
    end

    // Xử lý thao tác Ghi (Write) từ Processor ra RAM
    always_ff @(posedge Clock) begin
        if (W) begin
            RAM[ADDR[4:0]] <= DOUT;
            $display("   >>> [RAM WRITE EVENT] Dia chi RAM[%0d] duoc ghi gia tri = %0d <<<", ADDR[4:0], DOUT);
        end
    end

    // 6. Màn hình Monitor theo dõi luồng dữ liệu tự động
    always @(negedge Clock) begin
        if (Resetn) begin
            $display("Time:%4t | State:%2d | PC(R7):%2d | IR:%3b_%3b_%3b | R1:%2d R2:%2d R3:%2d | ADDR:%2d DOUT:%2d W:%b", 
                     $time, 
                     uut.control_unit.present_state, 
                     uut.R[7],                   // Program Counter
                     uut.IR[8:6], uut.IR[5:3], uut.IR[2:0], // Mã lệnh phân rã
                     uut.R[1], uut.R[2], uut.R[3], // Quan sát các thanh ghi chính
                     ADDR, DOUT, W);
        end
    end

    // 7. Kịch bản chạy Testbench
    initial begin
        $display("=========================================================================================");
        $display(" BAT DAU MO PHONG LAB 5 (ENHANCED PROCESSOR)");
        $display("=========================================================================================");
        
        Clock = 0;
        Resetn = 0;
        Run = 0;

        #10;
        Resetn = 1; 
        Run = 1; // Kích hoạt bộ xử lý tự chạy

        // Chờ