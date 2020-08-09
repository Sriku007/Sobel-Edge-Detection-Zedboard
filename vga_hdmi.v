// File vga_hdmi.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// Module Name: vga_hdmi - Behavioral 
// 
// Description: A test of the Zedboard's VGA & HDMI interface
//
// Feel free to use this how you see fit, and fix any errors you find :-)
//--------------------------------------------------------------------------------

module vga_hdmi(input clk_100,
                input [7:0] pattern_r,
                input [7:0] pattern_g,
                input [7:0] pattern_b,
                input  pattern_hsync,
                input  pattern_vsync,
                input  pattern_de,
                output     hdmi_clk,
                output     hdmi_hsync,
                output     hdmi_vsync,
                output     [15:0] hdmi_d,
                output     hdmi_de,
                output     hdmi_scl,
                inout      hdmi_sda
                );
                

// Clock PreBuffer
wire prebuf_clk;
wire prebuf_clk0;
wire prebuf_clk90;
wire prebuf_clk_100;
// Clocking
wire clk;
wire clk0;
wire clk90;
wire clkfb;

// Signals from the pixel pair convertor
wire [8:0] c422_r1;
wire [8:0] c422_g1;
wire [8:0] c422_b1;
wire [8:0] c422_r2;
wire [8:0] c422_g2;
wire [8:0] c422_b2;
wire  c422_pair_start;
wire  c422_hsync;
wire  c422_vsync;
wire  c422_de;
// Signals from the colour space convertor
wire [7:0] csc_y;
wire [7:0] csc_c;
wire  csc_hsync;
wire  csc_vsync;
wire  csc_de;
// signals from the output range clampler
wire [7:0] clamper_c;
wire [7:0] clamper_y;
wire  clamper_hsync;
wire  clamper_vsync;
wire  clamper_de;

//  vga_generator i_vga_generator(
//      .clk(clk),
//    .r(pattern_r),
//    .g(pattern_g),
//    .b(pattern_b),
//    .de(pattern_de),
//    .vsync(pattern_vsync),
//    .hsync(pattern_hsync));

  convert_444_422 i_convert_444_422(
      .clk(clk),
    .r_in(pattern_r),
    .g_in(pattern_g),
    .b_in(pattern_b),
    .hsync_in(pattern_hsync),
    .vsync_in(pattern_vsync),
    .de_in(pattern_de),
    .r1_out(c422_r1),
    .g1_out(c422_g1),
    .b1_out(c422_b1),
    .r2_out(c422_r2),
    .g2_out(c422_g2),
    .b2_out(c422_b2),
    .pair_start_out(c422_pair_start),
    .hsync_out(c422_hsync),
    .vsync_out(c422_vsync),
    .de_out(c422_de));

  colour_space_conversion i_csc(
      .clk(clk),
    .r1_in(c422_r1),
    .g1_in(c422_g1),
    .b1_in(c422_b1),
    .r2_in(c422_r2),
    .g2_in(c422_g2),
    .b2_in(c422_b2),
    .pair_start_in(c422_pair_start),
    .vsync_in(c422_vsync),
    .hsync_in(c422_hsync),
    .de_in(c422_de),
    .y_out(csc_y),
    .c_out(csc_c),
    .hsync_out(csc_hsync),
    .vsync_out(csc_vsync),
    .de_out(csc_de));

    //Clamper instantiation removed as not needed
  assign clamper_y = csc_y;
  assign clamper_c = csc_c;
  assign clamper_de = csc_de;
  assign clamper_hsync = csc_hsync;
  assign clamper_vsync = csc_vsync;
  
  hdmi_ddr_output i_hdmi_ddr_output(
      .clk(clk),
    .clk90(clk90),
    .y(clamper_y),
    .c(clamper_c),
    .hsync_in(clamper_hsync),
    .vsync_in(clamper_vsync),
    .de_in(clamper_de),
    .hdmi_clk(hdmi_clk),
    .hdmi_hsync(hdmi_hsync),
    .hdmi_vsync(hdmi_vsync),
    .hdmi_d(hdmi_d),
    .hdmi_de(hdmi_de),
    .hdmi_scl(hdmi_scl),
    .hdmi_sda(hdmi_sda));

    //Global buffer to provide precise timing
   BUFG clk_buf (
      .O(prebuf_clk_100), // 1-bit output: Clock output (connect to I/O clock loads).
      .I(clk_100)  // 1-bit input: Clock input (connect to an IBUFG or BUFMR).
   );   

  // Generate a 75MHz pixel clock and one with 90 degree phase shift from the 100MHz system clock.
  PLLE2_BASE #(
    .BANDWIDTH("OPTIMIZED"),    // OPTIMIZED, HIGH, LOW
    .CLKFBOUT_MULT(9),          // Multiply value for all CLKOUT, (2-64)
    .CLKFBOUT_PHASE(0),         // Phase offset in degrees of CLKFB, (-360.000-360.000).
    .CLKIN1_PERIOD(10),         // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT0_DIVIDE(9),
    .CLKOUT1_DIVIDE(12),
    .CLKOUT2_DIVIDE(12),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(0),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_PHASE(135),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_PHASE(0),
    .DIVCLK_DIVIDE(1),  // Master division value, (1-56)
    .REF_JITTER1(0),    // Reference input jitter in UI, (0.000-0.999).
    .STARTUP_WAIT("FALSE"))
  PLLE2_BASE_inst(
      // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(clk0),
    .CLKOUT1(clk),
    .CLKOUT2(clk90),
    .CLKOUT3(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKFBOUT(clkfb),   // 1-bit output: Feedback clock
    .LOCKED(),          // 1-bit output: LOCK
    .CLKIN1(prebuf_clk_100),   // 1-bit input: Input clock
    .PWRDWN(1'b0),      // 1-bit input: Power-down
    .RST(1'b0),         // 1-bit input: Reset
    .CLKFBIN(clkfb));

endmodule
