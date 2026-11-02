
module tb_sobel_compare;

    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    wire signed [11:0] gx, gy;

    integer fd;
    integer n;

    sobel3x3 uut (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .gx(gx), .gy(gy)
    );

    initial begin
        fd = $fopen("hardware/vectors.txt", "r");

        if (fd == 0)
            $fatal(1, "Cannot open vectors.txt");

        while (!$feof(fd)) begin
            n = $fscanf(fd, "%h %h %h %h %h %h %h %h %h\n",
                p00, p01, p02,
                p10, p11, p12,
                p20, p21, p22);

            if (n == 9) begin
                #1;
                $display("RESULT,%0d,%0d", gx, gy);
            end
        end

        $fclose(fd);
        $display("COMPARISON_INPUTS_COMPLETED");
        $finish;
    end

endmodule
