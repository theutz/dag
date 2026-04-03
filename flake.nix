{
  description = "dag";
  outputs = _: { lib = import ./.; };
}
