#include "game.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "snake_utils.h"

/* Helper function definitions */
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch);
static bool is_tail(char c);
static bool is_head(char c);
static bool is_snake(char c);
static char body_to_tail(char c);
static char head_to_body(char c);
static unsigned int get_next_row(unsigned int cur_row, char c);
static unsigned int get_next_col(unsigned int cur_col, char c);
static void find_head(game_t *game, unsigned int snum);
static char next_square(game_t *game, unsigned int snum);
static void update_tail(game_t *game, unsigned int snum);
static void update_head(game_t *game, unsigned int snum);

/* Task 1 */
game_t *create_default_game() {
  // TODO: Implement this function.
  game_t *game = malloc(sizeof(game_t));    // Allocate the memory space for game_t
  game->num_rows = 18;    // Set number of rows for this game board
  game->board = malloc(sizeof(game->board[0]) * 18);    // Allocate the memory space for the game board
  game->num_snakes = 1;     // Initialize the number of snake 
  game->snakes = malloc(sizeof(snake_t));     // Allocate memory space for snake_t

  // Make allocation for the board
  for (int i = 0; i < 18; i++){
    game->board[i] = malloc(sizeof(game->board[i][0]) * 22);   // Make allocation for each row in size of 22
    if (!game->board[i]){
      free(game->board);
    }
  }

  // Set the board frame 
  for (int i = 0; i <18; i++){
    if (i == 0 || i == 17){
      strcpy(game->board[i],"####################\n");    // Copy several '#' to set the first and last row
    } else {
      strcpy(game->board[i],"#                  #\n");    // Copy several '#' to set row 0
    }
  }

  // Set icon of snake in board
  game->board[2][2] = 'd';
  game->board[2][3] = '>';
  game->board[2][4] = 'D';
  game->board[2][9] = '*';


  // Set initial position of the snake
  game->snakes[0].tail_row = 2;
  game->snakes[0].tail_col = 2;
  game->snakes[0].head_row = 2;
  game->snakes[0].head_col = 4;
  game->snakes[0].live = true;

  // Test print board
  // for (int i = 0; i < game->num_rows; i++) {
  //   printf("%s", game->board[i]);
  // }

  return game;
}

/* Task 2 */
void free_game(game_t *game) {
  // TODO: Implement this function.
  // Free all the allocation we made in task 1
  free(game->board);
  free(game->snakes);
  free(game);
  return;
}

/* Task 3 */
void print_board(game_t *game, FILE *fp) {
  // TODO: Implement this function.

  // Print the board by using fprint and write to fp pointer
  for (int i = 0; i < game->num_rows; i++) {
    fprintf(fp, "%s", game->board[i]);
  }

  return;
}

/*
  Saves the current game into filename. Does not modify the game object.
  (already implemented for you).
*/
void save_board(game_t *game, char *filename) {
  FILE *f = fopen(filename, "w");
  print_board(game, f);
  fclose(f);
}

/* Task 4.1 */

/*
  Helper function to get a character from the board
  (already implemented for you).
*/
char get_board_at(game_t *game, unsigned int row, unsigned int col) { return game->board[row][col]; }

/*
  Helper function to set a character on the board
  (already implemented for you).
*/
static void set_board_at(game_t *game, unsigned int row, unsigned int col, char ch) {
  game->board[row][col] = ch;
}

