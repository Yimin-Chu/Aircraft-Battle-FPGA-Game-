module keyboardfinal(
    input CLOCK_50,
    input [0:0] KEY,
    inout PS2_DAT,
    inout PS2_CLK,
    /*output W,
    output A,
    output S,
    output D,*/
    output Fire,
    output start,
    output ResetGame,
	 /*output I,
	 output J,
	 output K,
	 output L,*/
	 output [9:0]LEDR
	 
);

	 wire W,A,S,D,I,J,K,L;
	 
	 assign LEDR[0]=W;
	 assign LEDR[1]=A;
	 assign LEDR[2]=S;
	 assign LEDR[3]=D;
	 assign LEDR[4]=I;
	 assign LEDR[5]=J;
	 assign LEDR[6]=K;
	 assign LEDR[7]=L;
	 assign LEDR[8]=1'b1;
	 assign LEDR[9]=1'b1;
	 
    KeyboardDecoder u0(
        .clk(CLOCK_50),
        .reset(~KEY[0]),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .W(W),
        .A(A),
        .S(S),
        .D(D),
		  //second player
		  .I(I),
		  .J(J),
		  .K(K),
		  .L(L),
        .Fire(Fire),
        .start(start),
        .ResetGame(ResetGame)
        // .Player1(LEDR[7]), // Removed
        // .Player2(LEDR[8])  // Removed
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
    // output Player1, // Removed
    // output Player2  // Removed
);
    wire [7:0] key_data;
    wire key_pressed;

    // Instantiate the PS2 Controller
    PS2_Controller PS2 (
        .CLOCK_50(clk),
        .reset(reset),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .received_data(key_data),
        .received_data_en(key_pressed)
    );

    // Instantiate the control module
    control c1(
        .clk(clk),
        .reset(reset),
        .Data(key_data),
        .keypressed(key_pressed),
        .W(W),
        .A(A),
        .S(S),
        .D(D),
        .Fire(Fire),
        .start(start),
        .RG(ResetGame)
        // .Player1(Player1), // Removed
        // .Player2(Player2)  // Removed
    );
	 
	 control2 c2(
		  .clk(clk),
        .reset(reset),
        .Data(key_data),
        .keypressed(key_pressed),
		  .I(I),
		  .J(J),
		  .K(K),
		  .L(L)
	 );
endmodule

module control2(
    input clk,
    input reset,
    input keypressed,
    input [7:0] Data,
    output reg I,
    output reg J,
    output reg K,
    output reg L
    // output reg Player1, // Removed
    // output reg Player2  // Removed
);
    // State encoding
    localparam STATE_IDLE  = 2'd0,
               STATE_MAKE  = 2'd1,
               STATE_BREAK = 2'd2;

    reg [1:0] state;
    reg [7:0] cur_key_code;

    // Key make codes
    localparam I_CODE     = 8'h43, // 'W' key make code
               J_CODE     = 8'h3B, // 'A' key make code
               K_CODE     = 8'h42, // 'S' key make code
               L_CODE     = 8'h4B, // 'D' key make code
               SPACE_CODE = 8'h29, // Space Bar make code
               ENTER_CODE = 8'h5A,
               ESC_CODE   = 8'h76;
               // Removed ONE_CODE and TWO_CODE

    // State transition and output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            cur_key_code <= 8'h00;
            // Reset outputs
            I        <= 1'b0;
            J        <= 1'b0;
            K        <= 1'b0;
            L        <= 1'b0;
            // Player1  <= 1'b0; // Removed
            // Player2  <= 1'b0; // Removed
        end else if (keypressed) begin
            case (state)
                STATE_IDLE: begin
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        cur_key_code <= Data;
                        state <= STATE_MAKE;
                        // Set the output corresponding to the key code
                        case (Data)
                            I_CODE:     I       <= 1'b1;
                            J_CODE:     J       <= 1'b1;
                            K_CODE:     K       <= 1'b1;
                            L_CODE:     L       <= 1'b1;
                            // No action for other keys
                            default: ; // Do nothing
                        endcase
                    end
                end
                STATE_MAKE: begin
                    // Wait for the next data byte
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                STATE_BREAK: begin
                    // After 0xF0, we get the key code of the released key
                    cur_key_code <= Data;
                    // Clear the output corresponding to the key code
                    case (Data)
                        I_CODE:     I       <= 1'b0;
                        J_CODE:     J       <= 1'b0;
                        K_CODE:     K       <= 1'b0;
                        L_CODE:     L       <= 1'b0;
                        // No action for other keys
                        default: ; // Do nothing
                    endcase
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule


module control(
    input clk,
    input reset,
    input keypressed,
    input [7:0] Data,
    output reg W,
    output reg A,
    output reg S,
    output reg D,
    output reg Fire,
    output reg start,
    output reg RG
    // output reg Player1, // Removed
    // output reg Player2  // Removed
);
    // State encoding
    localparam STATE_IDLE  = 2'd0,
               STATE_MAKE  = 2'd1,
               STATE_BREAK = 2'd2;

    reg [1:0] state;
    reg [7:0] cur_key_code;

    // Key make codes
    localparam W_CODE     = 8'h1D, // 'W' key make code
               A_CODE     = 8'h1C, // 'A' key make code
               S_CODE     = 8'h1B, // 'S' key make code
               D_CODE     = 8'h23, // 'D' key make code
               SPACE_CODE = 8'h29, // Space Bar make code
               ENTER_CODE = 8'h5A,
               ESC_CODE   = 8'h76;
               // Removed ONE_CODE and TWO_CODE

    // State transition and output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            cur_key_code <= 8'h00;
            // Reset outputs
            W        <= 1'b0;
            A        <= 1'b0;
            S        <= 1'b0;
            D        <= 1'b0;
            Fire     <= 1'b0;
            start  <= 1'b0;
            RG       <= 1'b0;
            // Player1  <= 1'b0; // Removed
            // Player2  <= 1'b0; // Removed
        end else if (keypressed) begin
            case (state)
                STATE_IDLE: begin
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        cur_key_code <= Data;
                        state <= STATE_MAKE;
                        // Set the output corresponding to the key code
                        case (Data)
                            W_CODE:     W       <= 1'b1;
                            A_CODE:     A       <= 1'b1;
                            S_CODE:     S       <= 1'b1;
                            D_CODE:     D       <= 1'b1;
                            SPACE_CODE: Fire    <= 1'b1;
                            ENTER_CODE: start <= 1'b1;
                            ESC_CODE:   RG      <= 1'b1;
                            // No action for other keys
                            default: ; // Do nothing
                        endcase
                    end
                end
                STATE_MAKE: begin
                    // Wait for the next data byte
                    if (Data == 8'hF0) begin
                        state <= STATE_BREAK;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                STATE_BREAK: begin
                    // After 0xF0, we get the key code of the released key
                    cur_key_code <= Data;
                    // Clear the output corresponding to the key code
                    case (Data)
                        W_CODE:     W       <= 1'b0;
                        A_CODE:     A       <= 1'b0;
                        S_CODE:     S       <= 1'b0;
                        D_CODE:     D       <= 1'b0;
                        SPACE_CODE: Fire    <= 1'b0;
                        ENTER_CODE: start <= 1'b0;
                        ESC_CODE:   RG      <= 1'b0;
                        // No action for other keys
                        default: ; // Do nothing
                    endcase
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
