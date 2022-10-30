open! Core
open! Import

val filter
  :  ('key, 'value, 'cmp) Map.t Bonsai.Value.t
  -> value_equal:('value -> 'value -> bool)
  -> f:('value -> bool) Bonsai.Value.t
  -> ('key, 'value, 'cmp) Map.t Bonsai.Value.t

val filteri
  :  ('key, 'value, 'cmp) Map.t Bonsai.Value.t
  -> value_equal:('value -> 'value -> bool)
  -> f:(key:'key -> data:'value -> bool) Bonsai.Value.t
  -> ('key, 'value, 'cmp) Map.t Bonsai.Value.t

val filter_map
  :  ('key, 'value_in, 'cmp) Map.t Bonsai.Value.t
  -> value_in_equal:('value_in -> 'value_in -> bool)
  -> value_out_equal:('value_out -> 'value_out -> bool)
  -> f:('value_in -> 'value_out option) Bonsai.Value.t
  -> ('key, 'value_out, 'cmp) Map.t Bonsai.Value.t

val filter_mapi
  :  ('key, 'value_in, 'cmp) Map.t Bonsai.Value.t
  -> value_in_equal:('value_in -> 'value_in -> bool)
  -> value_out_equal:('value_out -> 'value_out -> bool)
  -> f:(key:'key -> data:'value_in -> 'value_out option) Bonsai.Value.t
  -> ('key, 'value_out, 'cmp) Map.t Bonsai.Value.t

val filter_opt
  :  ('key, 'value option, 'cmp) Map.t Bonsai.Value.t
  -> value_equal:('value -> 'value -> bool)
  -> ('key, 'value, 'cmp) Map.t Bonsai.Value.t

val map
  :  ('key, 'value_in, 'cmp) Map.t Bonsai.Value.t
  -> value_in_equal:('value_in -> 'value_in -> bool)
  -> value_out_equal:('value_out -> 'value_out -> bool)
  -> f:('value_in -> 'value_out) Bonsai.Value.t
  -> ('key, 'value_out, 'cmp) Map.t Bonsai.Value.t

val mapi
  :  ('key, 'value_in, 'cmp) Map.t Bonsai.Value.t
  -> value_in_equal:('value_in -> 'value_in -> bool)
  -> value_out_equal:('value_out -> 'value_out -> bool)
  -> f:(key:'key -> data:'value_in -> 'value_out) Bonsai.Value.t
  -> ('key, 'value_out, 'cmp) Map.t Bonsai.Value.t

val reindex_exn
  :  ('key_in, 'value_in, 'cmp_in) Map.t Bonsai.Value.t
  -> value_in_equal:('value_in -> 'value_in -> bool)
  -> value_out_equal:('value_out -> 'value_out -> bool)
  -> new_key_comparator:('key_out, 'cmp_out) Comparator.Module.t
  -> f:('key_in * 'value_in -> 'key_out * 'value_out)
  -> ('key_out, 'value_out, 'cmp_out) Map.t Bonsai.Value.t
