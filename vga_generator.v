module vga_generator(input clk,                     
                    output reg [17:0] addra,
                    input [7:0] douta,
                    output reg [7:0] r,
                    output reg [7:0] g,
                    output reg [7:0] b,
                    output reg de,
                    output reg vsync = 0,
                    output reg hsync = 0,
                    input done,
                    input ready
                     );
    parameter H = 500  ;
    parameter V= 500;
    reg ena=1'b1;
    reg wea=1'b0;
    reg [7:0] dina=8'b0;
    
    wire  blanking = 0;
    reg [23:0] colour;
    reg [11:0] hcounter = 0;
    reg [11:0] vcounter = 0;
    parameter ZERO = 0;
    wire [11:0] hVisible;
    wire [11:0] hStartSync;
    wire [11:0] hEndSync;
    wire [11:0] hMax;
    wire  hSyncActive = 1;

    wire [11:0] vVisible;
    wire [11:0] vStartSync;
    wire [11:0] vEndSync;
    wire [11:0] vMax;
    wire  vSyncActive = 1;
    
    // Set the video mode to 1280x720x60Hz (75MHz pixel clock needed)
//    assign hVisible = ZERO + 1280;
//    assign hStartSync = ZERO + 1280 + 72;
//    assign hEndSync = ZERO + 1280 + 72 + 80;
//    assign hMax = ZERO + 1280 + 72 + 80 + 216 - 1;
//    assign vVisible = ZERO + 720;
//    assign vStartSync = ZERO + 720 + 3;
//    assign vEndSync = ZERO + 720 + 3 + 5;
//    assign vMax = ZERO + 720 + 3 + 5 + 22 - 1;
    // Set the video mode to 1920x1080x60Hz (150MHz pixel clock needed)
       assign hVisible =  ZERO + 1920;
       assign hStartSync  = ZERO + 1920+88;
       assign hEndSync    = ZERO + 1920+88+44;
       assign hMax        = ZERO + 1920+88+44+148-1;
//       assign vSyncActive = '1';
       assign vVisible    = ZERO + 1080;
       assign vStartSync  = ZERO + 1080+4;
       assign vEndSync    = ZERO + 1080+4+5;
       assign vMax        = ZERO + 1080+4+5+36-1;
//       assign hSyncActive = '1';
    always @(hcounter or vcounter) 
        begin
            if((hcounter<H)&&(vcounter<V))
                begin
                    addra <= vcounter * H + hcounter;
                    colour[23:16] <= douta;
                    colour[15:8] <= douta;
                    colour[7:0] <= douta;
                end
            else
                begin
                    colour[23:0]<=24'b0;
                end
        end
    
    always @(posedge clk) 
        begin
            if(vcounter >= vVisible || hcounter >= hVisible) 
                begin
                  r <= {8'b0};
                  g <= {8'b0};
                  b <= {8'b0};
                  de <= 1'b 0;
                end
            else 
                begin
                  b <= colour[23:16] ;
                  g <= colour[15:8] ;
                  r <= colour[7:0] ;
                  de <= 1'b1;
                end
            // Generate the sync Pulses
            if(vcounter == vStartSync)
                begin
                  vsync <= vSyncActive;
                end
            else 
                if(vcounter == vEndSync) begin
                  vsync <=  ~((vSyncActive));
                end
            if(hcounter == hStartSync) 
                begin
                  hsync <= hSyncActive;
                end
            else if(hcounter == hEndSync)
                begin
                  hsync <=  ~((hSyncActive));
                end
        // Advance the position counters
            if(hcounter == hMax) 
                begin
                    hcounter <= {1'b0};
                    if(vcounter == vMax)
                        begin
                            vcounter <= {1'b0};
                        end
                    else 
                        begin
                            vcounter <= vcounter + 1;
                        end
                end
            else
                begin
                    hcounter <= hcounter + 1;
                end
        end
endmodule
