module game_go_next
(
    input        clk,
    input        rst,

    input        new_game_field_vld,
    input    [39:0] game_field_new [29:0],
    input   [39:0] game_field_start [29:0],
    output    [39:0] game_field_old [29:0]
);

    logic [39:0] game_field_old_latched [29:0];

    always_ff @ (posedge rst or posedge clk)
        if (rst)
        begin
            game_field_old_latched <= game_field_start;
        end
        else if (new_game_field_vld)
        begin
            game_field_old_latched <= game_field_new;
        end

    assign game_field_old = game_field_old_latched;

endmodule
