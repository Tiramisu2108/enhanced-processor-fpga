module counter (
    input  logic [8:0] R,
    input  logic Rin, E, Clock, Resetn, // Thêm Resetn
    output logic [8:0] Q
);
    always_ff @(posedge Clock) begin
        if (!Resetn)               // Khi Reset tích cực thấp
            Q <= 9'b0;             // Ép PC về 0
        else if (Rin) 
            Q <= R;
        else if (E) 
            Q <= Q + 1'b1;
    end
endmodule
