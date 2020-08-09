// File i2c_sender.vhd translated with vhd2vl v2.0 VHDL to Verilog RTL translator
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
// Module Name: i2c_sender h- Behavioral 
//
// Description: Send register writes over an I2C-like interface
//
// Feel free to use this how you see fit, and fix any errors you find :-)
//--------------------------------------------------------------------------------

module i2c_sender(
clk,
resend,
sioc,
siod
);

input clk;
input resend;
output sioc;
//inout siod;
output siod;

wire   clk;
wire   resend;
reg   sioc;
reg   siod;


reg [8:0] divider = 0;
// this value gives nearly 200ms cycles before the first register is written
reg [7:0] initial_pause = 0;
reg  finished = 0;
reg [7:0] address = 0;
reg [28:0] clk_first_quarter = 29'h1FFFFFFF; // := (others => '1');
reg [28:0] clk_last_quarter = 29'h1FFFFFFF; // := (others => '1');
reg [28:0] busy_sr = 29'h1FFFFFFF; // := (others => '1');
reg [28:0] data_sr = 29'h1FFFFFFF; // := (others => '1');
reg [28:0] tristate_sr = 0;
reg [15:0] reg_value = 0;

parameter i2c_wr_addr = 8'h72;
//type reg_value_pair is ARRAY(0 TO 63) OF std_logic_vector(15 DOWNTO 0);
parameter [0:0]
  array = 0;
wire [15:0] reg_value_pairs [0:63] = {
//   initial
//     begin
//            -------------------
//            -- Powerup please!
//            -------------------
        //reg_value_pairs[0] = 16'h4110;
				      16'h4110,
//            ---------------------------------------
//            -- These valuse must be set as follows
//            ---------------------------------------
	       16'h9803, 16'h9AE0, 16'h9C30, 16'h9D61, 16'hA2A4, 
	       16'hA3A4, 16'hE0D0, 16'h5512, 16'hF900,
        //reg_value_pairs[1] = 16'h9803;
	//reg_value_pairs[2] = 16'h9AE0;
//            
//            ---------------
//            -- Input mode
//            ---------------
            16'h1506, // YCbCr 422, DDR, External sync
            16'h4810, // Left justified data (D23 downto 8)
//            according to documenation, style 2 should be 16'h1637 but it isn't. ARGH!
           16'h1637, // 444 output, 8 bit style 2, 1st half on rising edge - YCrCb clipping
            16'h1700, // output asp ect ratio 16:9, external DE 
            16'hD03C, // auto sync data - must be set for DDR modes. No DDR clock delay
//            ---------------
//            -- Output mode
//            ---------------
            16'hAF04, // DVI mode
            16'h4c04, // Deep colour off (HDMI only?)     - not needed
            16'h4000, // Turn off additional data packets - not needed
//
//            --------------------------------------------------------------
//            -- Here is the YCrCb => RGB conversion, as per programming guide
//            -- This is table 57 - HDTV YCbCr (16 to 255) to RGB (0 to 255)
//            --------------------------------------------------------------
//            -- (Cr * A1       +      Y * A2       +     Cb * A3)/4096 +     A4    =  Red
             16'h18E7, 16'h1934,   16'h1A04, 16'h1BAD,   16'h1C00, 16'h1D00,   16'h1E1C, 16'h1F1B,
//            -- (Cr * B1       +      Y * B2       +     Cb * B3)/4096 +     B4    =  Green
            16'h201D, 16'h21DC,   16'h2204, 16'h23AD,   16'h241F, 16'h2524,   16'h2601, 16'h2735,
//            -- (Cr * C1       +      Y * C2       +     Cb * C3)/4096 +     C4    =  Blue
            16'h2800, 16'h2900,   16'h2A04, 16'h2BAD,   16'h2C08, 16'h2D7C,   16'h2E1B, 16'h2F77,
//
//            -- Extra space filled with FFFFs to signify end of data
            16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF,
            16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF,
            16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF, 16'hFFFF
//   );
};

  always @(posedge clk) begin
    reg_value <= reg_value_pairs[address] ;
  end

  always @(data_sr or tristate_sr) begin
    if(tristate_sr[28]  == 1'b 0) begin
      siod <= data_sr[28] ;
    end
    else begin
      siod <= 1'bz;
    end
  end

  always @(*) begin
    case(divider[8:7] )
      2'b 00 : sioc <= clk_first_quarter[28] ;
      2'b 11 : sioc <= clk_last_quarter[28] ;
      default : sioc <= 1'b 1;
    endcase
  end

  always @(posedge clk) begin
    if(resend == 1'b 1) begin
      address <= {8{1'b0}};
      clk_first_quarter <= {29{1'b1}};
      clk_last_quarter <= {29{1'b1}};
      busy_sr <= {29{1'b0}};
      divider <= {9{1'b0}};
      initial_pause <= {8{1'b0}};
      finished <= 1'b 0;
    end
    if(busy_sr[28]  == 1'b 0) begin
      if(initial_pause[7]  == 1'b 0) begin
        initial_pause <= initial_pause + 1;
      end
      else if(finished == 1'b 0) begin
        if(divider == 8'b 11111111) begin
          divider <= {9{1'b0}};
          if(reg_value[15:8]  == 8'b 11111111) begin
            finished <= 1'b 1;
          end
          else begin
            // move the new data into the shift registers
            clk_first_quarter <= {29{1'b0}};
            clk_first_quarter[28]  <= 1'b 1;
            clk_last_quarter <= {29{1'b0}};
            clk_last_quarter[0]  <= 1'b 1;
            //             Start    Address    Ack        Register            Ack          Value            Ack    Stop
            tristate_sr <= {1'b 0,8'b 00000000,1'b 1,8'b 00000000,1'b 1,8'b 00000000,1'b 1,1'b 0};
            data_sr <= {1'b 0,i2c_wr_addr,1'b 1,reg_value[15:8] ,1'b 1,reg_value[7:0] ,1'b 1,1'b 0};
            busy_sr <= {29{1'b1}};
            address <= (address + 1);
          end
        end
        else begin
          divider <= divider + 1;
        end
      end
    end
    else begin
      if(divider == 8'b 11111111) begin
        // divide clkin by 256 for I2C
        tristate_sr <= {tristate_sr[27:0] ,1'b 0};
        busy_sr <= {busy_sr[27:0] ,1'b 0};
        data_sr <= {data_sr[27:0] ,1'b 1};
        clk_first_quarter <= {clk_first_quarter[27:0] ,1'b 1};
        clk_last_quarter <= {clk_last_quarter[27:0] ,1'b 1};
        divider <= {9{1'b0}};
      end
      else begin
        divider <= divider + 1;
      end
    end
  end


endmodule
