namespace AOC\Day61;

use HH\Lib\{C, Math, Regex, Str, Vec};

const string FILE_NAME = 'input.txt';

<<__EntryPoint>>
async function day51(): Awaitable<void> {
  list($times_raw, $distances_raw) =
    \file_get_contents(FILE_NAME) |> Str\split($$, "\n");
  $times = Regex\every_match($times_raw, re"/\d+/")
    |> Vec\map($$, $time ==> (int)$time[0]);
  $distances = Regex\every_match($distances_raw, re"/\d+/")
    |> Vec\map($$, $distance ==> (int)$distance[0]);

  foreach ($times as $index => $time) {
    $times_beat = 0;
    for ($i = 0; $i < $time; $i++) {
      $speed = $i; // mm per mm
      $distance = ($time - $i) * $speed;
      if ($distance > $distances[$index]) {
        $times_beat++;
      }
    }
    echo "$times_beat\n";
  }
}
