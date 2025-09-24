module vga_demo(
    input CLOCK_50,
    input [0:0] SW,           // Switch 0 for firing
    inout PS2_DAT,
    inout PS2_CLK,
    output [4:0] LEDR,        // 添加 LEDR 输出端口
    output [7:0] VGA_R, VGA_G, VGA_B,
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK
);
	 // 声明用于接收键盘信号的线
    wire W, A, S, D, Fire, start, ResetGame;

    // 实例化 Keyboard 模块
    Keyboard keyboard_inst(
        .CLOCK_50(CLOCK_50),
        .KEY(1'b1), // 根据需要连接复位信号
        .PS2_DAT(PS2_DAT),
        .PS2_CLK(PS2_CLK),
        .W(W),
        .A(A),
        .S(S),
        .D(D),
        .Fire(Fire),
        .start(start),
        .ResetGame(ResetGame)
    );
	 
	 // 将键盘信号赋值给 LEDR
    assign LEDR[0] = W;
    assign LEDR[1] = A;
    assign LEDR[2] = S;
    assign LEDR[3] = D;
	 assign LEDR[4] = 1'b1;


    // Define an 8x8 spaceship pattern with colors
    reg [2:0] spaceship_pattern [0:7][0:7];
    reg [2:0] spaceship2_pattern [0:7][0:7]; // Define a new pattern for spaceship2
    reg [2:0] skull_pattern [0:7][0:7]; // Define a new pattern for a skull face
    reg [7:0] die_pattern [0:27]; // 28 columns of 8 bits each for "DIE"

    // Initialize the spaceship pattern with a gun at the tip
    initial begin
        // Original spaceship pattern (Blue spaceship)
        spaceship_pattern[0][0] = 3'b000; spaceship_pattern[0][1] = 3'b000; spaceship_pattern[0][2] = 3'b110; spaceship_pattern[0][3] = 3'b110;
        spaceship_pattern[0][4] = 3'b110; spaceship_pattern[0][5] = 3'b110; spaceship_pattern[0][6] = 3'b000; spaceship_pattern[0][7] = 3'b000;
        spaceship_pattern[1][0] = 3'b000; spaceship_pattern[1][1] = 3'b110; spaceship_pattern[1][2] = 3'b110; spaceship_pattern[1][3] = 3'b110;
        spaceship_pattern[1][4] = 3'b110; spaceship_pattern[1][5] = 3'b110; spaceship_pattern[1][6] = 3'b110; spaceship_pattern[1][7] = 3'b000;
        spaceship_pattern[2][0] = 3'b110; spaceship_pattern[2][1] = 3'b110; spaceship_pattern[2][2] = 3'b110; spaceship_pattern[2][3] = 3'b110;
        spaceship_pattern[2][4] = 3'b110; spaceship_pattern[2][5] = 3'b110; spaceship_pattern[2][6] = 3'b110; spaceship_pattern[2][7] = 3'b110;
        spaceship_pattern[3][0] = 3'b110; spaceship_pattern[3][1] = 3'b110; spaceship_pattern[3][2] = 3'b110; spaceship_pattern[3][3] = 3'b111;
        spaceship_pattern[3][4] = 3'b111; spaceship_pattern[3][5] = 3'b110; spaceship_pattern[3][6] = 3'b110; spaceship_pattern[3][7] = 3'b110;
        spaceship_pattern[4][0] = 3'b110; spaceship_pattern[4][1] = 3'b110; spaceship_pattern[4][2] = 3'b111; spaceship_pattern[4][3] = 3'b111;
        spaceship_pattern[4][4] = 3'b111; spaceship_pattern[4][5] = 3'b111; spaceship_pattern[4][6] = 3'b110; spaceship_pattern[4][7] = 3'b110;
        spaceship_pattern[5][0] = 3'b110; spaceship_pattern[5][1] = 3'b111; spaceship_pattern[5][2] = 3'b111; spaceship_pattern[5][3] = 3'b111;
        spaceship_pattern[5][4] = 3'b111; spaceship_pattern[5][5] = 3'b111; spaceship_pattern[5][6] = 3'b111; spaceship_pattern[5][7] = 3'b110;
        spaceship_pattern[6][0] = 3'b000; spaceship_pattern[6][1] = 3'b111; spaceship_pattern[6][2] = 3'b111; spaceship_pattern[6][3] = 3'b111;
        spaceship_pattern[6][4] = 3'b111; spaceship_pattern[6][5] = 3'b111; spaceship_pattern[6][6] = 3'b111; spaceship_pattern[6][7] = 3'b000;
        spaceship_pattern[7][0] = 3'b000; spaceship_pattern[7][1] = 3'b000; spaceship_pattern[7][2] = 3'b111; spaceship_pattern[7][3] = 3'b111;
        spaceship_pattern[7][4] = 3'b111; spaceship_pattern[7][5] = 3'b111; spaceship_pattern[7][6] = 3'b000; spaceship_pattern[7][7] = 3'b000;

        // New spaceship pattern for spaceship2 (Red spaceship)
        spaceship2_pattern[0][0] = 3'b000; spaceship2_pattern[0][1] = 3'b000; spaceship2_pattern[0][2] = 3'b100; spaceship2_pattern[0][3] = 3'b100;
        spaceship2_pattern[0][4] = 3'b100; spaceship2_pattern[0][5] = 3'b100; spaceship2_pattern[0][6] = 3'b000; spaceship2_pattern[0][7] = 3'b000;
        spaceship2_pattern[1][0] = 3'b000; spaceship2_pattern[1][1] = 3'b100; spaceship2_pattern[1][2] = 3'b100; spaceship2_pattern[1][3] = 3'b100;
        spaceship2_pattern[1][4] = 3'b100; spaceship2_pattern[1][5] = 3'b100; spaceship2_pattern[1][6] = 3'b100; spaceship2_pattern[1][7] = 3'b000;
        spaceship2_pattern[2][0] = 3'b100; spaceship2_pattern[2][1] = 3'b100; spaceship2_pattern[2][2] = 3'b100; spaceship2_pattern[2][3] = 3'b100;
        spaceship2_pattern[2][4] = 3'b100; spaceship2_pattern[2][5] = 3'b100; spaceship2_pattern[2][6] = 3'b100; spaceship2_pattern[2][7] = 3'b100;
        spaceship2_pattern[3][0] = 3'b100; spaceship2_pattern[3][1] = 3'b100; spaceship2_pattern[3][2] = 3'b100; spaceship2_pattern[3][3] = 3'b111;
        spaceship2_pattern[3][4] = 3'b111; spaceship2_pattern[3][5] = 3'b100; spaceship2_pattern[3][6] = 3'b100; spaceship2_pattern[3][7] = 3'b100;
        spaceship2_pattern[4][0] = 3'b100; spaceship2_pattern[4][1] = 3'b100; spaceship2_pattern[4][2] = 3'b111; spaceship2_pattern[4][3] = 3'b111;
        spaceship2_pattern[4][4] = 3'b111; spaceship2_pattern[4][5] = 3'b111; spaceship2_pattern[4][6] = 3'b100; spaceship2_pattern[4][7] = 3'b100;
        spaceship2_pattern[5][0] = 3'b100; spaceship2_pattern[5][1] = 3'b111; spaceship2_pattern[5][2] = 3'b111; spaceship2_pattern[5][3] = 3'b111;
        spaceship2_pattern[5][4] = 3'b111; spaceship2_pattern[5][5] = 3'b111; spaceship2_pattern[5][6] = 3'b111; spaceship2_pattern[5][7] = 3'b100;
        spaceship2_pattern[6][0] = 3'b000; spaceship2_pattern[6][1] = 3'b111; spaceship2_pattern[6][2] = 3'b111; spaceship2_pattern[6][3] = 3'b111;
        spaceship2_pattern[6][4] = 3'b111; spaceship2_pattern[6][5] = 3'b111; spaceship2_pattern[6][6] = 3'b111; spaceship2_pattern[6][7] = 3'b000;
        spaceship2_pattern[7][0] = 3'b000; spaceship2_pattern[7][1] = 3'b000; spaceship2_pattern[7][2] = 3'b111; spaceship2_pattern[7][3] = 3'b111;
        spaceship2_pattern[7][4] = 3'b111; spaceship2_pattern[7][5] = 3'b111; spaceship2_pattern[7][6] = 3'b000; spaceship2_pattern[7][7] = 3'b000;



        // D
        die_pattern[0]  = 8'b11111100;
        die_pattern[1]  = 8'b11000110;
        die_pattern[2]  = 8'b11000011;
        die_pattern[3]  = 8'b11000011;
        die_pattern[4]  = 8'b11000011;
        die_pattern[5]  = 8'b11000011;
        die_pattern[6]  = 8'b11000110;
        die_pattern[7]  = 8'b11111100;
        die_pattern[8]  = 8'b00000000; // Gap between letters

        // I
        die_pattern[9]  = 8'b11111111;
        die_pattern[10] = 8'b00011000;
        die_pattern[11] = 8'b00011000;
        die_pattern[12] = 8'b00011000;
        die_pattern[13] = 8'b00011000;
        die_pattern[14] = 8'b00011000;
        die_pattern[15] = 8'b00011000;
        die_pattern[16] = 8'b11111111;
        die_pattern[17] = 8'b00000000; // Gap between letters

        // E
        die_pattern[18] = 8'b11111111;
        die_pattern[19] = 8'b11000000;
        die_pattern[20] = 8'b11000000;
        die_pattern[21] = 8'b11111100;
        die_pattern[22] = 8'b11111100;
        die_pattern[23] = 8'b11000000;
        die_pattern[24] = 8'b11000000;
        die_pattern[25] = 8'b11111111;
        die_pattern[26] = 8'b00000000; // Gap after letter
        die_pattern[27] = 8'b00000000;

    end

    // Spaceship position registers, initialized to center of 160x120 resolution
    reg [7:0] spaceship_x = 80;   // Initial x position of first spaceship
    reg [6:0] spaceship_y = 60;   // Initial y position of first spaceship

    // Second spaceship position
    reg [7:0] spaceship2_x = 0;  // Initial x position of second spaceship
    reg [6:0] spaceship2_y = 0;  // Initial y position of second spaceship

    reg [7:0] skull_x = 40;   // Initial x position of skull
    reg [6:0] skull_y = 30;   // Initial y position of skull

    // Projectile properties
    parameter MAX_PROJECTILES = 10;
    reg [7:0] projectile_x [0:MAX_PROJECTILES-1];
    reg [6:0] projectile_y [0:MAX_PROJECTILES-1];
    reg projectile_active [0:MAX_PROJECTILES-1];
    
    // Track previous switch state for detecting changes
    reg previous_switch_state;

    // VGA position signals
    reg [7:0] current_x;
    reg [6:0] current_y;
    reg [2:0] colour;

    // Debounce logic and movement counter
    reg [19:0] counter;
    reg [21:0] movement_counter;
    integer i;
    reg found_slot;
    parameter CLOSE_THRESHOLD = 5;
    reg stateNumber = 0;

    // Initialize projectiles to inactive
    initial begin
        for (i = 0; i < MAX_PROJECTILES; i = i + 1) begin
            projectile_active[i] = 0;
        end
        previous_switch_state = SW[0];
    end

    always @(posedge CLOCK_50) begin
        counter <= counter + 1;
        movement_counter <= movement_counter + 1;
        if (counter == 0) begin
            if (W && spaceship_y > 0)           // 向上移动
                spaceship_y <= spaceship_y - 1;
            if (S && spaceship_y < 112)         // 向下移动
                spaceship_y <= spaceship_y + 1;
            if (A && spaceship_x > 0)           // 向左移动
                spaceship_x <= spaceship_x - 1;
            if (D && spaceship_x < 152)         // 向右移动
                spaceship_x <= spaceship_x + 1;

            if (movement_counter == 0) begin
            // Second spaceship moves towards the first spaceship
            if (spaceship2_x < spaceship_x)           // Move right to catch the first spaceship
                spaceship2_x <= spaceship2_x + 1;
            else if (spaceship2_x > spaceship_x)      // Move left to catch the first spaceship
                spaceship2_x <= spaceship2_x - 1;

            if (spaceship2_y < spaceship_y)           // Move down to catch the first spaceship
                spaceship2_y <= spaceship2_y + 1;
            else if (spaceship2_y > spaceship_y)      // Move up to catch the first spaceship
                spaceship2_y <= spaceship2_y - 1;
            end

            if ((spaceship_x >= spaceship2_x - CLOSE_THRESHOLD && spaceship_x <= spaceship2_x + CLOSE_THRESHOLD) &&
                (spaceship_y >= spaceship2_y - CLOSE_THRESHOLD && spaceship_y <= spaceship2_y + CLOSE_THRESHOLD))

                stateNumber = 1;

            // Detect switch state change to trigger a new projectile
            if (SW[0] != previous_switch_state) begin
                found_slot = 0;

                // Find an inactive projectile slot
                for (i = 0; i < MAX_PROJECTILES && !found_slot; i = i + 1) begin
                    if (!projectile_active[i]) begin
                        projectile_active[i] <= 1;
                        projectile_x[i] <= spaceship_x + 3; // Position at the spaceship tip
                        projectile_y[i] <= spaceship_y - 1;
                        found_slot = 1; // Set flag to stop further activation in this cycle
                    end
                end
                previous_switch_state <= SW[0]; // Update the previous switch state
            end

            // Move each active projectile
            for (i = 0; i < MAX_PROJECTILES; i = i + 1) begin
                if (projectile_active[i]) begin
                    if ((projectile_x[i] >= spaceship2_x - CLOSE_THRESHOLD && projectile_x[i] <= spaceship2_x + CLOSE_THRESHOLD) &&
                        (projectile_y[i] >= spaceship2_y - CLOSE_THRESHOLD && projectile_y[i] <= spaceship2_y + CLOSE_THRESHOLD))
                            projectile_active[i] <= 0; // Deactivate if within close range


                    if (projectile_y[i] > 0 && projectile_y[i] < 120 && projectile_x[i] > 0 && projectile_x[i] < 160 && projectile_x[i] ) begin
                        // Update projectile x position towards spaceship2
                        if (projectile_x[i] < spaceship2_x)
                            projectile_x[i] <= projectile_x[i] + 1;
                        else if (projectile_x[i] > spaceship2_x)
                            projectile_x[i] <= projectile_x[i] - 1;

                        // Update projectile y position towards spaceship2
                        if (projectile_y[i] < spaceship2_y)
                            projectile_y[i] <= projectile_y[i] + 1;
                        else if (projectile_y[i] > spaceship2_y)
                            projectile_y[i] <= projectile_y[i] - 1; // Removed the erroneous semicolon here
                    end
                    else
                        projectile_active[i] <= 0; // Deactivate if it goes off-screen
                end
            end
        end
    end

    // VGA Adapter instantiation with color logic for spaceship, projectiles, and background
    always @(posedge CLOCK_50) begin
        // Update current_x and current_y to scan through the display
        if (current_x == 159) begin
            current_x <= 0;
            if (current_y == 119)
                current_y <= 0;
            else
                current_y <= current_y + 1;
        end else begin
            current_x <= current_x + 1;
        end

        // Set color based on whether the current pixel is within the spaceship or projectile area
        colour <= 3'b000; // Default background color

        if (stateNumber == 0)begin
        // Check if current pixel is within any active projectile
        for (i = 0; i < MAX_PROJECTILES; i = i + 1) begin
            if (projectile_active[i] && current_x == projectile_x[i] && current_y == projectile_y[i]) begin
                colour <= 3'b111; // White color for projectile
            end
        end

        // Check if current pixel is within the first spaceship area
        if (current_x >= spaceship_x && current_x < spaceship_x + 8 &&
            current_y >= spaceship_y && current_y < spaceship_y + 8) begin
            // Check the spaceship pattern to decide if this pixel should be filled
            colour <= spaceship_pattern[current_y - spaceship_y][current_x - spaceship_x];
        end

        // Check if current pixel is within the second spaceship area
        if (current_x >= spaceship2_x && current_x < spaceship2_x + 8 &&
            current_y >= spaceship2_y && current_y < spaceship2_y + 8) begin
            // Check the spaceship2 pattern to decide if this pixel should be filled
            colour <= spaceship2_pattern[current_y - spaceship2_y][current_x - spaceship2_x];
        end
        end

if (stateNumber == 1) begin
    // Set a default background color (e.g., red)
    colour <= 3'b000; // Red background

    // Check if the current pixel is within the "DIE" pattern area
    if (current_x >= skull_x && current_x < skull_x + 28 &&
        current_y >= skull_y && current_y < skull_y + 8) begin
        
        // Check if the corresponding bit in die_pattern is set to 1
        if (die_pattern[current_x - skull_x][7 - current_y - skull_y] == 1'b1) begin
            colour <= 3'b100; // Set to white if the bit is 1
        end
    end
end




    end

    vga_adapter VGA (
        .resetn(1'b1),             // No reset on VGA adapter
        .clock(CLOCK_50),
        .colour(colour),
        .x(current_x),
        .y(current_y),
        .plot(1'b1),               // Constant plot signal
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    // VGA adapter configuration parameters
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "NONE"; // Black background
endmodule
