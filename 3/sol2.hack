use HH\Lib\{C, Str, Vec};

<<__EntryPoint>>
async function day32(): Awaitable<void> {
  $grid = \file_get_contents('input.txt') |> Str\split($$, "\n");

  $x = Str\length($grid[0]);
  $y = C\count($grid);

  // [(number, [(x, y)], id)]
  $number_coordinates = vec<(int, vec<(int, int)>, int)>[];

  // [(x,y)]
  $star_coordinates = vec<(int, int)>[];

  $id = 0;
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
        $number_coordinates[] = tuple((int)$current_number, $coordinates, $id);
        $id++;
        $current_number = '';
      }

      if ($grid[$i][$j] === '.') {
        continue;
      }

      if ($grid[$i][$j] === '*') {
        $star_coordinates[] = tuple($j, $i);
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
      $number_coordinates[] = tuple((int)$current_number, $coordinates, $id);
      $id++;
      $current_number = '';
    }
  }

  // number_id => number
  $id_to_number = dict[];
  foreach ($number_coordinates as list($number, $_, $number_id)) {
    $id_to_number[$number_id] = $number;
  }
  // y => x => number_id
  $coordinates_to_number_id = dict[];
  foreach ($number_coordinates as list($number, $coordinates, $number_id)) {
    foreach ($coordinates as list($cx, $cy)) {
      if (!C\contains_key($coordinates_to_number_id, $cy)) {
        $coordinates_to_number_id[$cy] = dict[];
      }
      $coordinates_to_number_id[$cy][$cx] = $number_id;
    }
  }

  $gear_power = 0;
  foreach ($star_coordinates as list($cx, $cy)) {
    $found_number_ids = keyset[];
    foreach (vec[-1, 0, 1] as $offset_x) {
      foreach (vec[-1, 0, 1] as $offset_y) {
        $px = $cx - $offset_x;
        $py = $cy - $offset_y;
        if ($px < 0 || $px >= $x) {
          continue;
        }
        if ($py < 0 || $py >= $y) {
          continue;
        }
        if (C\contains_key($coordinates_to_number_id, $py)) {
          if (C\contains_key($coordinates_to_number_id[$py], $px)) {
            $found_number_ids[] = $coordinates_to_number_id[$py][$px];
          }
        }
      }
    }
    if (C\count($found_number_ids) === 2) {
      list($id1, $id2) = vec($found_number_ids);
      $gear_power += $id_to_number[$id1] * $id_to_number[$id2];
    }
  }

  echo "$gear_power\n";
}
