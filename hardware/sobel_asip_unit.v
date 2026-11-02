
module sobel_asip_unit (
    input wire clk,
    input wire reset,

    // Proposed SET instructions
    input wire load_row0,
    input wire load_row1,
    input wire load_row2,

    input wire [23:0] row_data,

    // Proposed compute instruction
    input wire compute,

    output reg signed [11:0] gx_out,
    output reg signed [11:0] gy_out,
    output reg result_valid
);

    // Three 24-bit pixel row registers
    reg [23:0] row0;
    reg [23:0] row1;
    reg [23:0] row2;

    // Extract 8-bit pixels from each row
    wire [7:0] p00 = row0[23:16];
    wire [7:0] p01 = row0[15:8];
    wire [7:0] p02 = row0[7:0];

    wire [7:0] p10 = row1[23:16];
    wire [7:0] p11 = row1[15:8];
    wire [7:0] p12 = row1[7:0];

    wire [7:0] p20 = row2[23:16];
    wire [7:0] p21 = row2[15:8];
    wire [7:0] p22 = row2[7:0];

    wire signed [11:0] gx_internal;
    wire signed [11:0] gy_internal;

    // Existing Sobel calculation unit
    sobel3x3 sobel_core (
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .gx(gx_internal),
        .gy(gy_internal)
    );

    // Register loading and result generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row0 <= 24'd0;
            row1 <= 24'd0;
            row2 <= 24'd0;

            gx_out <= 12'sd0;
            gy_out <= 12'sd0;
            result_valid <= 1'b0;
        end
        else begin
            result_valid <= 1'b0;

            if (load_row0)
                row0 <= row_data;

            if (load_row1)
                row1 <= row_data;

            if (load_row2)
                row2 <= row_data;

            if (compute) begin
                gx_out <= gx_internal;
                gy_out <= gy_internal;
                result_valid <= 1'b1;
            end
        end
    end

endmodule
