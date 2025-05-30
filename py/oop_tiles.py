import pygame
import random

class tile():
    def __init__(self, x, y, width, height, note,time_length):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.color = (random.randint(120,255), random.randint(0,120), random.randint(120,255))
        self.note= note
        self.time_length = time_length
        self.is_pressed = False
    
    def draw(self, screen):
        pygame.draw.rect(screen, self.color, (self.x, self.y, self.width, self.height))
        font = pygame.font.Font(None, 36)
        text_surface = font.render(self.note, True, (0, 0, 0))
        text_rect = text_surface.get_rect(center=(self.x + self.width // 2, self.y + self.height // 2))
        screen.blit(text_surface, text_rect)

    def update(self,screen,tile_speed, screen_height):
        self.y += tile_speed
        self.color = (0, 255, 0) if self.is_pressed else (self.color)
        pygame.draw.rect(screen, self.color, (self.x, self.y, self.width, self.height))

        font = pygame.font.Font(None, 60)
        text_surface = font.render(str(self.note), True, (0, 0, 0))
        text_rect = text_surface.get_rect(center=(self.x+self.width//2, self.y+self.height//2))
        screen.blit(text_surface, text_rect)
    
    def check_collision(self, y): 
        if self.y < y < self.y + self.height:
            return True
        return False

    def not_fully_appeared(self):
        if(self.y + self.height < 0):
            return True
        return False
    
    def is_fallen(self,ser,screen_height):
        if self.y > screen_height:
            return True
        return False
        