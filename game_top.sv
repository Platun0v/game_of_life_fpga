`include "game_config.svh"

module game_top
# (
    parameter clk_mhz = 50,
              strobe_to_update_xy_counter_width = 20
)
(
    input        clk,
    input        rst,

    input        launch_key,
    input  [1:0] left_right_keys,
    input        enable_net_switch,

    output       hsync,
    output       vsync,
    output [2:0] rgb
);
    //------------------------------------------------------------------------

    wire                  display_on;
    wire [`X_WIDTH - 1:0] pixel_x;
    wire [`Y_WIDTH - 1:0] pixel_y;

    vga
    # (
        .N_MIXER_PIPE_STAGES ( `N_MIXER_PIPE_STAGES ),

        .HPOS_WIDTH          ( `X_WIDTH             ),
        .VPOS_WIDTH          ( `Y_WIDTH             ),

        .CLK_MHZ             ( clk_mhz              )
    )
    i_vga
    (
        .clk        ( clk        ),
        .rst        ( rst        ),
        .hsync      ( hsync      ),
        .vsync      ( vsync      ),
        .display_on ( display_on ),
        .hpos       ( pixel_x    ),
        .vpos       ( pixel_y    )
    );

    //------------------------------------------------------------------------

    wire go_next_state;

    key_pressed i_key_pressed
    (
        .clk         (clk),
        .rst         (rst),

        .key         (launch_key),

        .key_pressed (go_next_state)
    );

    //------------------------------------------------------------------------

    wire [39:0] new_game_field [29:0];
    wire [39:0] game_field [29:0];
    wire [39:0] game_field_start [29:0];

    assign game_field_start [0] = 40'h0;
    assign game_field_start [1] = 40'h0;
    assign game_field_start [2] = 40'h0;
    assign game_field_start [3] = 40'b0001110000000000000000000000000000000000;
    assign game_field_start [4] = 40'b0000010000000000000000000000000000000000;
    assign game_field_start [5] = 40'b0000100000000000000000000000000000000000;
    assign game_field_start [6] = 40'b0000000000000000000000000000000000000000;
    assign game_field_start [7] = 40'h0;
    assign game_field_start [8] = 40'h0;
    assign game_field_start [9] = 40'h0;
    assign game_field_start [10] = 40'h0;
    assign game_field_start [11] = 40'h0;
    assign game_field_start [12] = 40'h0;
    assign game_field_start [13] = 40'h0;
    assign game_field_start [14] = 40'h0;
    assign game_field_start [15] = 40'h0;
    assign game_field_start [16] = 40'h0;
    assign game_field_start [17] = 40'h0;
    assign game_field_start [18] = 40'h0;
    assign game_field_start [19] = 40'h0;
    assign game_field_start [20] = 40'h0;
    assign game_field_start [21] = 40'h0;
    assign game_field_start [22] = 40'h0;
    assign game_field_start [23] = 40'h0;
    assign game_field_start [24] = 40'h0;
    assign game_field_start [25] = 40'h0;
    assign game_field_start [26] = 40'h0;
    assign game_field_start [27] = 40'h0;
    assign game_field_start [28] = 40'h0;
    assign game_field_start [29] = 40'h0;

    wire new_game_field_vld;

    game_simulate simulate
    (
        .clk       ( clk       ),
        .rst       ( rst       ),
        .game_field( game_field),
        .game_field_next( new_game_field),
        .go_next_state (go_next_state),
        .game_field_next_vld (new_game_field_vld),
        .counter   ( clk   )
    );

    game_display display
    (
        .clk        ( clk        ),
        .rst        ( rst        ),
        .pixel_x    ( pixel_x    ),
        .pixel_y    ( pixel_y    ),
        .game_field ( game_field ),
        .rgb        ( rgb        )
    );

    game_go_next go_next
    (
        .clk         (clk),
        .rst         (rst),

        .new_game_field_vld (new_game_field_vld),
        .game_field_start (game_field_start),
        .game_field_new (new_game_field),
        .game_field_old (game_field)
    );


    // //------------------------------------------------------------------------

    // wire [15:0] random;

    // game_random random_generator (clk, rst, random);

    // //------------------------------------------------------------------------

    // wire                     sprite_target_write_xy;
    // wire                     sprite_target_write_dxy;

    // logic [`X_WIDTH   - 1:0] sprite_target_write_x;
    // wire  [`Y_WIDTH   - 1:0] sprite_target_write_y;

    // logic [             1:0] sprite_target_write_dx;
    // wire                     sprite_target_write_dy;

    // wire                     sprite_target_enable_update;

    // wire  [`X_WIDTH   - 1:0] sprite_target_x;
    // wire  [`Y_WIDTH   - 1:0] sprite_target_y;

    // wire                     sprite_target_within_screen;

    // wire  [`X_WIDTH   - 1:0] sprite_target_out_left;
    // wire  [`X_WIDTH   - 1:0] sprite_target_out_right;
    // wire  [`Y_WIDTH   - 1:0] sprite_target_out_top;
    // wire  [`Y_WIDTH   - 1:0] sprite_target_out_bottom;

    // wire                     sprite_target_rgb_en;
    // wire  [             2:0] sprite_target_rgb;

    // //------------------------------------------------------------------------

    // always_comb
    // begin
    //     if (random [7])
    //     begin
    //         sprite_target_write_x  = 10'd0;
    //         sprite_target_write_dx = 2'b01;
    //     end
    //     else
    //     begin
    //         sprite_target_write_x  = `SCREEN_WIDTH - 8;
    //         sprite_target_write_dx = { 1'b1, random [6] };
    //     end
    // end

    // assign sprite_target_write_y  = `SCREEN_HEIGHT / 10 + random [5:0];
    // assign sprite_target_write_dy = 1'd0;

    // //------------------------------------------------------------------------

    // game_sprite_top
    // #(
    //     .SPRITE_WIDTH  ( 8 ),
    //     .SPRITE_HEIGHT ( 8 ),

    //     .DX_WIDTH      ( 2 ),
    //     .DY_WIDTH      ( 1 ),

    //     .ROW_0 ( 32'h000bb000 ),
    //     .ROW_1 ( 32'h00099000 ),
    //     .ROW_2 ( 32'h00099000 ),
    //     .ROW_3 ( 32'hb99ff99b ),
    //     .ROW_4 ( 32'hb99ff99b ),
    //     .ROW_5 ( 32'h00099000 ),
    //     .ROW_6 ( 32'h00099000 ),
    //     .ROW_7 ( 32'h000bb000 ),

    //     .strobe_to_update_xy_counter_width
    //     (strobe_to_update_xy_counter_width)
    // )
    // sprite_target
    // (
    //     .clk                   ( clk                          ),
    //     .rst                   ( rst                          ),

    //     .pixel_x               ( pixel_x                      ),
    //     .pixel_y               ( pixel_y                      ),

    //     .sprite_write_xy       ( sprite_target_write_xy       ),
    //     .sprite_write_dxy      ( sprite_target_write_dxy      ),

    //     .sprite_write_x        ( sprite_target_write_x        ),
    //     .sprite_write_y        ( sprite_target_write_y        ),

    //     .sprite_write_dx       ( sprite_target_write_dx       ),
    //     .sprite_write_dy       ( sprite_target_write_dy       ),

    //     .sprite_enable_update  ( sprite_target_enable_update  ),

    //     .sprite_x              ( sprite_target_x              ),
    //     .sprite_y              ( sprite_target_y              ),

    //     .sprite_within_screen  ( sprite_target_within_screen  ),

    //     .sprite_out_left       ( sprite_target_out_left       ),
    //     .sprite_out_right      ( sprite_target_out_right      ),
    //     .sprite_out_top        ( sprite_target_out_top        ),
    //     .sprite_out_bottom     ( sprite_target_out_bottom     ),

    //     .rgb_en                ( sprite_target_rgb_en         ),
    //     .rgb                   ( sprite_target_rgb            )
    // );

    // //------------------------------------------------------------------------

    // wire                    sprite_torpedo_write_xy;
    // wire                    sprite_torpedo_write_dxy;

    // wire [`X_WIDTH   - 1:0] sprite_torpedo_write_x;
    // wire [`Y_WIDTH   - 1:0] sprite_torpedo_write_y;

    // logic  [             1:0] sprite_torpedo_write_dx;
    // logic  [             2:0] sprite_torpedo_write_dy;

    // wire                    sprite_torpedo_enable_update;

    // wire [`X_WIDTH   - 1:0] sprite_torpedo_x;
    // wire [`Y_WIDTH   - 1:0] sprite_torpedo_y;

    // wire                    sprite_torpedo_within_screen;

    // wire [`X_WIDTH   - 1:0] sprite_torpedo_out_left;
    // wire [`X_WIDTH   - 1:0] sprite_torpedo_out_right;
    // wire [`Y_WIDTH   - 1:0] sprite_torpedo_out_top;
    // wire [`Y_WIDTH   - 1:0] sprite_torpedo_out_bottom;

    // wire                    sprite_torpedo_rgb_en;
    // wire [             2:0] sprite_torpedo_rgb;

    // //------------------------------------------------------------------------

    // assign sprite_torpedo_write_x  = `SCREEN_WIDTH / 2 + random [15:10];
    // assign sprite_torpedo_write_y  = `SCREEN_HEIGHT - 16;

    // always_comb
    // begin
    //     case (left_right_keys)
    //     2'b00: sprite_torpedo_write_dx = 2'b00;
    //     2'b01: sprite_torpedo_write_dx = 2'b01;
    //     2'b10: sprite_torpedo_write_dx = 2'b11;
    //     2'b11: sprite_torpedo_write_dx = 2'b00;
    //     endcase

    //     case (left_right_keys)
    //     2'b00: sprite_torpedo_write_dy = 3'b111;
    //     2'b01: sprite_torpedo_write_dy = 3'b110;
    //     2'b10: sprite_torpedo_write_dy = 3'b110;
    //     2'b11: sprite_torpedo_write_dy = 3'b110;
    //     endcase
    // end

    // //------------------------------------------------------------------------

    // game_sprite_top
    // #(
    //     .SPRITE_WIDTH  ( 8 ),
    //     .SPRITE_HEIGHT ( 8 ),

    //     .DX_WIDTH      ( 2 ),
    //     .DY_WIDTH      ( 3 ),

    //     .ROW_0 ( 32'h000cc000 ),
    //     .ROW_1 ( 32'h00cccc00 ),
    //     .ROW_2 ( 32'h0cceecc0 ),
    //     .ROW_3 ( 32'hcccccccc ),
    //     .ROW_4 ( 32'hcc0cc0cc ),
    //     .ROW_5 ( 32'hcc0cc0cc ),
    //     .ROW_6 ( 32'hcc0cc0cc ),
    //     .ROW_7 ( 32'hcc0cc0cc ),

    //     .strobe_to_update_xy_counter_width
    //     (strobe_to_update_xy_counter_width)
    // )
    // sprite_torpedo
    // (
    //     .clk                   ( clk                           ),
    //     .rst                   ( rst                           ),

    //     .pixel_x               ( pixel_x                       ),
    //     .pixel_y               ( pixel_y                       ),

    //     .sprite_write_xy       ( sprite_torpedo_write_xy       ),
    //     .sprite_write_dxy      ( sprite_torpedo_write_dxy      ),

    //     .sprite_write_x        ( sprite_torpedo_write_x        ),
    //     .sprite_write_y        ( sprite_torpedo_write_y        ),

    //     .sprite_write_dx       ( sprite_torpedo_write_dx       ),
    //     .sprite_write_dy       ( sprite_torpedo_write_dy       ),

    //     .sprite_enable_update  ( sprite_torpedo_enable_update  ),

    //     .sprite_x              ( sprite_torpedo_x              ),
    //     .sprite_y              ( sprite_torpedo_y              ),

    //     .sprite_within_screen  ( sprite_torpedo_within_screen  ),

    //     .sprite_out_left       ( sprite_torpedo_out_left       ),
    //     .sprite_out_right      ( sprite_torpedo_out_right      ),
    //     .sprite_out_top        ( sprite_torpedo_out_top        ),
    //     .sprite_out_bottom     ( sprite_torpedo_out_bottom     ),

    //     .rgb_en                ( sprite_torpedo_rgb_en         ),
    //     .rgb                   ( sprite_torpedo_rgb            )
    // );

    // //------------------------------------------------------------------------

    // wire collision;

    // game_overlap overlap
    // (
    //     .clk       ( clk                        ),
    //     .rst       ( rst                        ),

    //     .left_1    ( sprite_target_out_left     ),
    //     .right_1   ( sprite_target_out_right    ),
    //     .top_1     ( sprite_target_out_top      ),
    //     .bottom_1  ( sprite_target_out_bottom   ),

    //     .left_2    ( sprite_torpedo_out_left    ),
    //     .right_2   ( sprite_torpedo_out_right   ),
    //     .top_2     ( sprite_torpedo_out_top     ),
    //     .bottom_2  ( sprite_torpedo_out_bottom  ),

    //     .overlap   ( collision                  )
    // );

    // //------------------------------------------------------------------------

    // wire end_of_game_timer_start;
    // wire end_of_game_timer_running;

    // game_timer # (.width (25)) timer
    // (
    //     .clk     ( clk                       ),
    //     .rst     ( rst                       ),
    //     .value   ( 25'h1000000               ),
    //     .start   ( end_of_game_timer_start   ),
    //     .running ( end_of_game_timer_running )
    // );

    // //------------------------------------------------------------------------

    // wire game_won;

    // game_mixer mixer
    // (
    //     .clk                           ( clk                           ),
    //     .rst                           ( rst                           ),

    //     .display_on                    ( display_on                    ),

    //     .sprite_target_rgb_en          ( sprite_target_rgb_en          ),
    //     .sprite_target_rgb             ( sprite_target_rgb             ),

    //     .sprite_torpedo_rgb_en         ( sprite_torpedo_rgb_en         ),
    //     .sprite_torpedo_rgb            ( sprite_torpedo_rgb            ),

    //     .game_won                      ( game_won                      ),
    //     .end_of_game_timer_running     ( end_of_game_timer_running     ),
    //     .random                        ( random [0]                    ),

    //     .rgb                           ( rgb                           )
    // );

    // //------------------------------------------------------------------------

    // `GAME_MASTER_FSM_MODULE master_fsm
    // (
    //     .clk                           ( clk                           ),
    //     .rst                           ( rst                           ),

    //     .launch_key                    ( launch_key                    ),

    //     .sprite_target_write_xy        ( sprite_target_write_xy        ),
    //     .sprite_torpedo_write_xy       ( sprite_torpedo_write_xy       ),

    //     .sprite_target_write_dxy       ( sprite_target_write_dxy       ),
    //     .sprite_torpedo_write_dxy      ( sprite_torpedo_write_dxy      ),

    //     .sprite_target_enable_update   ( sprite_target_enable_update   ),
    //     .sprite_torpedo_enable_update  ( sprite_torpedo_enable_update  ),

    //     .sprite_target_within_screen   ( sprite_target_within_screen   ),
    //     .sprite_torpedo_within_screen  ( sprite_torpedo_within_screen  ),

    //     .collision                     ( collision                     ),

    //     .game_won                      ( game_won                      ),
    //     .end_of_game_timer_start       ( end_of_game_timer_start       ),

    //     .end_of_game_timer_running     ( end_of_game_timer_running     )
    // );

endmodule
