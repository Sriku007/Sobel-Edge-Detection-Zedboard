`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 19:36:28
// Design Name: 
// Module Name: edge_detect
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


module edge_detect(
    input clk,
    input rst_n,
    input [7:0] douta1,
    output reg [7:0] dina2,
    output reg wea2,
    output reg [17:0] addra4,
    output reg [17:0] addra5,
    output reg ready
    );
    parameter H=500;
    parameter V=500;
    reg [11:0] row,col;
    reg [3:0] state;
    reg [7:0] array[0:8];
    wire [7:0] dina2c;
    kernel inst_kernel(array[0],array[1],array[2],array[3],array[4],array[5],array[6],array[7],array[8],dina2c);
    
	always@(posedge clk or posedge rst_n)
	    begin
	    	if (rst_n) 
		    	begin
		    		row <= 1;
		    		col <= 1;
					addra4 <= row*H + col;
					ready <= 0;
				end
			else 
				begin		
					if(state==0&&ready==0)
						begin
							array[0] <= douta1 ; 
							addra4 <= (row-1)*H + col ;
							state <= state+1;
						end
					else if(state==1)
						begin
							array[1] <= douta1 ; 
							addra4 <= (row+1)*H + col ;
							state <= state+1;
						end
					else if(state==2)
						begin
							array[2] <= douta1 ; 
							addra4 <= (row+1)*H + (col+1) ;
							state <= state+1;
						end
					else if(state==3)
						begin
							array[3] <= douta1 ; 
							addra4 <= (row)*H + (col+1) ;
							state <= state+1;
						end
					else if(state==4)
						begin
							array[4] <= douta1 ; 
							addra4 <= (row-1)*H + (col+1) ;
							state <= state+1;
						end
					else if(state==5)
						begin
							array[5] <= douta1 ; 
							addra4 <= (row+1)*H + (col-1) ;
							state <= state+1;
						end
					else if(state==6)
						begin
							array[6] <= douta1 ; 
							addra4 <= (row)*H + (col-1) ;
							state <= state+1;
						end
					else if(state==7)
						begin
							array[7] <= douta1 ; 
							addra4 <= (row-1)*H + (col-1) ;
							state <= state+1;
						end
					else if(state==8)
						begin
							array[8] <= douta1 ;
							addra5 <= row*H + col;
							dina2 <= dina2c;
							wea2 <= 1'b1;
							if(col+1<H)
								begin
									col <= col+1;
								end
							else if(row+1<V)
								begin
									row <= row+1;
									col <= 0;
								end
							else 
								begin
									state <= 10;
									ready <= 1;
								end
							state <= state+1;
						end
					else if(state==9)
						begin
						    addra4 <= row*H + col;
							wea2 <= 1'b0;
							state <= 0;
						end
				end
		end
    
endmodule
