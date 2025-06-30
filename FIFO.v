module FIFO #(parameter DATA_WIDTH = 8, parameter DEPTH = 8)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output reg full,
    output reg empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wr_ptr;
    reg [$clog2(DEPTH):0] rd_ptr;
    reg [$clog2(DEPTH+1):0] count;

    // Write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Count logic for full/empty
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; // Write only
                2'b01: count <= count - 1; // Read only
                default: count <= count;   // Idle or both
            endcase
        end
    end

    // Full and Empty flags
    always @(*) begin
        full  = (count == DEPTH);
        empty = (count == 0);
    end

endmodule
