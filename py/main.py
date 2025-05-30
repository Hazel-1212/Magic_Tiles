import pygame
import time
import uart
import game
import notes_rx

# === Game Constants ===
SCREEN_WIDTH = 1520
SCREEN_HEIGHT = 750
REFRESH_INTERVAL = 0.01  
TILE_WIDTH = 190
TILE_SPEED = 6
TILE_HEIGHT_PER_QUARTER = (0.25 / REFRESH_INTERVAL) * TILE_SPEED
RAIL_NUM = SCREEN_WIDTH // TILE_WIDTH

def reset_game_state():
    return (
        [[] for _ in range(2)],  # tiles
        [[] for _ in range(2)],  # tile_notes
        [0, 0],                  # note_index
        [None, None],            # note_pressed
        [0, 0],                  # prev_clk
        [0, 0]                   # next_note_interval
    )

def game_loop(ser, song_notes, song_notes_length, score):
    """Main game loop"""
    pygame.init()
    screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
    pygame.display.set_caption("Magic Tiles")
    clock = pygame.time.Clock()

    move_clk = 0
    running = True
    tiles, tile_note, note_index, note_pressed, prev_clk, next_note_interval = reset_game_state()

    while running:
        clock.tick(100)
        screen.fill((255, 255, 255))
        move_clk += 1

        running = game.handle_events()
        game.draw_grid(screen, RAIL_NUM, TILE_WIDTH, SCREEN_HEIGHT)

        # === Receive from Nexys4 DDR ===
        received_data = uart.receive_data(ser)
        if received_data:
            if received_data == 'R':  # End the game
                break

            # note input
            note_pressed = [None, None]
            for ch in received_data[:2]:  # Max 2 characters
                if 'A' <= ch <= 'M':
                    note_pressed[0] = ord(ch) - ord('A') + 1
                elif 'a' <= ch <= 'm':
                    note_pressed[1] = ord(ch) - ord('a') + 1
                if note_pressed[1]==11:
                    note_pressed[1]=0
            #print(f"Note pressed: {note_pressed}")

            for hand in range(2):
                for tile in reversed(tiles[hand]):
                    if not tile.is_pressed and tile.note == note_pressed[hand] and tile.check_collision(SCREEN_HEIGHT):
                        tile.is_pressed = True
                        score[hand]=score[hand] +1
                        if hand == 0:
                            uart.send_data(ser, 'C') # input left-hand_add_one in Verilog driven high
                        elif hand == 1:
                            uart.send_data(ser,'c') # right-hand_add_one driven high
                        break

        # === Tile update and spawn ===
        for hand in range(2):
            if move_clk >= prev_clk[hand] + next_note_interval[hand]:
                prev_clk[hand] = move_clk
                if note_index[hand] < len(song_notes[hand]):
                    interval = song_notes_length[hand][note_index[hand]] * 25
                    next_note_interval[hand] = interval
                    game.spawn_tile(
                        hand, TILE_WIDTH, RAIL_NUM,
                        tiles[hand], tile_note[hand],
                        note_index[hand], song_notes[hand],
                        song_notes_length[hand], TILE_HEIGHT_PER_QUARTER
                    )

                    if note_index[hand] < len(song_notes[hand]) - 1:
                        note_index[hand] += 1
                    else:
                        note_index[hand] = 0

            for tile in tiles[hand][:]: 
                tile.update(screen, TILE_SPEED, SCREEN_HEIGHT)
                if tile.is_fallen(ser, SCREEN_HEIGHT):
                    tiles[hand].remove(tile)
        pygame.display.flip()

def main():
    # Open Nexys4 DDR
    ser = uart.open_serial_port()
    if ser is None:
        print("Failed to open serial port.")
        return
    else:
        print("Nexys4 DDR is open.")
    time.sleep(0.1)

    song_notes =[[],[]]
    song_notes_length =[[],[]]
    song_notes[0],song_notes_length[0]=notes_rx.receive_notes(ser,0,'R')
    song_notes[1],song_notes_length[1]=notes_rx.receive_notes(ser,1,'r')

    score = [0,0]

    game_loop(ser, song_notes, song_notes_length, score)
    pygame.quit()

if __name__ == "__main__":
    main()
