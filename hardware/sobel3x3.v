
module sobel3x3 (
    input wire [7:0] p00,
    input wire [7:0] p01,
    input wire [7:0] p02,

    input wire [7:0] p10,
    input wire [7:0] p11,
    input wire [7:0] p12,

    input wire [7:0] p20,
    input wire [7:0] p21,
    input wire [7:0] p22,

    output wire signed [11:0] gx,
    output wire signed [11:0] gy
);

    // Convert unsigned pixels to signed 12-bit values.
    wire signed [11:0] a00 = {4'b0000, p00};
    wire signed [11:0] a01 = {4'b0000, p01};
    wire signed [11:0] a02 = {4'b0000, p02};

    wire signed [11:0] a10 = {4'b0000, p10};
    wire signed [11:0] a11 = {4'b0000, p11};
    wire signed [11:0] a12 = {4'b0000, p12};

    wire signed [11:0] a20 = {4'b0000, p20};
    wire signed [11:0] a21 = {4'b0000, p21};
    wire signed [11:0] a22 = {4'b0000, p22};

    // Horizontal gradient.
    // Multiplication by 2 is implemented using left shift.
    assign gx =
        -a00 + a02
        - (a10 <<< 1) + (a12 <<< 1)
        - a20 + a22;

    // Vertical gradient.
    assign gy =
        -a00 - (a01 <<< 1) - a02
        + a20 + (a21 <<< 1) + a22;

endmodule
