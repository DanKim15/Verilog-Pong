# Verilog Pong FPGA Project

A hardware implementation of classic Pong on an FPGA, written in Verilog. This project features VGA video output driving, a game state machine, score display on seven-segment displays, and pseudo-random serves.

Watch the demo: [https://youtu.be/ontBRRvBoz8?si=9O94XZ_7O2J_kUfg](https://youtu.be/ontBRRvBoz8?si=9O94XZ_7O2J_kUfg)

---

## Repository Structure

```
/ (root)
│
├─ src/
│   ├─ PongGame.v              # Top-level integration of submodules: debouncers, FSM, VGA driver, 7 segment displays
│   ├─ DebounceFilter.v        # Counter-based switch/button debouncer
│   ├─ BinaryToSevSeg.v        # 4-bit binary to seven-segment display decoder
│   ├─ PongStateMachine.v      # Main FSM: state sequencing, ball/paddle logic, scoring, serve RNG
│   ├─ VGAController.v         # VGA timing, sync generation, pixel logic for a 640×480 display
│   ├─ Counter.v               # Up-counter for horizontal and vertical timing domains
│   └─ Lfsr.v                  # 3-bit LFSR for pseudo-random serve direction and angle
```

---

## Description

### PongStateMachine

The `PongStateMachine` module implements the game logic in an FSM that transitions through five states:

- **RESET**: Prepares for a new game by clearing scores and centering the ball and paddles.
- **SERVE**: Holds the ball at center for one frame tick and assigns an initial velocity using a 3-bit LFSR to choose horizontal direction and vertical angle.
- **PLAY**: Updates positions each frame tick:
  1. **Horizontal movement**: Attempts `ball_x += vel_x`. If this move overlaps a paddle face, inverts `vel_x` and recalculates `vel_y` based on the hit offset from paddle center (angle proportional to distance from of the ball to the paddle's center).
  2. **Vertical movement**: Attempts `ball_y += vel_y`. If this move overlaps the top/bottom of a paddle or screen edges, inverts `vel_y` to bounce.
  3. **Score detection**: If the ball crosses a left or right boundary, records the scorer and goes to INCR\_SCORE.
- **INCR\_SCORE**: Increments the appropriate player score, pauses the display for a short countdown, then returns to **SERVE** or **FINISH** if a player has reached the game limit.
- **FINISH**: Blinks the paddles indefinitely until reset using the push button.

Positions and velocities are all signed integers, and the paddle movement is controlled by debounced switches, clamped to screen bounds. The FSM runs synced to a frame tick of 60Hz provided by the VGA controller.

### VGAController
![VGA Timing Standard](https://github.com/DanKim15/Verilog-Pong/blob/main/vga_timing_standard.png)
The `VGAController` module handles video timing and pixel generation for a standard 640×480\@60 Hz VGA display, following this VGA timing standard:

1. **Pixel clock generation**: Divides the 50 MHz input clock by 2 to create a 25 MHz pixel clock.
2. **Counters**: Uses a horizontal counter (0–799) and vertical counter (0–524).  When the horizontal counter wraps, it pulses the vertical counter, and when the vertical counter wraps, it pulses a frame tick back to the FSM.
3. **Sync pulses**:
   - **HSYNC** is set to low for counts 0–96
   - **VSYNC** is set to low for lines 0–2
4. **Visible window**: Considers pixels visible when `144 < hcounter < 799` and `35 < vcounter < 515`.
5. **Frame rendering**: On each pixel clock, the logic compares the current (`hcounter`, `vcounter`) to input ball and paddle coordinates to produce a pixel mask:
   - If `(hcounter,vcounter)` falls within the 8×8 ball or 8×64 paddle rectangles coordinates, the controller outputs the **primary colour**;
   - Otherwise outputs the **secondary colour**.
6. **Color schemes**: A push-button cycles through several preset colour palettes by updating 4‑bit RGB registers.

---

## State Machine Diagram
![State Machine Diagram](https://github.com/DanKim15/Verilog-Pong/blob/main/state_machine_diagram.jpg)


---

## License

Distributed under the MIT License. See `LICENSE` for details.

