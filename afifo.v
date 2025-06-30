

module async_fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    // Signals
    reg wr_clk, rd_clk;
    reg wr_rst, rd_rst;
    reg wr_en, rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty;

    // Instantiate the FIFO
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wr_clk(wr_clk),
        .wr_rst(wr_rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),

        .rd_clk(rd_clk),
        .rd_rst(rd_rst),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Clock generation (asynchronous)
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;  // 100 MHz
    end

    initial begin
        rd_clk = 0;
        forever #12 rd_clk = ~rd_clk; // ~41.67 MHz
    end

    // Test Sequence
    initial begin
        // Initial reset
        wr_rst = 1;
        rd_rst = 1;
        wr_en = 0;
        rd_en = 0;
        wr_data = 8'h00;

        // Hold reset for a few cycles
        @(negedge wr_clk);
        @(negedge rd_clk);
        #2;
        wr_rst = 0;
        rd_rst = 0;

        // WRITE PHASE ? Write 10 values
        repeat (10) begin
            @(negedge wr_clk);
            if (!full) begin
                wr_en = 1;
                wr_data = wr_data + 8'h01;
            end else begin
                wr_en = 0;
            end
        end
        wr_en = 0;

        // Wait before reading
        #100;

        // READ PHASE ? Read 10 values
        repeat (10) begin
            @(negedge rd_clk);
            if (!empty) begin
                rd_en = 1;
            end else begin
                rd_en = 0;
            end
        end
        rd_en = 0;

        #100;
        $finish;
    end

    // Monitor
    initial begin
        $display("Time\twr_clk\trd_clk\twr_en\twr_data\trd_en\trd_data\tfull\tempty");
        $monitor("%0t\t%b\t%b\t%b\t%h\t%b\t%h\t%b\t%b", 
            $time, wr_clk, rd_clk, wr_en, wr_data, rd_en, rd_data, full, empty);
    end

endmodule