/*
  Returns true if c is part of the snake's tail.
  The snake consists of these characters: "wasd"
  Returns false otherwise.
*/
static bool is_tail(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd'){
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake's head.
  The snake consists of these characters: "WASDx"
  Returns false otherwise.
*/
static bool is_head(char c) {
  // TODO: Implement this function.
  if (c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x'){
    return true;
  } else {
    return false;
  }
}

/*
  Returns true if c is part of the snake.
  The snake consists of these characters: "wasd^<v>WASDx"
*/
static bool is_snake(char c) {
  // TODO: Implement this function.
  if (c == 'w' || c == 'a' || c == 's' || c == 'd' || c == '^' || c == '<' || c == 'v' 
  || c == '>' || c == 'W' || c == 'A' || c == 'S' || c == 'D' || c == 'x'){
    return true;
  } else {
    return false;
  }
}

/*
  Converts a character in the snake's body ("^<v>")
  to the matching character representing the snake's
  tail ("wasd").
*/
static char body_to_tail(char c) {
  // TODO: Implement this function.
  if (c == '^'){
    return 'w';
  } else if (c == '<'){
    return 'a';
  } else if (c == 'v'){
    return 's';
  } else if (c == '>'){
    return 'd';
  }

  return c;
}

/*
  Converts a character in the snake's head ("WASD")
  to the matching character representing the snake's
  body ("^<v>").
*/
static char head_to_body(char c) {
  // TODO: Implement this function.
  if (c == 'W'){
    return '^';
  } else if (c == 'A'){
    return '<';
  } else if (c == 'S'){
    return 'v';
  } else if (c == 'D'){
    return '>';
  }

  return c;
}

/*
  Returns cur_row + 1 if c is 'v' or 's' or 'S'.
  Returns cur_row - 1 if c is '^' or 'w' or 'W'.
  Returns cur_row otherwise.
*/
static unsigned int get_next_row(unsigned int cur_row, char c) {
  // TODO: Implement this function.
  if (c == 'v' || c == 's' || c == 'S'){
    return (cur_row + 1);
 } else if (c == '^' || c == 'w' || c == 'W'){
    return (cur_row - 1);
  } else{
    return cur_row;
  }
}

/*
  Returns cur_col + 1 if c is '>' or 'd' or 'D'.
  Returns cur_col - 1 if c is '<' or 'a' or 'A'.
  Returns cur_col otherwise.
*/
static unsigned int get_next_col(unsigned int cur_col, char c) {
  // TODO: Implement this function.
  if (c == '>' || c == 'd' || c == 'D'){
    return (cur_col + 1);
 } else if (c == '<' || c == 'a' || c == 'A'){
    return (cur_col - 1);
  } else{
    return cur_col;
  }
}

/*
  Task 4.2

  Helper function for update_game. Return the character in the cell the snake is moving into.

  This function should not modify anything.
*/
static char next_square(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  snake_t *snake = &(game->snakes[snum]);   // Get the snake number
  unsigned int head_row = snake->head_row;
  unsigned int head_col = snake->head_col;
  char head = get_board_at(game, head_row, head_col);

  // Get the next head location
  unsigned int next_row = get_next_row(head_row, head);
  unsigned int next_col = get_next_col(head_col, head);

  return get_board_at(game, next_row, next_col);
}

/*
  Task 4.3

  Helper function for update_game. Update the head...

  ...on the board: add a character where the snake is moving

  ...in the snake struct: update the row and col of the head

  Note that this function ignores food, walls, and snake bodies when moving the head.
*/
static void update_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  snake_t *snake = &(game->snakes[snum]);   // Get the snake number
  unsigned int old_head_row = snake->head_row;
  unsigned int old_head_col = snake->head_col;
  char old_head = get_board_at(game, old_head_row, old_head_col);

  // Get the new head location
  unsigned int new_head_row = get_next_row(old_head_row, old_head);
  unsigned int new_head_col = get_next_col(old_head_col, old_head);

  // Update on the game board
  set_board_at(game, old_head_row, old_head_col, head_to_body(old_head));  // Update the old head to body
  set_board_at(game, new_head_row, new_head_col, old_head);  // Update the new head on the board

  // Update the snake head on snake struct
  snake->head_row = new_head_row;
  snake->head_col = new_head_col;

  return;
}

/*
  Task 4.4

  Helper function for update_game. Update the tail...

  ...on the board: blank out the current tail, and change the new
  tail from a body character (^<v>) into a tail character (wasd)

  ...in the snake struct: update the row and col of the tail
*/
static void update_tail(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  snake_t *snake = &(game->snakes[snum]);   // Get the snake number
  unsigned int old_tail_row = snake->tail_row;
  unsigned int old_tail_col = snake->tail_col;
  char old_tail = get_board_at(game, old_tail_row, old_tail_col);
  
  // Get new tail location
  unsigned int new_tail_row = get_next_row(old_tail_row, old_tail);
  unsigned int new_tail_col = get_next_col(old_tail_col, old_tail);

  // Get new tail body
  char new_tail_body = get_board_at(game, new_tail_row, new_tail_col);

  // Update on the board display
  set_board_at(game, old_tail_row, old_tail_col, ' ');
  set_board_at(game, new_tail_row, new_tail_col, body_to_tail(new_tail_body));

  // Update tail on snake struct
  snake->tail_row = new_tail_row;
  snake->tail_col = new_tail_col;

  return;
}

/* Task 4.5 */
void update_game(game_t *game, int (*add_food)(game_t *game)) {
  // TODO: Implement this function.
  unsigned int snum = game->num_snakes;

  for (unsigned int i = 0; i < snum; i++){
    snake_t *snake = &(game->snakes[i]);   // Get the snake number

    bool is_live = snake->live;
    if (!is_live){
      continue;
    }

  // Initialize next_squ, head_row and head_col
  char next_squ = next_square(game,i);
  unsigned int head_row = snake->head_row;
  unsigned int head_col = snake->head_col;

  // Set 3 conditions - next square is # or snake body, fruit or empty
  if (next_squ == '#' || is_snake(next_squ)){
    set_board_at(game, head_row, head_col, 'x');
    snake->live = false;      
    continue;
  } else if (next_squ == '*'){
    update_head(game, i);
    add_food(game);
  } else {
    update_head(game, i);
    update_tail(game, i);
  }
  }
  return;
}

