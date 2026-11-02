
module tb_sobel3x3;
    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    wire signed [11:0] gx, gy;

    integer expected_gx, expected_gy;
    integer i;

    sobel3x3 uut (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .gx(gx), .gy(gy)
    );

    initial begin
        $display("Sobel3x3 test started");

        // Test 1: Siyah goruntu
        {p00,p01,p02,p10,p11,p12,p20,p21,p22} = {9{8'd0}};
        #10;
        if (gx !== 0 || gy !== 0) $fatal(1, "Test 1 FAILED");
        $display("Test 1 PASSED");

        // Test 2: Sabit gri goruntu
        {p00,p01,p02,p10,p11,p12,p20,p21,p22} = {9{8'd100}};
        #10;
        if (gx !== 0 || gy !== 0) $fatal(1, "Test 2 FAILED");
        $display("Test 2 PASSED");

        // Test 3: Dikey gecis
        p00=0; p01=128; p02=255;
        p10=0; p11=128; p12=255;
        p20=0; p21=128; p22=255;
        #10;
        if (gx !== 1020 || gy !== 0)
            $fatal(1, "Test 3 FAILED");
        $display("Test 3 PASSED");

        // Test 4: Yatay gecis
        p00=0; p01=0; p02=0;
        p10=128; p11=128; p12=128;
        p20=255; p21=255; p22=255;
        #10;
        if (gx !== 0 || gy !== 1020)
            $fatal(1, "Test 4 FAILED");
        $display("Test 4 PASSED");

        // Test 5: 1000 rastgele matris
        $display("Random test started: 1000 cases");

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

            expected_gx = -p00 + p02
                        - 2*p10 + 2*p12
                        - p20 + p22;

            expected_gy = -p00 - 2*p01 - p02
                        + p20 + 2*p21 + p22;

            #1;

            if (gx !== expected_gx || gy !== expected_gy)
                $fatal(1, "Random test FAILED at case %0d: GX=%0d expected=%0d GY=%0d expected=%0d",
                       i, gx, expected_gx, gy, expected_gy);
        end

        $display("1000 RANDOM TESTS PASSED");
        $display("ALL TESTS PASSED");

        $finish;
    end
endmodule
