// File hdmi_ddr_output.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// 
// Module Name:    hdmi_ddr_output - Behavioral 
//
// Description: DDR inferface to the ADV7511 HDMI transmitter
//
// Feel free to use this how you see fit, and fix any errors you find :-)
//--------------------------------------------------------------------------------

module hdmi_ddr_output(
clk,
clk90,
y,
c,
hsync_in,
vsync_in,
de_in,
hdmi_clk,
hdmi_hsync,
hdmi_vsync,
hdmi_d,
hdmi_de,
hdmi_scl,
hdmi_sda
);

input clk;
input clk90;
input[7:0] y;
input[7:0] c;
input hsync_in;
input vsync_in;
input de_in;
output hdmi_clk;
output hdmi_hsync;
output hdmi_vsync;
output[15:0] hdmi_d;
output hdmi_de;
output hdmi_scl;
inout hdmi_sda;

wire   clk;
wire   clk90;
wire  [7:0] y;
wire  [7:0] c;
wire   hsync_in;
wire   vsync_in;
wire   de_in;
wire   hdmi_clk;
reg   hdmi_hsync;
reg   hdmi_vsync;
wire  [15:0] hdmi_d;
wire   hdmi_de;
wire   hdmi_scl;
wire   hdmi_sda;

  always @(posedge clk) begin
    hdmi_vsync <= vsync_in;
    hdmi_hsync <= hsync_in;
  end

  ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"),
    .INIT(1'b 0),
    .SRTYPE("SYNC"))
  ODDR_hdmi_clk(
      .C(clk90),
    .Q(hdmi_clk),
    .D1(1'b1),
    .D2(1'b0),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0));

  ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"),
    .INIT(1'b 0),
    .SRTYPE("SYNC"))
  ODDR_hdmi_de(
      .C(clk),
    .Q(hdmi_de),
    .D1(de_in),
    .D2(de_in),
    .CE(1'b1),
    .R(1'b0),
    .S(1'b0));

  genvar i;
  generate for (i=0; i <= 7; i = i + 1) begin : ddrmem
      //begin
    ODDR #(.DDR_CLK_EDGE("SAME_EDGE"),
			.INIT(1'b 0),
			.SRTYPE("SYNC"))
		ODDR_hdmi_d(.C(clk),
						.Q(hdmi_d[i + 8] ),
						.D1(y[i] ),
						.D2(c[i] ),
						.CE(1'b1),
						.R(1'b0),
						.S(1'b0));
	end
  endgenerate
  
  assign hdmi_d[7:0]  = 8'b 00000000;
  //---------------------------------------------------------------------   
  // This sends the configuration register values to the HDMI transmitter
  //---------------------------------------------------------------------   
  i2c_sender i_i2c_sender(
      .clk(clk),
    .resend(1'b0),
    .sioc(hdmi_scl),
    .siod(hdmi_sda));


endmodule