/* Task 5.1 */
char *read_line(FILE *fp) {
  // TODO: Implement this function.
  if (!fp) return NULL;

  char buffer[1024];
  char *load_line = fgets(buffer, sizeof(buffer), fp);   // Set load_line point to the fgets' input
  char *line = NULL;
  size_t line_len = 0;

  while(load_line){
    size_t chunk_length = strlen(buffer);    // set the length of the output from fgets

    char *new_line = realloc(line, line_len + chunk_length + 1);
    if (!new_line) {
      free(line);
      return NULL;
    }

    line = new_line;
    strcpy(line + line_len, buffer);
    line_len += chunk_length;

    if (strchr(buffer,'\n')) return line;

    load_line = fgets(buffer, sizeof(buffer), fp);

  }

  return line;

}

/* Task 5.2 */
game_t *load_board(FILE *fp) {
  // TODO: Implement this function.
  if (!fp) return NULL;

  game_t *game = malloc(sizeof(game_t));   // Make allocation for game board;
  if (!game) return NULL;

  // Initialize the arguments in game struct
  game->num_rows = 0;
  game->board = NULL;
  game->num_snakes = 0;
  game->snakes = NULL;

  char *line = read_line(fp);

  while (line != NULL) {
    char **new_board = realloc(game->board, 
      sizeof(game->board[0]) * (game->num_rows + 1));

    if (!new_board) {
      free(line);

      for (unsigned int i = 0; i < game->num_rows; i++){
        free(game->board[i]);
      }

    free(game->board);
    free(game);

    return NULL;
    }
    
    game->board = new_board;
    game->board[game->num_rows] = line;
    game->num_rows++;

    line = read_line(fp);
  }

  return game;
}

/*
  Task 6.1

  Helper function for initialize_snakes.
  Given a snake struct with the tail row and col filled in,
  trace through the board to find the head row and col, and
  fill in the head row and col in the struct.
*/
static void find_head(game_t *game, unsigned int snum) {
  // TODO: Implement this function.
  snake_t *snake = &(game->snakes[snum]);    // Set the snake pointer points to the snake in game struct
  unsigned int search_row = snake->tail_row;    // Initialize the search row number as the tail location
  unsigned int search_col = snake->tail_col;    // Initialize the search col number as the tail location
  char square = game->board[search_row][search_col];    // Initialize the searching square

  while(square != 'W' && square != 'A' && square != 'S' && square != 'D') {
    if (square == 'w' || square == '^'){
      search_row--;
    } else if (square == 'a' || square == '<') {
      search_col--;
    } else if (square == 's' || square == 'v') {
      search_row++;
    } else if (square == 'd' || square == '>') {
      search_col++;
    }

    square = get_board_at(game, search_row, search_col);
  }

  snake->head_row = search_row;
  snake->head_col = search_col;

  return;
}

/* Task 6.2 */
game_t *initialize_snakes(game_t *game) {
  // TODO: Implement this function.

  game->num_snakes = 0;    // Initialize the number of snakes
  unsigned int sum_rows = game->num_rows;    // Get the total rows on the board
  
  // Make for loop to count the number of snakes in the board
  for (unsigned int i = 0; i < sum_rows; i++) {

    size_t num_cols = strlen(game->board[i]) - 1;   // get the number of character in the row (not sure about -1 or -2)

    for (unsigned int j = 0; j <= num_cols; j++){
      char square = get_board_at(game, i, j);
      
      if (square == 'w' || square == 'a' || square == 's' || square == 'd') {
        // game->snakes[game->num_snakes].tail_row = i;    // Update the snake tail row
        // game->snakes[game->num_snakes].tail_col = j;    // Update the snake tail col
        // game->snakes[game->num_snakes].live = true;    // Update the snake live status
        game->num_snakes++;
      }
    
    }
  }

  // Make allocation for the snakes
  game->snakes = malloc(sizeof(snake_t)*game->num_snakes);

  unsigned int snake_index = 0;    // Initialize index for each snake. Used in the following for loop

  // Make another full loop to get the information of tail row&col and live status for each snake
  for (unsigned int i = 0; i < sum_rows; i++) {

    size_t num_cols = strlen(game->board[i]) - 1;   // get the number of character in the row (not sure about -1 or -2)

    for (unsigned int j = 0; j <= num_cols; j++){
      char square = get_board_at(game, i, j);
      
      if (square == 'w' || square == 'a' || square == 's' || square == 'd') {
        game->snakes[snake_index].tail_row = i;    // Update the snake tail row
        game->snakes[snake_index].tail_col = j;    // Update the snake tail col
        game->snakes[snake_index].live = true;    // Update the snake live status

        snake_index++;
      }
    
    }
  }

  for (unsigned int i = 0; i < game->num_snakes; i++){
    find_head(game, i);
  }

  return game;
}
