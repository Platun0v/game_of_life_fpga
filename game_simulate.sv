`include "game_config.svh"

module game_simulate

//----------------------------------------------------------------------------

(
    input                         clk,
    input                         rst,

    input      [39:0]             game_field      [29:0],
    input                         counter,
    input                         go_next_state,

    
    output     [39:0]             game_field_next [29:0],
    output                        game_field_next_vld

);

    logic [3:0] neighbours [3:0];
    logic life_cell;
    logic life_cell_vld;

    game_simulate_cell cell_inst (
        .clk(clk),
        .rst(rst),
        .neighbours(neighbours),
        .life_cell(life_cell),
        .life_cell_vld(life_cell_vld)
    );

    // Create a field of cells
    logic [31:0] cur_cell_x;
    logic [31:0] cur_cell_y;

    typedef enum logic [1:0] { 
        PROCEED = 2'b00,
        FINISH  = 2'b01
    } state_t;

    state_t state, next_state;

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        GO_NEXT = 2'b01
    } state_t2;

    state_t2 state2, next_state2;

    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            state <= PROCEED;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        case (state)
            PROCEED: begin
                if (life_cell_vld) begin
                    next_state = FINISH;
                end
            end
            FINISH: begin
                next_state = PROCEED;
            end
            default: begin
                next_state = PROCEED;
            end
        endcase
    end

    //------------------------------------------------------------------------

    logic game_field_next_vld_o;

    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            cur_cell_x <= 0;
            cur_cell_y <= 0;
            game_field_next_vld_o <= 0;
            state2 <= IDLE;
        end
        else if (go_next_state && state2 == IDLE) begin
            cur_cell_x <= 0;
            cur_cell_y <= 0;
            game_field_next_vld_o <= 0;
            state2 <= GO_NEXT;
        end
        else if (state == PROCEED && state2 == GO_NEXT) begin
            if (cur_cell_y == 29 && cur_cell_x == 39) begin
                cur_cell_x <= 0;
                cur_cell_y <= 0;
                game_field_next_vld_o <= 1;
                state2 <= IDLE;
            end
            else if (cur_cell_x == 39) begin
                cur_cell_x <= 0;
                cur_cell_y <= cur_cell_y + 1;
            end
            else begin
                cur_cell_x <= cur_cell_x + 1;
            end
        end
    end

    assign game_field_next_vld = game_field_next_vld_o;

    logic [39:0] game_field_o [29:0];

    always_ff @ (posedge clk or posedge rst) begin
        if (rst) begin
            game_field_o <= game_field;
        end
        else if (state == FINISH && state2 == GO_NEXT) begin
            if (life_cell_vld) begin
                if (cur_cell_x == 0) 
                    game_field_o[cur_cell_y][39] <= life_cell;
                else 
                    game_field_o[cur_cell_y][cur_cell_x - 1] <= life_cell;
            end
            else begin
                if (cur_cell_x == 0) 
                    game_field_o[cur_cell_y][39] <= game_field[cur_cell_y][39];
                else 
                    game_field_o[cur_cell_y][cur_cell_x - 1] <= game_field[cur_cell_y][cur_cell_x - 1];
            end
        end
    end

    assign game_field_next = game_field_o;

    //------------------------------------------------------------------------

    always_comb begin
        if (cur_cell_x == 0 && cur_cell_y == 0) begin
            neighbours[0][0] = game_field[29][39];
            neighbours[0][1] = game_field[29][0];
            neighbours[0][2] = game_field[29][1];
            neighbours[1][0] = game_field[0][39];
            neighbours[1][1] = game_field[0][0];
            neighbours[1][2] = game_field[0][1];
            neighbours[2][0] = game_field[1][39];
            neighbours[2][1] = game_field[1][0];
            neighbours[2][2] = game_field[1][1];
        end
        else if (cur_cell_x == 39 && cur_cell_y == 0) begin
            neighbours[0][0] = game_field[29][38];
            neighbours[0][1] = game_field[29][39];
            neighbours[0][2] = game_field[29][0];
            neighbours[1][0] = game_field[0][38];
            neighbours[1][1] = game_field[0][39];
            neighbours[1][2] = game_field[0][0];
            neighbours[2][0] = game_field[1][38];
            neighbours[2][1] = game_field[1][39];
            neighbours[2][2] = game_field[1][0];
        end
        else if (cur_cell_x == 0 && cur_cell_y == 29) begin
            neighbours[0][0] = game_field[28][39];
            neighbours[0][1] = game_field[28][0];
            neighbours[0][2] = game_field[28][1];
            neighbours[1][0] = game_field[29][39];
            neighbours[1][1] = game_field[29][0];
            neighbours[1][2] = game_field[29][1];
            neighbours[2][0] = game_field[0][39];
            neighbours[2][1] = game_field[0][0];
            neighbours[2][2] = game_field[0][1];
        end
        else if (cur_cell_x == 39 && cur_cell_y == 29) begin
            neighbours[0][0] = game_field[28][38];
            neighbours[0][1] = game_field[28][39];
            neighbours[0][2] = game_field[28][0];
            neighbours[1][0] = game_field[29][38];
            neighbours[1][1] = game_field[29][39];
            neighbours[1][2] = game_field[29][0];
            neighbours[2][0] = game_field[0][38];
            neighbours[2][1] = game_field[0][39];
            neighbours[2][2] = game_field[0][0];
        end
        else if (cur_cell_x == 0) begin
            neighbours[0][0] = game_field[cur_cell_y - 1][39];
            neighbours[0][1] = game_field[cur_cell_y - 1][0];
            neighbours[0][2] = game_field[cur_cell_y - 1][1];
            neighbours[1][0] = game_field[cur_cell_y][39];
            neighbours[1][1] = game_field[cur_cell_y][0];
            neighbours[1][2] = game_field[cur_cell_y][1];
            neighbours[2][0] = game_field[cur_cell_y + 1][39];
            neighbours[2][1] = game_field[cur_cell_y + 1][0];
            neighbours[2][2] = game_field[cur_cell_y + 1][1];
        end
        else if (cur_cell_x == 39) begin
            neighbours[0][0] = game_field[cur_cell_y - 1][38];
            neighbours[0][1] = game_field[cur_cell_y - 1][39];
            neighbours[0][2] = game_field[cur_cell_y - 1][0];
            neighbours[1][0] = game_field[cur_cell_y][38];
            neighbours[1][1] = game_field[cur_cell_y][39];
            neighbours[1][2] = game_field[cur_cell_y][0];
            neighbours[2][0] = game_field[cur_cell_y + 1][38];
            neighbours[2][1] = game_field[cur_cell_y + 1][39];
            neighbours[2][2] = game_field[cur_cell_y + 1][0];
        end
        else if (cur_cell_y == 0) begin
            neighbours[0][0] = game_field[29][cur_cell_x - 1];
            neighbours[0][1] = game_field[29][cur_cell_x];
            neighbours[0][2] = game_field[29][cur_cell_x + 1];
            neighbours[1][0] = game_field[0][cur_cell_x - 1];
            neighbours[1][1] = game_field[0][cur_cell_x];
            neighbours[1][2] = game_field[0][cur_cell_x + 1];
            neighbours[2][0] = game_field[1][cur_cell_x - 1];
            neighbours[2][1] = game_field[1][cur_cell_x];
            neighbours[2][2] = game_field[1][cur_cell_x + 1];
        end
        else if (cur_cell_y == 29) begin
            neighbours[0][0] = game_field[28][cur_cell_x - 1];
            neighbours[0][1] = game_field[28][cur_cell_x];
            neighbours[0][2] = game_field[28][cur_cell_x + 1];
            neighbours[1][0] = game_field[29][cur_cell_x - 1];
            neighbours[1][1] = game_field[29][cur_cell_x];
            neighbours[1][2] = game_field[29][cur_cell_x + 1];
            neighbours[2][0] = game_field[0][cur_cell_x - 1];
            neighbours[2][1] = game_field[0][cur_cell_x];
            neighbours[2][2] = game_field[0][cur_cell_x + 1];
        end
        else begin
            neighbours[0][0] = game_field[cur_cell_y - 1][cur_cell_x - 1];
            neighbours[0][1] = game_field[cur_cell_y - 1][cur_cell_x];
            neighbours[0][2] = game_field[cur_cell_y - 1][cur_cell_x + 1];
            neighbours[1][0] = game_field[cur_cell_y][cur_cell_x - 1];
            neighbours[1][1] = game_field[cur_cell_y][cur_cell_x];
            neighbours[1][2] = game_field[cur_cell_y][cur_cell_x + 1];
            neighbours[2][0] = game_field[cur_cell_y + 1][cur_cell_x - 1];
            neighbours[2][1] = game_field[cur_cell_y + 1][cur_cell_x];
            neighbours[2][2] = game_field[cur_cell_y + 1][cur_cell_x + 1];
        end
    end


endmodule
