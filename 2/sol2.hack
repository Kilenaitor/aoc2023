use HH\Lib\{Str, Math};

<<__EntryPoint>>
async function day22(): Awaitable<void> {
  $input = \file_get_contents('input1.txt');

  $games_data = vec[];
  foreach (Str\split($input, "\n") as $game) {
    list($_, $rounds) = Str\split($game, ':');
    $rounds_data = vec[];
    foreach (Str\split($rounds, ';') as $round) {
      $round_data = tuple(/* red */ 0, /* green */ 0, /* blue */ 0);
      foreach (Str\split($round, ',') as $cube) {
        list($count, $color) = Str\split(trim($cube), ' ');
        switch ($color) {
          case 'red':
            $round_data[0] = (int)$count;
            break;
          case 'green':
            $round_data[1] = (int)$count;
            break;
          case 'blue':
            $round_data[2] = (int)$count;
            break;
        }
      }
      $rounds_data[] = $round_data;
    }
    $games_data[] = $rounds_data;
  }

  $powers_sum = 0;
  foreach ($games_data as $game_id => $rounds) {
    $valid_game = true;

    $max_red = 0;
    $max_green = 0;
    $max_blue = 0;
    foreach ($rounds as $round) {
      $max_red = Math\maxva($max_red, $round[0]);
      $max_green = Math\maxva($max_green, $round[1]);
      $max_blue = Math\maxva($max_blue, $round[2]);
    }
    $powers_sum += $max_red * $max_green * $max_blue;
  }
  echo "$powers_sum\n";
}