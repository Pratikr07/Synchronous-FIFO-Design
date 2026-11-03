`timescale 1ns / 1ps

module fifo #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst_n,
    input wren,
    input rd_en,
    input [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty,
    output reg [$clog2(DEPTH+1)-1:0] count
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    reg [$clog2(DEPTH):0] w_ptr;
    reg [$clog2(DEPTH):0] r_ptr;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            w_ptr    <= 0;
            r_ptr    <= 0;
            count    <= 0;
            data_out <= 0;
        end

        else begin

            // Write
            if (wren && !full) begin
                mem[w_ptr % DEPTH] <= data_in;
                w_ptr <= w_ptr + 1;
            end

            // Read
            if (rd_en && !empty) begin
                data_out <= mem[r_ptr % DEPTH];
                r_ptr <= r_ptr + 1;
            end

            // Count
            if (wren && !full && !(rd_en && !empty))
                count <= count + 1;

            else if (rd_en && !empty && !(wren && !full))
                count <= count - 1;

        end
    end

endmodule