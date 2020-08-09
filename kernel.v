`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2020 20:09:32
// Design Name: 
// Module Name: kernel
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


module kernel(
    input [7:0] bw22,
    input [7:0] bw32,
    input [7:0] bw12,
    input [7:0] bw33,
    input [7:0] bw23,
    input [7:0] bw13,
    input [7:0] bw31,
    input [7:0] bw21,
    input [7:0] bw11,
    output [7:0] dina2
    );
//    wire signed [10:0] bw11,bw12,bw13,bw21,bw22,bw23,bw31,bw32,bw33,out2;
    wire signed [11:0] avg,hor,ver;
    wire [7:0] out;
//    assign bw11 = (ar11[7:0]+ar11[15:8]+ar11[23:16])/3;
//    assign bw12 = (ar12[7:0]+ar12[15:8]+ar12[23:16])/3;
//    assign bw13 = (ar13[7:0]+ar13[15:8]+ar13[23:16])/3;
//    assign bw21 = (ar21[7:0]+ar21[15:8]+ar21[23:16])/3;
//    assign bw22 = (ar22[7:0]+ar22[15:8]+ar22[23:16])/3;
//    assign bw23 = (ar23[7:0]+ar23[15:8]+ar11[23:16])/3;
//    assign bw31 = (ar31[7:0]+ar31[15:8]+ar31[23:16])/3;
//    assign bw32 = (ar32[7:0]+ar32[15:8]+ar32[23:16])/3;
//    assign bw33 = (ar33[7:0]+ar33[15:8]+ar33[23:16])/3;
    
//    assign hor = ( bw11 + 2*bw12 + bw13 - bw31 - 2*bw32 - bw33);// + 510) / 4;
//    assign ver = (bw11 + 2*bw21 + bw31 - bw13 - 2*bw23 - bw33 );//+ 510) / 4;
//    assign out = (hor + ver) / 2;
//    assign out = out2[7:0];
    wire [7:0] out2;
    assign hor = ( 3*bw11 + 10*bw12 + 3*bw13 - 3*bw31 - 10*bw32 - 3*bw33);// + 510) / 4;
    assign ver = (3*bw11 + 10*bw21 + 3*bw31 - 3*bw13 - 10*bw23 - 3*bw33 );//+ 510) / 4;
   // assign sqr = (hor*hor)+(ver*ver);
   // square_root root(sqr,out2,k);
    assign out2 = (hor + ver) / 2;
    assign out = (out2>150)?255:0;
    assign dina2 = out;

//    assign avg = (bw11+bw12+bw13+bw21+bw22+bw23+bw31+bw32+bw33)/9;
//    assign out = avg[7:0];
//    assign dina2 = {out,out,out};
    
//    bw00
    
endmodule
