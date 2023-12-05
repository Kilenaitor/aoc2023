namespace AOC\Day52r;

use HH\Lib\{C, Math, Str, Vec};

const string FILE_NAME = 'test.txt';

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

  public function getSmallestLocation(int $offset = 0): int {
    $humidity_to_locations = Vec\sort(
      $this->humidity_to_location,
      ($m1, $m2) ==> $m1['destination_start'] <=> $m2['destination_start'],
    );

    $humidity_to_location = $humidity_to_locations[$offset];
    \print_r(shape(
      'start' => $humidity_to_location['destination_start'],
      'range' => $humidity_to_location['range'],
    ));

    $humidity_range = shape(
      'start' => $humidity_to_location['source_start'],
      'range' => $humidity_to_location['range'],
    );
    \print_r($humidity_range);

    $temperature_range = $this->smallestInvertedIntersection(
      $this->temperature_to_humidity,
      $humidity_range,
    );
    \print_r($temperature_range);

    $light_range = $this->smallestInvertedIntersection(
      $this->light_to_temperature,
      $temperature_range,
    );
    $water_range =
      $this->smallestInvertedIntersection($this->water_to_light, $light_range);
    $fertilizer_range =
      $this->smallestInvertedIntersection($this->fertilizer_to_water, $water_range);
    $soil_range =
      $this->smallestInvertedIntersection($this->soil_to_fertilizer, $fertilizer_range);
    $seed_range = $this->smallestInvertedIntersection($this->seed_to_soil, $soil_range);


    return 0;
  }

  public function smallestInvertedIntersection(
    TMappings $mappings,
    TRange $range,
  ): TRange {
    $ordered_mappings = Vec\sort(
      $mappings,
      ($m1, $m2) ==> $m1['destination_start'] <=> $m2['destination_start'],
    );

    $new_range = null;
    $mapping_index = null;
    foreach ($ordered_mappings as $index => $mapping) {
      $intersection = $this->rangeIntersection(
        shape(
          'start' => $mapping['destination_start'],
          'range' => $mapping['range'],
        ),
        $range,
      );
      if ($intersection is nonnull) {
        $new_range = $intersection;
        $mapping_index = $index;
        break;
      }
    }
    if ($new_range is null) {
      return $range;
    }

    $mapping = $ordered_mappings[$mapping_index as nonnull];
    $destination_offset = $mapping['source_start'] - $mapping['destination_start'];

    return shape(
      'start' => $new_range['start'] + $destination_offset,
      'range' => $new_range['range'],
    );
  }

  public function rangeIntersection(
    TRange $r1,
    TRange $r2,
  ): ?TRange {
    $r1_start = $r1['start'];
    $r1_end = $r1['start'] + $r1['range'];
    $r2_start = $r2['start'];
    $r2_end = $r2['start'] + $r2['range'];

    $r_start = Math\maxva($r1_start, $r2_start);
    $r_end = Math\minva($r1_end, $r2_end);

    if ($r_end < $r_start) {
      return null;
    }
    return shape('start' => $r_start, 'range' => $r_end - $r_start);
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
async function day52(): Awaitable<void> {
  $mapping = new Mappings();
  $location = $mapping->getSmallestLocation();
  echo "$location\n";
}
