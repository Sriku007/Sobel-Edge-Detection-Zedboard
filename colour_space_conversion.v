// File colour_space_conversion.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// Module Name: colour_space_conversion - Behavioral 
// 
// Description: Convert the input pixel data into YCbCr 422 values
//
// Feel free to use this how you see fit, and fix any errors you find :-)
//--------------------------------------------------------------------------------

module colour_space_conversion(
clk,
r1_in,
g1_in,
b1_in,
r2_in,
g2_in,
b2_in,
pair_start_in,
de_in,
vsync_in,
hsync_in,
y_out,
c_out,
de_out,
hsync_out,
vsync_out
);

input clk;
input[8:0] r1_in;
input[8:0] g1_in;
input[8:0] b1_in;
input[8:0] r2_in;
input[8:0] g2_in;
input[8:0] b2_in;
input pair_start_in;
input de_in;
input vsync_in;
input hsync_in;
output[7:0] y_out;
output[7:0] c_out;
output de_out;
output hsync_out;
output vsync_out;

wire   clk;
wire  [8:0] r1_in;
wire  [8:0] g1_in;
wire  [8:0] b1_in;
wire  [8:0] r2_in;
wire  [8:0] g2_in;
wire  [8:0] b2_in;
wire   pair_start_in;
wire   de_in;
wire   vsync_in;
wire   hsync_in;
reg  [7:0] y_out;
reg  [7:0] c_out;
reg   de_out;
reg   hsync_out;
reg   vsync_out;


