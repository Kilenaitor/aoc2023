namespace AOC\Day52b;

use HH\Lib\{C, Math, Str, Vec};

const string FILE_NAME = 'input.txt';

type TRange = shape('start' => int, 'range' => int);
type TMapping = shape(
  'destination_start' => int,
  'source_start' => int,
  'range' => int,
);
type TMappings = vec<TMapping>;

class Mappings {

  private vec<TRange> $seed_ranges;
  private TMappings $seed_to_soil;
  private TMappings $soil_to_fertilizer;
  private TMappings $fertilizer_to_water;
  private TMappings $water_to_light;
  private TMappings $light_to_temperature;
  private TMappings $temperature_to_humidity;
  private TMappings $humidity_to_location;

  public function __construct() {
    $file = \file_get_contents(FILE_NAME);

    list(
      $seeds_raw,
      $seed_to_soil_raw,
      $soil_to_fertilizer_raw,
      $fertilizer_to_water_raw,
      $water_to_light_raw,
      $light_to_temperature_raw,
      $temperature_to_humidity_raw,
      $humidity_to_location_raw,
    ) = Str\split($file, "\n\n");

    $seeds = Str\split($seeds_raw, ':')
      |> Str\split(\trim($$[1]), ' ')
      |> Vec\map($$, $seed ==> (int)$seed);

    $seed_ranges = vec[];
    $seed_pairs = Vec\chunk($seeds, 2);
    foreach ($seed_pairs as list($seed_start, $range)) {
      $seed_ranges[] = shape('start' => $seed_start, 'range' => $range);
    }
    $this->seed_ranges = $seed_ranges;

    $this->seed_to_soil = $this->parseMapping($seed_to_soil_raw);
    $this->soil_to_fertilizer = $this->parseMapping($soil_to_fertilizer_raw);
    $this->fertilizer_to_water = $this->parseMapping($fertilizer_to_water_raw);
    $this->water_to_light = $this->parseMapping($water_to_light_raw);
    $this->light_to_temperature =
      $this->parseMapping($light_to_temperature_raw);
    $this->temperature_to_humidity =
      $this->parseMapping($temperature_to_humidity_raw);
    $this->humidity_to_location =
      $this->parseMapping($humidity_to_location_raw);
  }

  public function getSeed(int $location): ?int {
    $humidity = $this->lookupReverse($this->humidity_to_location, $location);
    $temperature =
      $this->lookupReverse($this->temperature_to_humidity, $humidity);
    $light = $this->lookupReverse($this->light_to_temperature, $temperature);
    $water = $this->lookupReverse($this->water_to_light, $light);
    $fertilizer = $this->lookupReverse($this->fertilizer_to_water, $water);
    $soil = $this->lookupReverse($this->soil_to_fertilizer, $fertilizer);
    $candidate_seed = $this->lookupReverse($this->seed_to_soil, $soil);

    foreach ($this->seed_ranges as $seed_range) {
      $seed_in_range = $candidate_seed >= $seed_range['start'] &&
        $candidate_seed < $seed_range['start'] + $seed_range['range'];
      if ($seed_in_range) {
        return $candidate_seed;
      }
    }

    return null;
  }

  public function lookupReverse(TMappings $mappings, int $destination): int {
    foreach ($mappings as $mapping) {
      $destination_in_range = $destination >= $mapping['destination_start'] &&
        $destination < $mapping['destination_start'] + $mapping['range'];
      if ($destination_in_range) {
        return $mapping['source_start'] +
          ($destination - $mapping['destination_start']);
      }
    }

    return $destination;
  }

  private function parseMapping(string $raw_contents): TMappings {
    $results = vec[];

    $rows = Str\split($raw_contents, "\n");
    for ($i = 1; $i < C\count($rows); $i++) {
      list($destination_start, $source_start, $range) =
        Str\split(\trim($rows[$i]), ' ');
      $source_start = (int)$source_start;
      $destination_start = (int)$destination_start;
      $range = (int)$range;

      $results[] = shape(
        'destination_start' => $destination_start,
        'source_start' => $source_start,
        'range' => $range,
      );
    }

    return $results;
  }
}

<<__EntryPoint>>
async function day51(): Awaitable<void> {
  $mapping = new Mappings();

  for ($location = 0; $location < \PHP_INT_MAX; $location++) {
    $seed = $mapping->getSeed($location);
    if ($seed is nonnull) {
      echo "$location\n";
      break;
    }
  }
}
