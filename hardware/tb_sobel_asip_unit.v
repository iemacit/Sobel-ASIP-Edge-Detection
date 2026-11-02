
module tb_sobel_asip_unit;

    reg clk = 0;
    reg reset = 0;

    reg load_row0 = 0;
    reg load_row1 = 0;
    reg load_row2 = 0;

    reg [23:0] row_data = 0;
    reg compute = 0;

    wire signed [11:0] gx_out;
    wire signed [11:0] gy_out;
    wire result_valid;

    integer errors = 0;

    sobel_asip_unit uut (
        .clk(clk),
        .reset(reset),
        .load_row0(load_row0),
        .load_row1(load_row1),
        .load_row2(load_row2),
        .row_data(row_data),
        .compute(compute),
        .gx_out(gx_out),
        .gy_out(gy_out),
        .result_valid(result_valid)
    );

    always #5 clk = ~clk;

    task load_rows;
        input [23:0] r0, r1, r2;
        begin
            @(negedge clk);
            row_data = r0;
            load_row0 = 1;
            @(negedge clk);
            load_row0 = 0;

            row_data = r1;
            load_row1 = 1;
            @(negedge clk);
            load_row1 = 0;

            row_data = r2;
            load_row2 = 1;
            @(negedge clk);
            load_row2 = 0;
        end
    endtask

    task check_result;
        input integer expected_x;
        input integer expected_y;
        begin
            @(negedge clk);
            compute = 1;
            @(posedge clk);
            #1;

            if (result_valid &&
                gx_out == expected_x &&
                gy_out == expected_y) begin
                $display("PASS: Gx=%0d Gy=%0d",
                         gx_out, gy_out);
            end
            else begin
                $display("FAIL: Gx=%0d Gy=%0d",
                         gx_out, gy_out);
                errors = errors + 1;
            end

            @(negedge clk);
            compute = 0;
        end
    endtask

    initial begin
        $display("ASIP UNIT TEST STARTED");

        reset = 1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        // Test 1: Black image
        load_rows(24'h000000, 24'h000000, 24'h000000);
        check_result(0, 0);

        // Test 2: Constant gray image
        load_rows(24'h646464, 24'h646464, 24'h646464);
        check_result(0, 0);

        // Test 3: Vertical transition
        load_rows(24'h0080FF, 24'h0080FF, 24'h0080FF);
        check_result(1020, 0);

        // Test 4: Horizontal transition
        load_rows(24'h000000, 24'h808080, 24'hFFFFFF);
        check_result(0, 1020);

        if (errors == 0)
            $display("ALL ASIP UNIT TESTS PASSED");
        else
            $display("ASIP UNIT TESTS FAILED: %0d errors", errors);

        $finish;
    end

endmodule