wire  d_a;
wire  h_a;
wire  v_a;
wire [47:0] c1;
wire [29:0] a_r1;
wire [29:0] a_g1;
wire [29:0] a_b1;
wire [17:0] b_r1;
wire [17:0] b_g1;
wire [17:0] b_b1;
wire [47:0] pc_r1;
wire [47:0] pc_g1;
wire [47:0] p_b1;
wire [47:0] c2;
wire [29:0] a_r2;
wire [29:0] a_g2;
wire [29:0] a_b2;
wire [17:0] b_r2;
wire [17:0] b_g2;
wire [17:0] b_b2;
wire [47:0] pc_r2;
wire [47:0] pc_g2;
wire [47:0] p_b2;
reg [3:0] hs_delay = 4'h0;
// := (others => '0');
reg [3:0] vs_delay = 4'h0;
// := (others => '0');
reg [3:0] de_delay = 4'h0;
// := (others => '0');
wire  one;
// := '1';
wire  zero;
// := '1';        -- zero

  //  y = ( 8432 * r + 16425 * g +  3176 * B) / 32768 + 16;
  // cb = (-4818 * r -  9527 * g + 14345 * B) / 32768 + 128;
  // cr = (14345 * r - 12045 * g -  2300 * B) / 32768 + 128; 
  assign one = 1'b 1;
  assign zero = 1'b 0;
  assign c1 = 'H002000000000;
  //X"002000000000";  
  assign a_r1 = {6'b 000000,r1_in,12'b 000000000000,3'b 000};
  assign a_g1 = {6'b 000000,g1_in,12'b 000000000000,3'b 000};
  assign a_b1 = {6'b 000000,b1_in,12'b 000000000000,3'b 000};
  assign c2 = 'H010000000000;
  assign a_r2 = {6'b 000000,r2_in,12'b 000000000000,3'b 000};
  assign a_g2 = {6'b 000000,g2_in,12'b 000000000000,3'b 000};
  assign a_b2 = {6'b 000000,b2_in,12'b 000000000000,3'b 000};
  assign b_r1 = {16'b 0010_0000_1111_0000,2'b 00};
  //0x20F0
  assign b_g1 = {16'b 0100_0000_0010_1001,2'b 00};
  //0x4029
  assign b_b1 = {16'H0C68,2'b 00};
  //0x0C68
  assign b_r2 = pair_start_in == 1'b 1 ? {16'hED2E,2'b 00} : {16'h3809,2'b 00};
  assign b_g2 = pair_start_in == 1'b 1 ? {16'hDAC9,2'b 00} : {16'hD0F3,2'b 00};
  assign b_b2 = pair_start_in == 1'b 1 ? {16'h3809,2'b 00} : {16'hF704,2'b 00};
  always @(posedge clk) begin
    //hsync_out <= hs_delay(hs_delay'high);
    //vsync_out <= vs_delay(vs_delay'high);
    //de_out    <= de_delay(de_delay'high);
    hsync_out <= hs_delay[3] ;
    vsync_out <= vs_delay[3] ;
    de_out <= de_delay[3] ;
    //de_delay  <= de_delay(de_delay'high-1 downto 0) & de_in;
    //vs_delay  <= vs_delay(de_delay'high-1 downto 0) & vsync_in;
    //hs_delay  <= hs_delay(de_delay'high-1 downto 0) & hsync_in;
    de_delay <= {de_delay[3:0] ,de_in};
    vs_delay <= {vs_delay[3:0] ,vsync_in};
    hs_delay <= {hs_delay[3:0] ,hsync_in};
    y_out <= p_b1[40:33] ;
    c_out <= p_b2[40:33] ;
  end

  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK(48'H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN(48'H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(0),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(0),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(0),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(0),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1), // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1), // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1), // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1) // Number of pipeline stages for P (0 or 1)
)
  mult_r1(
      // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(pc_r1),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(),
    // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(30'd0), // 30-bit input: A cascade data input
    .BCIN(18'd0), // 18-bit input: B cascade input
    .CARRYCASCIN(1'b0),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(1'b0),
    // 1-bit input: Multiplier sign input
    .PCIN(18'd0), // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'h0),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(1'b1),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),   // 5-bit input: INMODE control input
    .OPMODE(7'b0110101), // 7-bit input: Operation mode input
    .RSTINMODE(1'b0),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_r1),
    // 30-bit input: A data input
    .B(b_r1),
    // 18-bit input: B data input
    .C(c1),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(25'd0), // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(zero),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(zero),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(zero),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(zero),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(zero),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));

  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK('H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN('H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(1),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(1),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(1),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(1),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),
    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),
    // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),
    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1))
  mult_g1(
      // Cascade: 30-bit (each) input: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(pc_g1),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(), // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(0),
    // 30-bit input: A cascade data input
    .BCIN(0),
    // 18-bit input: B cascade input
    .CARRYCASCIN(zero),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(zero),
    // 1-bit input: Multiplier sign input
    .PCIN(pc_r1),
    // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'b0000),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(one),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),
    // 5-bit input: INMODE control input
    .OPMODE(7'b0010101),
    // 7-bit input: Operation mode input
    .RSTINMODE(zero),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_g1),
    // 30-bit input: A data input
    .B(b_g1),
    // 18-bit input: B data input
    .C(0),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(0), // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(zero),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(one),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(one),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(zero),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(one),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));

  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK('H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN('H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(2),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(2),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(1),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(1),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),
    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),
    // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),
    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1))
  mult_b1(
      // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(p_b1), // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(0),
    // 30-bit input: A cascade data input
    .BCIN(0),
    // 18-bit input: B cascade input
    .CARRYCASCIN(zero),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(zero),
    // 1-bit input: Multiplier sign input
    .PCIN(pc_g1),
    // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'b0000),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(one),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),
    // 5-bit input: INMODE control input
    .OPMODE(7'b0010101),
    // 7-bit input: Operation mode input
    .RSTINMODE(zero),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_b1),
    // 30-bit input: A data input
    .B(b_b1),
    // 18-bit input: B data input
    .C(0),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(0),
    // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(one),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(one),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(zero),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(zero),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(one),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));

  //---------------------------------------
  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK('H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN('H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(0),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(0),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(0),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(0),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),
    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),
    // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),
    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1))
  mult_r2(
      // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(pc_r2),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(),
    // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(0),
    // 30-bit input: A cascade data input
    .BCIN(0),
    // 18-bit input: B cascade input
    .CARRYCASCIN(zero),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(zero),
    // 1-bit input: Multiplier sign input
    .PCIN(0),
    // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'b0000),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(one),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),
    // 5-bit input: INMODE control input
    .OPMODE(7'b0110101),
    // 7-bit input: Operation mode input
    .RSTINMODE(zero),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_r2),
    // 30-bit input: A data input
    .B(b_r2),
    // 18-bit input: B data input
    .C(c2),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(0),
    // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(zero),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(zero),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(zero),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(zero),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(zero),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));

  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK('H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN('H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(1),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(1),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(1),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(1),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),
    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),
    // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),
    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1))
  mult_g2(
      // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(pc_g2),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(),
    // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(0),
    // 30-bit input: A cascade data input
    .BCIN(0),
    // 18-bit input: B cascade input
    .CARRYCASCIN(zero),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(zero),
    // 1-bit input: Multiplier sign input
    .PCIN(pc_r2),
    // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'b0000),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(one),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),
    // 5-bit input: INMODE control input
    .OPMODE(7'b0010101),
    // 7-bit input: Operation mode input
    .RSTINMODE(zero),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_g2),
    // 30-bit input: A data input
    .B(b_g2),
    // 18-bit input: B data input
    .C(0),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(0),
    // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(zero),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(one),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(zero),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(zero),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(one),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));

  DSP48E1 #(
      // Feature Control Attributes: Data Path Selection
    .A_INPUT("DIRECT"),
    // Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
    .B_INPUT("DIRECT"),
    // Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
    .USE_DPORT("FALSE"),
    // Select D port usage (TRUE or FALSE)
    .USE_MULT("MULTIPLY"),
    // Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
    .USE_SIMD("ONE48"),
    // SIMD selection ("ONE48", "TWO24", "FOUR12")
    // Pattern Detector Attributes: Pattern Detection Configuration
    .AUTORESET_PATDET("NO_RESET"),
    // "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH" 
    .MASK('H3fffffffffff),
    // 48-bit mask value for pattern detect (1=ignore)
    .PATTERN('H000000000000),
    // 48-bit pattern match for pattern detect
    .SEL_MASK("MASK"),
    // "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2" 
    .SEL_PATTERN("PATTERN"),
    // Select pattern value ("PATTERN" or "C")
    .USE_PATTERN_DETECT("NO_PATDET"),
    // Enable pattern detect ("PATDET" or "NO_PATDET")
    // Register Control Attributes: Pipeline Register Configuration
    .ACASCREG(2),
    // Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
    .ADREG(0),
    // Number of pipeline stages for pre-adder (0 or 1)
    .ALUMODEREG(1),
    // Number of pipeline stages for ALUMODE (0 or 1)
    .AREG(2),
    // Number of pipeline stages for A (0, 1 or 2)
    .BCASCREG(2),
    // Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
    .BREG(2),
    // Number of pipeline stages for B (0, 1 or 2)
    .CARRYINREG(1),
    // Number of pipeline stages for CARRYIN (0 or 1)
    .CARRYINSELREG(1),
    // Number of pipeline stages for CARRYINSEL (0 or 1)
    .CREG(0),
    // Number of pipeline stages for C (0 or 1)
    .DREG(0),
    // Number of pipeline stages for D (0 or 1)
    .INMODEREG(1),
    // Number of pipeline stages for INMODE (0 or 1)
    .MREG(1),
    // Number of multiplier pipeline stages (0 or 1)
    .OPMODEREG(1),
    // Number of pipeline stages for OPMODE (0 or 1)
    .PREG(1))
  mult_b2(
      // Cascade: 30-bit (each) output: Cascade Ports
    .ACOUT(),
    // 30-bit output: A port cascade output
    .BCOUT(),
    // 18-bit output: B port cascade output
    .CARRYCASCOUT(),
    // 1-bit output: Cascade carry output
    .MULTSIGNOUT(),
    // 1-bit output: Multiplier sign cascade output
    .PCOUT(),
    // 48-bit output: Cascade output
    // Control: 1-bit (each) output: Control Inputs/Status Bits
    .OVERFLOW(),
    // 1-bit output: Overflow in add/acc output
    .PATTERNBDETECT(),
    // 1-bit output: Pattern bar detect output
    .PATTERNDETECT(),
    // 1-bit output: Pattern detect output
    .UNDERFLOW(),
    // 1-bit output: Underflow in add/acc output
    // Data: 4-bit (each) output: Data Ports
    .CARRYOUT(),
    // 4-bit output: Carry output
    .P(p_b2),
    // 48-bit output: Primary data output
    // Cascade: 30-bit (each) input: Cascade Ports
    .ACIN(0),
    // 30-bit input: A cascade data input
    .BCIN(0),
    // 18-bit input: B cascade input
    .CARRYCASCIN(zero),
    // 1-bit input: Cascade carry input
    .MULTSIGNIN(zero),
    // 1-bit input: Multiplier sign input
    .PCIN(pc_g2),
    // 48-bit input: P cascade input
    // Control: 4-bit (each) input: Control Inputs/Status Bits
    .CLK(clk),
    // 1-bit input: Clock input
    .ALUMODE(4'b0000),
    // 4-bit input: ALU control input
    .CARRYINSEL(3'b000),
    // 3-bit input: Carry select input
    .CEINMODE(one),
    // 1-bit input: Clock enable input for INMODEREG
    .INMODE(5'b00000),
    // 5-bit input: INMODE control input
    .OPMODE(7'b0010101),
    // 7-bit input: Operation mode input
    .RSTINMODE(zero),
    // 1-bit input: Reset input for INMODEREG
    // Data: 30-bit (each) input: Data Ports
    .A(a_b2),
    // 30-bit input: A data input
    .B(b_b2),
    // 18-bit input: B data input
    .C(0),
    // 48-bit input: C data input
    .CARRYIN(zero),
    // 1-bit input: Carry input signal
    .D(0),
    // 25-bit input: D data input
    // Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
    .CEA1(one),
    // 1-bit input: Clock enable input for 1st stage AREG
    .CEA2(one),
    // 1-bit input: Clock enable input for 2nd stage AREG
    .CEAD(zero),
    // 1-bit input: Clock enable input for ADREG
    .CEALUMODE(one),
    // 1-bit input: Clock enable input for ALUMODE
    .CEB1(one),
    // 1-bit input: Clock enable input for 1st stage BREG
    .CEB2(one),
    // 1-bit input: Clock enable input for 2nd stage BREG
    .CEC(zero),
    // 1-bit input: Clock enable input for CREG
    .CECARRYIN(one),
    // 1-bit input: Clock enable input for CARRYINREG
    .CECTRL(one),
    // 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
    .CED(zero),
    // 1-bit input: Clock enable input for DREG
    .CEM(one),
    // 1-bit input: Clock enable input for MREG
    .CEP(one),
    // 1-bit input: Clock enable input for PREG
    .RSTA(zero),
    // 1-bit input: Reset input for AREG
    .RSTALLCARRYIN(zero),
    // 1-bit input: Reset input for CARRYINREG
    .RSTALUMODE(zero),
    // 1-bit input: Reset input for ALUMODEREG
    .RSTB(zero),
    // 1-bit input: Reset input for BREG
    .RSTC(zero),
    // 1-bit input: Reset input for CREG
    .RSTCTRL(zero),
    // 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
    .RSTD(zero),
    // 1-bit input: Reset input for DREG and ADREG
    .RSTM(zero),
    // 1-bit input: Reset input for MREG
    .RSTP(zero));


endmodule
