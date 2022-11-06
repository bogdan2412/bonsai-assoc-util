open! Core
open! Import

let f_filter_everything ~key:_ ~data:_ = None

let filter_mapi map ~value_in_equal ~value_out_equal ~f =
  let last_value = ref (Obj.magic 0) in
  let last_filtered_value = ref (Obj.magic 0) in
  let last_f = ref f_filter_everything in
  Bonsai.Value.map2 map f ~f:(fun new_value new_f ->
    let new_filtered_value =
      match phys_equal new_f !last_f with
      | false ->
        last_f := new_f;
        Map.filter_mapi new_value ~f:new_f
      | true ->
        Map.fold_symmetric_diff
          !last_value
          new_value
          ~data_equal:value_in_equal
          ~init:!last_filtered_value
          ~f:(fun acc (key, diff) ->
            match diff with
            | `Left _ -> Map.remove acc key
            | `Right data ->
              (match new_f ~key ~data with
               | Some data -> Map.add_exn acc ~key ~data
               | None -> acc)
            | `Unequal (_, data) ->
              (match new_f ~key ~data with
               | Some data -> Map.set acc ~key ~data
               | None -> Map.remove acc key))
    in
    last_value := new_value;
    last_filtered_value := new_filtered_value;
    new_filtered_value)
  |> Bonsai.Value.cutoff ~equal:(Map.equal value_out_equal)
;;

let filter_map map ~value_in_equal ~value_out_equal ~f =
  filter_mapi
    map
    ~value_in_equal
    ~value_out_equal
    ~f:
      (let%map.Bonsai f = f in
       fun ~key:_ ~data -> f data)
;;

let filteri map ~value_equal ~f =
  filter_mapi
    map
    ~value_in_equal:value_equal
    ~value_out_equal:value_equal
    ~f:
      (let%map.Bonsai f = f in
       fun ~key ~data ->
         match f ~key ~data with
         | true -> Some data
         | false -> None)
;;

let filter map ~value_equal ~f =
  filter_mapi
    map
    ~value_in_equal:value_equal
    ~value_out_equal:value_equal
    ~f:
      (let%map.Bonsai f = f in
       fun ~key:_ ~data ->
         match f data with
         | true -> Some data
         | false -> None)
;;

let f_filter_opt ~key:_ ~data = data

let filter_opt map ~value_equal =
  filter_mapi
    map
    ~value_in_equal:(fun a b ->
      match a, b with
      | None, None -> true
      | Some _, None | None, Some _ -> false
      | Some a, Some b -> value_equal a b)
    ~value_out_equal:value_equal
    ~f:(Bonsai.Value.return f_filter_opt)
;;

let map map ~value_in_equal ~value_out_equal ~f =
  filter_mapi
    map
    ~value_in_equal
    ~value_out_equal
    ~f:
      (let%map.Bonsai f = f in
       fun ~key:_ ~data -> Some (f data))
;;

let mapi map ~value_in_equal ~value_out_equal ~f =
  filter_mapi
    map
    ~value_in_equal
    ~value_out_equal
    ~f:
      (let%map.Bonsai f = f in
       fun ~key ~data -> Some (f ~key ~data))
;;

let reindex_exn map ~value_in_equal ~value_out_equal ~new_key_comparator ~f =
  let last_value = ref None in
  let last_result = ref (Obj.magic 0) in
  Bonsai.Value.map map ~f:(fun new_value ->
    let new_result =
      match !last_value with
      | None -> Map.of_alist_exn new_key_comparator (List.map ~f (Map.to_alist new_value))
      | Some last_value ->
        Map.fold_symmetric_diff
          last_value
          new_value
          ~data_equal:value_in_equal
          ~init:!last_result
          ~f:(fun acc (key, diff) ->
            match diff with
            | `Left data ->
              let key, _ = f (key, data) in
              Map.remove acc key
            | `Right data ->
              let key, data = f (key, data) in
              Map.add_exn acc ~key ~data
            | `Unequal (data_old, data_new) ->
              let key_old, _ = f (key, data_old) in
              let acc = Map.remove acc key_old in
              let key_new, data_new = f (key, data_new) in
              Map.add_exn acc ~key:key_new ~data:data_new)
    in
    last_value := Some new_value;
    last_result := new_result;
    new_result)
  |> Bonsai.Value.cutoff ~equal:(Map.equal value_out_equal)
;;
