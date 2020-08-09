// File convert_444_422.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
// Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
// Modifications (C) 2006 Mark Gonzales - PMC Sierra Inc
// 
// vhd2vl comes with ABSOLUTELY NO WARRANTY
// ALWAYS RUN A FORMAL VERIFICATION TOOL TO COMPARE VHDL INPUT TO VERILOG OUTPUT 
// 
// This is free software, and you are welcome to redistribute it under certain conditions.
// See the license file license.txt included with the source for details.

//--------------------------------------------------------------------------------
// Engineer:    Mike Field <hamster@snap.net.nz> 
// Module Name: convert_444_422 - Behavioral 
// 
// Description: Convert the input pixels into two RGB values - that for the Y calc
//              and that for the CbCr calculation
//
// Feel free to use this how you see fit, and fix any errors you find :-)
//--------------------------------------------------------------------------------

module convert_444_422(
    clk,
    r_in,
    g_in,
    b_in,
    hsync_in,
    vsync_in,
    de_in,
    r1_out,
    g1_out,
    b1_out,
    r2_out,
    g2_out,
    b2_out,
    pair_start_out,
    hsync_out,
    vsync_out,
    de_out
    );

input clk;
// pixels and control signals in
input[7:0] r_in;
input[7:0] g_in;
input[7:0] b_in;
input hsync_in;
input vsync_in;
input de_in;
// two channels of output RGB + control signals
output[8:0] r1_out;
output[8:0] g1_out;
output[8:0] b1_out;
output[8:0] r2_out;
output[8:0] g2_out;
output[8:0] b2_out;
output pair_start_out;
output hsync_out;
output vsync_out;
output de_out;

wire   clk;
wire  [7:0] r_in;
wire  [7:0] g_in;
wire  [7:0] b_in;
wire   hsync_in;
wire   vsync_in;
wire   de_in;
reg  [8:0] r1_out;
reg  [8:0] g1_out;
reg  [8:0] b1_out;
reg  [8:0] r2_out;
reg  [8:0] g2_out;
reg  [8:0] b2_out;
reg   pair_start_out;
reg   hsync_out;
reg   vsync_out;
reg   de_out;


reg [7:0] r_a;
reg [7:0] g_a;
reg [7:0] b_a;
reg  h_a;
reg  v_a;
reg  d_a;
reg  d_a_last;
// flag is used to work out which pairs of pixels to sum.
reg  flag;

  always @(posedge clk) begin
    // sync pairs to the de_in going high (if a scan line has odd pixel count)
    if((d_a == 1'b 1 && d_a_last == 1'b 0) || flag == 1'b 1) begin
      r2_out <= (({1'b 0,r_a}) + ({1'b 0,r_in}));
      g2_out <= (({1'b 0,g_a}) + ({1'b 0,g_in}));
      b2_out <= (({1'b 0,b_a}) + ({1'b 0,b_in}));
      flag <= 1'b 0;
      pair_start_out <= 1'b 1;
    end
    else begin
      flag <= 1'b 1;
      pair_start_out <= 1'b 0;
    end
    r1_out <= {r_a,1'b 0};
    b1_out <= {b_a,1'b 0};
    g1_out <= {g_a,1'b 0};
    hsync_out <= h_a;
    vsync_out <= v_a;
    de_out <= d_a;
    d_a_last <= d_a;
    r_a <= r_in;
    g_a <= g_in;
    b_a <= b_in;
    h_a <= hsync_in;
    v_a <= vsync_in;
    d_a <= de_in;
  end


endmodule
