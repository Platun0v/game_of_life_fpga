`include "game_config.svh"

module game_simulate_cell

//----------------------------------------------------------------------------

(
    input                         clk,
    input                         rst,

    input      [3:0] neighbours [3:0],

    output           life_cell,
    output  life_cell_vld
);

    // count number if live neighbours

    wire [3:0] live_neighbours;

    assign live_neighbours = neighbours[0][0] + neighbours[0][1] + neighbours[0][2] + 
                             neighbours[1][0] + neighbours[1][2] + 
                             neighbours[2][0] + neighbours[2][1] + neighbours[2][2];

    // simulate cell

    logic life_cell_o, life_cell_vld_o;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            life_cell_o    <= 1'b0;
            life_cell_vld_o <= 1'b0;
        end
        else
        begin
            if (live_neighbours == 3)
            begin
                life_cell_o    <= 1'b1;
                life_cell_vld_o <= 1'b1;
            end
            else if (live_neighbours == 2 && neighbours[1][1] == 1'b1)
            begin
                life_cell_o    <= 1'b1;
                life_cell_vld_o <= 1'b1;
            end
            else
            begin
                life_cell_o   <= 1'b0;
                life_cell_vld_o <= 1'b1;
            end
        end

    assign life_cell    = life_cell_o;
    assign life_cell_vld = life_cell_vld_o;

endmodule
