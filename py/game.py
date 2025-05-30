import pygame
import oop_tiles
import notes_rx

def handle_events():
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            return False
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                return False
    return True

def draw_grid(screen,rail_num,tile_width,screen_height):
    for i in range(rail_num):
        if i==rail_num//2:
            thickness =6
        else:
            thickness =2
        pygame.draw.line(screen, 'black', (i * tile_width, 0), (i * tile_width, screen_height), thickness)

def draw_text(screen,text, color, size=100, pos=(400, 300)):
    font = pygame.font.Font(None, size)
    surface = font.render(text, True, color)
    rect = surface.get_rect(center=pos)
    screen.blit(surface, rect)

def spawn_tile(hand,tile_width,rail_num,tiles,tile_note,note_index,song_notes,song_notes_length,tile_height_per_quarter_second):
    note = song_notes[note_index]
    note_length = song_notes_length[note_index]
    if note == '0':
        return
    height= tile_height_per_quarter_second * note_length
    #print("Spawn")
    rail=notes_rx.rail() + hand * rail_num // 2
    tiles.append(oop_tiles.tile(tile_width * rail , (-1)*height, tile_width, height , note,note_length))
    tile_note.append(note)