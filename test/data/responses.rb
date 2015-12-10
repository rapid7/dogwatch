ERROR_RES = [
  '400',
  { 'errors' => ["The value provided for parameter 'query' is invalid"] }
]
VALID_RES = [
  '200',
  {
    'name' => 'foobar',
    'query' => 'some query',
    'message' => 'foobar',
    'id' => 1_234_567
  }
]
ACCEPTED_RES = [
  '202',
  {
    'name' => 'foobar',
    'query' => 'some query',
    'message' => 'foobar',
    'id' => 1_234_567
  }
]
