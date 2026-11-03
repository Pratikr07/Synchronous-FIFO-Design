
`timescale 1ns / 1ps

module tb_fifo #(
    parameter DEPTH = 8,
    parameter DATA_WIDTH = 8
);

    reg clk;
    reg rst_n;
    reg wren;
    reg rd_en;
    reg [DATA_WIDTH-1:0] data_in;

    wire [DATA_WIDTH-1:0] data_out;
    wire full;
    wire empty;
    wire [$clog2(DEPTH+1)-1:0] count;

    reg [DATA_WIDTH-1:0] ref_queue[$];
    reg [DATA_WIDTH-1:0] expected_data;

    integer errors;

    // DUT
    fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wren(wren),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .count(count)
    );

    // -------------------------
    // Assertions
    // -------------------------

    assert property (@(posedge clk) disable iff (!rst_n)
        (count == 0) |-> empty
    )
    else $error("EMPTY FLAG ERROR");

    assert property (@(posedge clk) disable iff (!rst_n)
        (count == DEPTH) |-> full
    )
    else $error("FULL FLAG ERROR");

    assert property (@(posedge clk) disable iff (!rst_n)
        (full && wren && !(rd_en && !empty))
        |=> (count == DEPTH)
    )
    else $error("OVERFLOW ERROR");

    assert property (@(posedge clk) disable iff (!rst_n)
        (empty && rd_en && !(wren && !full))
        |=> (count == 0)
    )
    else $error("UNDERFLOW ERROR");

    // -------------------------
    // Clock Generation
    // -------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // -------------------------
    // FIFO Operation Task
    // -------------------------

    task fifo_operation;
        input wr;
        input rd;
        input [DATA_WIDTH-1:0] din;

        reg write_ok;
        reg read_ok;

        begin

            @(negedge clk);

            wren = wr;
            rd_en = rd;
            data_in = din;

            // Determine accepted operations
            write_ok = wr && !full;
            read_ok = rd && !empty;

            // Reference queue update
            if (read_ok) begin
                expected_data = ref_queue.pop_front();
            end

            if (write_ok) begin
                ref_queue.push_back(din);
            end

            // Wait for DUT operation
            @(posedge clk);
            #1;

            // Read data verification
            if (read_ok) begin

                if (data_out === expected_data) begin
                    $display("READ PASS: Expected=%0d Actual=%0d",
                             expected_data, data_out);
                end
                else begin
                    $display("READ FAIL: Expected=%0d Actual=%0d",
                             expected_data, data_out);
                    errors = errors + 1;
                end

            end

            // Count verification
            if (count == ref_queue.size()) begin
                $display("COUNT PASS: %0d", count);
            end
            else begin
                $display("COUNT FAIL: Actual=%0d Expected=%0d",
                         count, ref_queue.size());
                errors = errors + 1;
            end

            // Flag verification
            if ((full == (ref_queue.size() == DEPTH)) &&
                (empty == (ref_queue.size() == 0))) begin

                $display("FLAG PASS: FULL=%b EMPTY=%b",
                         full, empty);

            end
            else begin
                $display("FLAG FAIL");
                errors = errors + 1;
            end

        end
    endtask

    // -------------------------
    // Main Test Sequence
    // -------------------------

    initial begin

        rst_n = 0;
        wren = 0;
        rd_en = 0;
        data_in = 0;
        errors = 0;

        // RESET
        $display("\n========== RESET TEST ==========");

        #12;
        rst_n = 1;

        fifo_operation(0, 0, 0);

        // TEST 1: NORMAL WRITE
        $display("\n========== WRITE TEST ==========");

        fifo_operation(1, 0, 10);
        fifo_operation(1, 0, 20);
        fifo_operation(1, 0, 30);
        fifo_operation(1, 0, 40);

        // TEST 2: NORMAL READ
        $display("\n========== READ TEST ==========");

        fifo_operation(0, 1, 0);
        fifo_operation(0, 1, 0);
        fifo_operation(0, 1, 0);
        fifo_operation(0, 1, 0);

        // TEST 3: UNDERFLOW
        $display("\n========== UNDERFLOW TEST ==========");

        fifo_operation(0, 1, 0);

        // TEST 4: FILL FIFO
        $display("\n========== FULL TEST ==========");

        repeat(DEPTH) begin
            fifo_operation(1, 0, $urandom_range(1, 255));
        end

        // TEST 5: OVERFLOW
        $display("\n========== OVERFLOW TEST ==========");

        fifo_operation(1, 0, 99);

        // TEST 6: READ ALL
        $display("\n========== READ ALL TEST ==========");

        repeat(DEPTH) begin
            fifo_operation(0, 1, 0);
        end

        // TEST 7: SIMULTANEOUS READ AND WRITE
        $display("\n========== SIMULTANEOUS TEST ==========");

        fifo_operation(1, 0, 100);
        fifo_operation(1, 0, 200);

        fifo_operation(1, 1, 300);

        fifo_operation(0, 1, 0);
        fifo_operation(0, 1, 0);

        // TEST 8: POINTER WRAPAROUND
        $display("\n========== POINTER WRAPAROUND TEST ==========");

        repeat(DEPTH) begin
            fifo_operation(1, 0, $urandom_range(1, 255));
        end

        repeat(DEPTH) begin
            fifo_operation(0, 1, 0);
        end

        // FINAL CHECK
        @(negedge clk);
        wren = 0;
        rd_en = 0;

        $display("\n========== FINAL RESULT ==========");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("TESTS FAILED: %0d errors", errors);
        end

        #20;
        $finish;

    end

endmodule
