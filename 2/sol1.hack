use HH\Lib\Str;

<<__EntryPoint>>
async function day21(): Awaitable<void> {
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

  $valid_games_sum = 0;
  foreach ($games_data as $game_id => $rounds) {
    $valid_game = true;
    foreach ($rounds as $round) {
      $valid_round = $round[0] <= 12 && $round[1] <= 13 && $round[2] <= 14;
      if (!$valid_round) {
        $valid_game = false;
      }
    }
    if ($valid_game) {
      // Need to add 1 since games are 1-indexed
      $valid_games_sum += $game_id + 1;
    }
  }
  echo "$valid_games_sum\n";
}