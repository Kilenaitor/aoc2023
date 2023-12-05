use HH\Lib\{C, Math, Str, Vec};

const string FILE_NAME = 'input.txt';

type TMappings = vec<shape(
  'destination_start' => int,
  'source_start' => int,
  'range' => int,
)>;

class Mappings {

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
      $_seeds_raw,
      $seed_to_soil_raw,
      $soil_to_fertilizer_raw,
      $fertilizer_to_water_raw,
      $water_to_light_raw,
      $light_to_temperature_raw,
      $temperature_to_humidity_raw,
      $humidity_to_location_raw,
    ) = Str\split($file, "\n\n");

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

  public function getSeedLocation(int $seed): int {
    $soil = $this->lookup($this->seed_to_soil, $seed);
    $fertilizer = $this->lookup($this->soil_to_fertilizer, $soil);
    $water = $this->lookup($this->fertilizer_to_water, $fertilizer);
    $light = $this->lookup($this->water_to_light, $water);
    $temperature = $this->lookup($this->light_to_temperature, $light);
    $humidity = $this->lookup($this->temperature_to_humidity, $temperature);
    return $this->lookup($this->humidity_to_location, $humidity);
  }

  public function lookup(TMappings $mappings, int $source): int {
    foreach ($mappings as $mapping) {
      $source_in_range = $source >= $mapping['source_start'] &&
        $source < $mapping['source_start'] + $mapping['range'];
      if ($source_in_range) {
        return
          $mapping['destination_start'] + ($source - $mapping['source_start']);
      }
    }

    return $source;
  }

  private function parseMapping(string $raw_contents): TMappings {
    $results = vec[];

    $rows = Str\split($raw_contents, "\n");
    for ($i = 1; $i < C\count($rows); $i++) {
      list($destination_start, $source_start, $range) =
        Str\split(trim($rows[$i]), ' ');
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
  $file = \file_get_contents(FILE_NAME);
  list($seeds_raw, $_) = Str\split($file, "\n\n");
  $seeds = Str\split($seeds_raw, ':')
    |> Str\split(trim($$[1]), ' ')
    |> Vec\map($$, $seed ==> (int)$seed);

  $mapping = new Mappings();

  $locations = Vec\map($seeds, $seed ==> $mapping->getSeedLocation($seed));
  echo Math\min($locations) as nonnull."\n";
}
