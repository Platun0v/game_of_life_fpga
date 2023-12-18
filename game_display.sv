`include "game_config.svh"

module game_display
#(
    parameter SPRITE_WIDTH  = 4,  // pixels 2^4
              SPRITE_HEIGHT = 4,  // pixels 2^4

              EN_RGB = 3'b111,
              NET_RGB = 3'b001,
              DIS_RGB = 3'b000
)

//----------------------------------------------------------------------------

(
    input                         clk,
    input                         rst,

    input      [`X_WIDTH   - 1:0] pixel_x,
    input      [`Y_WIDTH   - 1:0] pixel_y,
    
    input                         enable_net,
    input      [39:0]             game_field [29:0],

    output logic [`RGB_WIDTH - 1:0] rgb
);

    // Convert coordinates of the pixel to coordinates of the cell on the field

    logic [`X_WIDTH - 1:0] pixel_x_on_field;
    logic [`Y_WIDTH - 1:0] pixel_y_on_field;

    always_comb
    begin
        pixel_x_on_field = pixel_x >> SPRITE_WIDTH;
        pixel_y_on_field = pixel_y >> SPRITE_HEIGHT;
    end
    

    wire field_pixel = game_field [pixel_y_on_field] [pixel_x_on_field];
    
    wire net_x = pixel_x[SPRITE_HEIGHT:0] == 5'b10000 || pixel_x[SPRITE_HEIGHT:0] == 5'b00000 ? 1'b1 : 1'b0;
    wire net_y = pixel_y[SPRITE_WIDTH:0] == 5'b10000 || pixel_y[SPRITE_WIDTH:0] == 5'b00000  ? 1'b1 : 1'b0;

    //------------------------------------------------------------------------

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            rgb <= 1'b0;
        else if (net_x || net_y)
            rgb <= NET_RGB;
        else if (field_pixel == 1'b1)
            rgb <= EN_RGB;
        else
            rgb <= DIS_RGB;

endmodule
