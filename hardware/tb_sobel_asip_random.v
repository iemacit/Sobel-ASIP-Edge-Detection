
module tb_sobel_asip_random;

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

    reg [7:0] p00,p01,p02;
    reg [7:0] p10,p11,p12;
    reg [7:0] p20,p21,p22;

    integer expected_gx, expected_gy;
    integer i, errors;

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

    initial begin
        errors = 0;

        reset = 1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;

        $display("ASIP RANDOM TEST STARTED");

        for (i = 0; i < 1000; i = i + 1) begin

            p00 = $urandom_range(0,255);
            p01 = $urandom_range(0,255);
            p02 = $urandom_range(0,255);
            p10 = $urandom_range(0,255);
            p11 = $urandom_range(0,255);
            p12 = $urandom_range(0,255);
            p20 = $urandom_range(0,255);
            p21 = $urandom_range(0,255);
            p22 = $urandom_range(0,255);

            expected_gx =
                -p00 + p02 - 2*p10 + 2*p12 - p20 + p22;

            expected_gy =
                -p00 - 2*p01 - p02 + p20 + 2*p21 + p22;

            // Load row 0
            @(negedge clk);
            row_data = {p00,p01,p02};
            load_row0 = 1;

            // Load row 1
            @(negedge clk);
            load_row0 = 0;
            row_data = {p10,p11,p12};
            load_row1 = 1;

            // Load row 2
            @(negedge clk);
            load_row1 = 0;
            row_data = {p20,p21,p22};
            load_row2 = 1;

            // Compute
            @(negedge clk);
            load_row2 = 0;
            compute = 1;

            @(posedge clk);
            #1;

            if (!result_valid ||
                gx_out !== expected_gx ||
                gy_out !== expected_gy) begin

                errors = errors + 1;

                if (errors <= 5)
                    $display("FAIL Case %0d: GX=%0d Expected=%0d GY=%0d Expected=%0d",
                        i, gx_out, expected_gx,
                        gy_out, expected_gy);
            end

            @(negedge clk);
            compute = 0;
        end

        $display("----------------------------");
        $display("Total tests: 1000");
        $display("Failed tests: %0d", errors);
        $display("Successful tests: %0d", 1000-errors);

        if (errors == 0)
            $display("ALL ASIP RANDOM TESTS PASSED");
        else
            $display("ASIP RANDOM TESTS FAILED");

        $finish;
    end

endmodule
