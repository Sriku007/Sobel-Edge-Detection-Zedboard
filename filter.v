`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 00:01:43
// Design Name: 
// Module Name: edge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module filter(
    input clk,
    output hdmi_clk,
    output hdmi_hsync,
    output hdmi_vsync,
    output [15:0] hdmi_d,
    output hdmi_de,
    output hdmi_scl,
    inout hdmi_sda,
    input done,
    input rst_n,
    input sel,
    output ready,
    output ready2,
    output ready3
);
    assign ready2 = rst_n;
    assign ready3 = 1'b1;

	reg [7:0] array[8:0];
	reg [3:0] state;
	reg [11:0] row;
	reg [11:0] col;
    wire [7:0] pattern_r;
    wire [7:0] pattern_g;
    wire [7:0] pattern_b;
    wire  pattern_hsync;
    wire  pattern_vsync;
    wire  pattern_de;
    
    reg [17:0] addra1;
    wire [7:0] douta1;
    reg [7:0] dina1;
    reg [17:0] addra2;
    wire [7:0] douta2;
    wire [7:0] dina2;
    wire wea2;
    wire [17:0] addra3;
    wire [17:0] addra4;
    wire [17:0] addra5;
    reg [7:0] douta3;
    
    vga_generator i_vga_generator(
        .clk(clk),
        .addra(addra3),
        .douta(douta3),
        .r(pattern_r),
        .g(pattern_g),
        .b(pattern_b),
        .de(pattern_de),
        .vsync(pattern_vsync),
        .hsync(pattern_hsync),
        .done(done)
    );
   

	image edge_img(
       .clka(clk),    // input wire clka
       .ena(1'b1),      // input wire ena
       .wea(wea2),      // input wire [0 : 0] wea
       .addra(addra2),  // input wire [15 : 0] addra
       .dina(dina2),    // input wire [23 : 0] dina
       .douta(douta2)  // output wire [23 : 0] douta
     );

    image img1 (
       .clka(clk),    // input wire clka
       .ena(1'b1),      // input wire ena
       .wea(1'b0),      // input wire [0 : 0] wea
       .addra(addra1),  // input wire [15 : 0] addra
       .dina(dina1),    // input wire [23 : 0] dina
       .douta(douta1)  // output wire [23 : 0] douta
     );

    vga_hdmi inst_vga_hdmi( 
    	clk,
        pattern_r,
        pattern_g,
        pattern_b,
        pattern_hsync,
        pattern_vsync,
        pattern_de,
        hdmi_clk,
        hdmi_hsync,
        hdmi_vsync,
        hdmi_d,
        hdmi_de,
        hdmi_scl,
        hdmi_sda
    );
    
    always@(posedge clk)
        begin
        	if(~ready)
                begin
                    douta3 <= 24'b1111_1111;
                    addra1 <= addra4;
                    addra2 <= addra5;
                end
            else if(sel)
                begin
                    addra1 <= addra3;
                    douta3 <= douta1;
                end
            else if(~sel)
                begin
                    addra2 <= addra3;
                    douta3 <= douta2;
                end
        end
    	
        edge_detect inst_edge_detect(clk, rst_n,douta1,dina2,wea2,addra4,addra5,ready);


endmodule
