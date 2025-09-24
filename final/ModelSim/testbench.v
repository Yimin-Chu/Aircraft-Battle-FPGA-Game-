`timescale 1ns / 1ps

module testbench();

    reg CLOCK_50;
    reg [7:0] sim_received_data;
    reg sim_received_data_en;
    // VGA outputs (if needed)
    wire [7:0] VGA_R;
    wire [7:0] VGA_G;
    wire [7:0] VGA_B;
    wire VGA_HS;
    wire VGA_VS;
    wire VGA_BLANK_N;
    wire VGA_SYNC_N;
    wire VGA_CLK;

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50; // 50 MHz clock
    end

// Instantiate the DUT with SIMULATION parameter set to 1
vga_demo #(.SIMULATION(1)) U1 (
    .CLOCK_50(CLOCK_50),
    .PS2_CLK(), // Not used in simulation
    .PS2_DAT(), // Not used in simulation
    .sim_received_data(sim_received_data),
    .sim_received_data_en(sim_received_data_en),
    .SIMULATION(1),
    // VGA outputs
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N),
    .VGA_CLK(VGA_CLK)
);


    // Simulate key presses
    initial begin
        // Initialize simulation inputs
        sim_received_data = 8'h00;
        sim_received_data_en = 1'b0;

        // Wait for some time after reset
        #100000; // Wait for 100 us

        // Simulate pressing 'W' key
        sim_received_data = 8'h1D; // 'W' key make code
        sim_received_data_en = 1;
        #20;
        sim_received_data_en = 0;

        // Wait for some time to observe movement
        #500000; // Wait for 500 us

        // Simulate releasing 'W' key
        sim_received_data = 8'hF0; // Break code
        sim_received_data_en = 1;
        #20;
        sim_received_data_en = 0;
        #20;
        sim_received_data = 8'h1D; // 'W' key make code
        sim_received_data_en = 1;
        #20;
        sim_received_data_en = 0;

        // Continue simulation for observation
        #500000; // Wait for 500 us

        // Finish simulation
        $stop;
    end

endmodule
