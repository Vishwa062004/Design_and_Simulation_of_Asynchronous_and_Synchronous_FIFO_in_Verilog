`timescale 1ns / 1ps

module fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 4;

    // Signals
    reg clk, rst;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty;

    // Instantiate FIFO
    FIFO #(DATA_WIDTH, DEPTH) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 10ns clock

    // Test sequence
    initial begin
        $display("Starting FIFO Simulation...");
        $monitor("Time=%0t | wr_en=%b rd_en=%b din=%h dout=%h | full=%b empty=%b",
                 $time, wr_en, rd_en, din, dout, full, empty);

        clk = 0; rst = 1; wr_en = 0; rd_en = 0; din = 0;
        #10 rst = 0;

        // Write data
        write(8'hA1); #10;
        write(8'hB2); #10;
        write(8'hC3); #10;
        write(8'hD4); #10;
        write(8'hE5); // Should be ignored, FIFO full
        #10;

        // Read data
        read(); #10;
        read(); #10;
        read(); #10;
        read(); #10;
        read(); // Should be ignored, FIFO empty
        #20;

        $finish;
    end

    // Tasks
    task write(input [DATA_WIDTH-1:0] data);
        begin
            wr_en = 1; din = data;
            #10;
            wr_en = 0;
        end
    endtask

    task read();
        begin
            rd_en = 1;
            #10;
            rd_en = 0;
        end
    endtask

endmodule

