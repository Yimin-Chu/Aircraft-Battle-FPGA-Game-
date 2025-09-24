Aircraft Battle (FPGA Game) Done by Yimin Chu and Zhongyi Wang

Aircraft Battle is a two-player co-op survival game built entirely in Verilog and deployed on the DE1-SoC FPGA development board. The game uses a VGA adapter for pixel rendering and a PS/2 keyboard for user input, creating a classic arcade feel with real hardware logic.

🎮 Gameplay

Two Players:

Player 1 controls their ship with WASD.

Player 2 controls with IJKL.

Objective: Survive while AI-controlled “chaser” ships pursue the players.

Win Condition: Stay alive until the progress bar fills.

Lose Condition: If either player is caught, the game displays a skull overlay.

🖥️ Features

Custom Sprites: 8×8 pixel ships, tick (✔) win icon, and skull (☠) defeat icon.

Dynamic Difficulty: Enemy ships spawn and chase players with increasing challenge.

Graphics:

VGA display at 160×120 resolution

3-bit color sprites rendered pixel-by-pixel

User Feedback:

LEDR displays key states in real time

HEX display shows game timer/progress bar

Start (Enter) / Reset (Esc) controls

⚙️ Technical Highlights

Implemented entirely in Verilog HDL

50 MHz system clock

Real-time VGA pixel scanning and sprite overlay logic

Multi-object collision detection between ships and projectiles

Modular design with keyboard decoder, VGA driver, and game logic separated
