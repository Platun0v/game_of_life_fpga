module key_pressed(
    input clk,
    input rst,

    input key,

    output logic key_pressed
);

    logic key_pressed_o;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        begin
            key_pressed_o <= 1'b0;
        end
        else
        begin
            key_pressed_o <= key;
        end

    assign key_pressed = ~ key & key_pressed_o;

endmodule