module keyboard(
    input CLOCK_50,
    input [0:0] KEY,
    inout PS2_DAT,
    inout PS2_CLK,
    output W,
    output A,
    output S,
    output D,
    output Fire,
    output start,
    output ResetGame,
    output I,
    output J,
    output K,
    output L
);

    KeyboardDecoder u0(
        .clk(CLOCK_50),
        .reset(~KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .W(W),
        .A(A),
        .S(S),
        .D(D),
        .I(I),
        .J(J),
        .K(K),
        .L(L),
        .Fire(Fire),
        .start(start),
        .ResetGame(ResetGame)
    );
endmodule

module KeyboardDecoder(
    input clk,
    input reset,
    inout PS2_CLK,
    inout PS2_DAT,
    output W,
    output A,
    output S,
    output D,
    output I,
    output J,
    output K,
    output L,
    output Fire,
    output start,
    output ResetGame
);
    wire [7:0] key_data;
    wire key_pressed;

    // 实例化PS2控制器
    PS2_Controller PS2 (
        .CLOCK_50(clk),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(key_data),
        .received_data_en(key_pressed)
    );

    // 实例化统一的控制模块
    unified_control uc(
        .clk(clk),
        .reset(reset),
        .Data(key_data),
        .keypressed(key_pressed),
        .W(W),
        .A(A),
        .S(S),
        .D(D),
        .I(I),
        .J(J),
        .K(K),
        .L(L),
        .Fire(Fire),
        .start(start),
        .ResetGame(ResetGame)
    );
endmodule

module unified_control(
    input clk,
    input reset,
    input keypressed,
    input [7:0] Data,
    output reg W,
    output reg A,
    output reg S,
    output reg D,
    output reg I,
    output reg J,
    output reg K,
    output reg L,
    output reg Fire,
    output reg start,
    output reg ResetGame
);
    // 定义按键扫描码
    localparam W_CODE     = 8'h1D,
               A_CODE     = 8'h1C,
               S_CODE     = 8'h1B,
               D_CODE     = 8'h23,
               I_CODE     = 8'h43,
               J_CODE     = 8'h3B,
               K_CODE     = 8'h42,
               L_CODE     = 8'h4B,
               SPACE_CODE = 8'h29,
               ENTER_CODE = 8'h5A,
               ESC_CODE   = 8'h76;

    // 标志位，用于指示下一个扫描码是BREAK码
    reg is_break;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            is_break <= 1'b0;
            // 重置所有输出信号
            W         <= 1'b0;
            A         <= 1'b0;
            S         <= 1'b0;
            D         <= 1'b0;
            I         <= 1'b0;
            J         <= 1'b0;
            K         <= 1'b0;
            L         <= 1'b0;
            Fire      <= 1'b0;
            start     <= 1'b0;
            ResetGame <= 1'b0;
        end else if (keypressed) begin
            if (Data == 8'hF0) begin
                // 接收到BREAK码前缀
                is_break <= 1'b1;
            end else begin
                if (is_break) begin
                    // 处理BREAK码，释放按键
                    is_break <= 1'b0;
                    case (Data)
                        W_CODE:     W         <= 1'b0;
                        A_CODE:     A         <= 1'b0;
                        S_CODE:     S         <= 1'b0;
                        D_CODE:     D         <= 1'b0;
                        I_CODE:     I         <= 1'b0;
                        J_CODE:     J         <= 1'b0;
                        K_CODE:     K         <= 1'b0;
                        L_CODE:     L         <= 1'b0;
                        SPACE_CODE: Fire      <= 1'b0;
                        ENTER_CODE: start     <= 1'b0;
                        ESC_CODE:   ResetGame <= 1'b0;
                        default: ; // 不处理其他按键
                    endcase
                end else begin
                    // 处理MAKE码，按下按键
                    case (Data)
                        W_CODE:     W         <= 1'b1;
                        A_CODE:     A         <= 1'b1;
                        S_CODE:     S         <= 1'b1;
                        D_CODE:     D         <= 1'b1;
                        I_CODE:     I         <= 1'b1;
                        J_CODE:     J         <= 1'b1;
                        K_CODE:     K         <= 1'b1;
                        L_CODE:     L         <= 1'b1;
                        SPACE_CODE: Fire      <= 1'b1;
                        ENTER_CODE: start     <= 1'b1;
                        ESC_CODE:   ResetGame <= 1'b1;
                        default: ; // 不处理其他按键
                    endcase
                end
            end
        end
    end
endmodule


/*module unified_control(
    input clk,
    input reset,
    input keypressed,
    input [7:0] Data,
    output reg W,
    output reg A,
    output reg S,
    output reg D,
    output reg I,
    output reg J,
    output reg K,
    output reg L,
    output reg Fire,
    output reg start,
    output reg ResetGame
);
    // 状态编码
    localparam STATE_IDLE  = 2'd0,
               STATE_MAKE  = 2'd1,
               STATE_BREAK = 2'd2;

    reg [1:0] state;
    reg [7:0] cur_key_code;

    // 按键扫描码定义
    localparam W_CODE     = 8'h1D,
               A_CODE     = 8'h1C,
               S_CODE     = 8'h1B,
               D_CODE     = 8'h23,
               I_CODE     = 8'h43,
               J_CODE     = 8'h3B,
               K_CODE     = 8'h42,
               L_CODE     = 8'h4B,
               SPACE_CODE = 8'h29,
               ENTER_CODE = 8'h5A,
               ESC_CODE   = 8'h76;

    // 状态机逻辑
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            cur_key_code <= 8'h00;
            // 重置输出信号
            W         <= 1'b0;
            A         <= 1'b0;
            S         <= 1'b0;
            D         <= 1'b0;
            I         <= 1'b0;
            J         <= 1'b0;
            K         <= 1'b0;
            L         <= 1'b0;
            Fire      <= 1'b0;
            start     <= 1'b0;
            ResetGame <= 1'b0;
        end else if (keypressed) begin
            case (state)
                STATE_IDLE: begin
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        cur_key_code <= Data;
                        state <= STATE_MAKE;
                        // 设置对应的输出信号
                        case (Data)
                            W_CODE:     W         <= 1'b1;
                            A_CODE:     A         <= 1'b1;
                            S_CODE:     S         <= 1'b1;
                            D_CODE:     D         <= 1'b1;
                            I_CODE:     I         <= 1'b1;
                            J_CODE:     J         <= 1'b1;
                            K_CODE:     K         <= 1'b1;
                            L_CODE:     L         <= 1'b1;
                            SPACE_CODE: Fire      <= 1'b1;
                            ENTER_CODE: start     <= 1'b1;
                            ESC_CODE:   ResetGame <= 1'b1;
                            default: ; // 不处理其他按键
                        endcase
                    end
                end
                STATE_MAKE: begin
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                STATE_BREAK: begin
                    cur_key_code <= Data;
                    // 清除对应的输出信号
                    case (Data)
                        W_CODE:     W         <= 1'b0;
                        A_CODE:     A         <= 1'b0;
                        S_CODE:     S         <= 1'b0;
                        D_CODE:     D         <= 1'b0;
                        I_CODE:     I         <= 1'b0;
                        J_CODE:     J         <= 1'b0;
                        K_CODE:     K         <= 1'b0;
                        L_CODE:     L         <= 1'b0;
                        SPACE_CODE: Fire      <= 1'b0;
                        ENTER_CODE: start     <= 1'b0;
                        ESC_CODE:   ResetGame <= 1'b0;
                        default: ; // 不处理其他按键
                    endcase
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule*/
