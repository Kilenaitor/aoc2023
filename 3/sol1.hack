use HH\Lib\{C, Str, Vec};

<<__EntryPoint>>
async function day31(): Awaitable<void> {
  $grid = \file_get_contents('input.txt') |> Str\split($$, "\n");

  $x = Str\length($grid[0]);
  $y = C\count($grid);

  // number => [(x, y)]
  $number_coordinates = vec<(int, vec<(int, int)>)>[];

  for ($i = 0; $i < $y; $i++) {
    $current_number = '';
    for ($j = 0; $j < $x; $j++) {
      if ((string)(int)$grid[$i][$j] === $grid[$i][$j]) {
        $current_number .= $grid[$i][$j];
        continue;
      }

      if (!Str\is_empty($current_number)) {
        $coordinates = vec[];
        foreach (Str\split($current_number, '') as $index => $character) {
          $coordinates[] = tuple($j - Str\length($current_number) + $index, $i);
        }
        $number_coordinates[] = tuple((int)$current_number, $coordinates);
        $current_number = '';
      }

      if ($grid[$i][$j] === '.') {
        continue;
      }
    }

    // Numbers cannot flow onto the next line! So if we've reached end of line,
    // and have a non-empty current number string, we need to consider that
    // the end of it.
    if (!Str\is_empty($current_number)) {
      $coordinates = vec[];
      foreach (Str\split($current_number, '') as $index => $character) {
        $coordinates[] = tuple($j - Str\length($current_number) + $index, $i);
      }
      $number_coordinates[] = tuple((int)$current_number, $coordinates);
      $current_number = '';
    }
  }

  $valid_part_numbers = vec[];
  foreach ($number_coordinates as list($number, $coordinates)) {
    $valid_number = false;
    foreach ($coordinates as list($cx, $cy)) {
      if ($valid_number) {
        break;
      }
      foreach (vec[-1, 0, 1] as $offset_x) {
        if ($valid_number) {
          break;
        }
        foreach (vec[-1, 0, 1] as $offset_y) {
          if ($valid_number) {
            break;
          }
          $px = $cx - $offset_x;
          $py = $cy - $offset_y;
          if ($px < 0 || $px >= $x) {
            continue;
          }
          if ($py < 0 || $py >= $y) {
            continue;
          }
          if (
            $grid[$py][$px] !== '.' &&
            (string)(int)$grid[$py][$px] !== $grid[$py][$px]
          ) {
            $valid_number = true;
          }
        }
      }
    }
    if ($valid_number) {
      $valid_part_numbers[] = $number;
    }
  }

  $part_number_sum = 0;
  foreach ($valid_part_numbers as $part_number) {
    $part_number_sum += $part_number;
  }
  echo "$part_number_sum\n";
}
