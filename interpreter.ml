type token =
    | Number of int
    | Plus
    | Minus
    | Multiply
    | Divide
    | Modulo
    | LeftBracket
    | RightBracket

let tokenize input =
    let length = String.length input in

    let rec scan i tokens =
        if i >= length then
            List.rev tokens
        else
            match input.[i] with
            | ' ' | '\t' | '\n' | '\r' ->
                scan (i + 1) tokens
            | '+' -> scan (i + 1) (Plus :: tokens)
            | '-' -> scan (i + 1) (Minus :: tokens)
            | '*' -> scan (i + 1) (Multiply :: tokens)
            | '/' -> scan (i + 1) (Divide :: tokens)
            | '%' -> scan (i + 1) (Modulo :: tokens)
            | '(' -> scan (i + 1) (LeftBracket :: tokens)
            | ')' -> scan (i + 1) (RightBracket :: tokens)
            | '0' .. '9' ->
                let j = ref i in
                while !j < length &&
                      input.[!j] >= '0' &&
                      input.[!j] <= '9' do
                    incr j
                done;
                let n =
                    int_of_string (String.sub input i (!j - i))
                in
                scan !j (Number n :: tokens)
            | c ->
                failwith
                    (Printf.sprintf "Unexpected character: %c" c)
    in
    scan 0 []

type expr =
    | Int of int
    | Add of expr * expr
    | Subtract of expr * expr
    | Multiply of expr * expr
    | Divide of expr * expr
    | Modulo of expr * expr

let parse tokens =
    let tokens = Array.of_list tokens in
    let pos = ref 0 in

    let peek () =
        if !pos < Array.length tokens then
            Some tokens.(!pos)
        else
            None
    in

    let consume () =
        let token = peek () in
        incr pos;
        token
    in

    let rec parse_expr () =
        let lhs = parse_term () in
        parse_addition lhs

    and parse_addition lhs =
        match peek () with
        | Some Plus ->
            ignore (consume ());
            let rhs = parse_term () in
            parse_addition (Add (lhs, rhs))

        | Some Minus ->
            ignore (consume ());
            let rhs = parse_term () in
            parse_addition (Subtract (lhs, rhs))

        | _ -> lhs

    and parse_term () =
        let lhs = parse_atom () in
        parse_multiplication lhs

    and parse_multiplication lhs =
        match peek () with
        | Some Multiply ->
            ignore (consume ());
            let rhs = parse_atom () in
            parse_multiplication (Multiply (lhs, rhs))

        | Some Divide ->
            ignore (consume ());
            let rhs = parse_atom () in
            parse_multiplication (Divide (lhs, rhs))

        | Some Modulo ->
            ignore (consume ());
            let rhs = parse_atom () in
            parse_multiplication (Modulo (lhs, rhs))

        | _ -> lhs

    and parse_atom () =
        match consume () with
        | Some (Number n) -> Int n
        | Some LeftBracket ->
            let expr = parse_expr() in 
            (match consume () with
            | Some RightBracket -> expr
            |_ -> failwith "Expected ')'")
        | _ -> failwith "Expected a number"
    in

    let ast = parse_expr () in

    if !pos <> Array.length tokens then
        failwith "Unexpected token at end of expression";

    ast

    let rec eval expr =
    match expr with
    | Int n ->
        n

    | Add (lhs, rhs) ->
        eval lhs + eval rhs

    | Subtract (lhs, rhs) ->
        eval lhs - eval rhs

    | Multiply (lhs, rhs) ->
        eval lhs * eval rhs

    | Divide (lhs, rhs) ->
        let rhs_val = eval rhs in
        if rhs_val = 0 then
            failwith "Attempted to divide by zero"
        else
            eval lhs / rhs_val


    | Modulo (lhs, rhs) ->
        let rhs_val = eval rhs in
        if rhs_val = 0 then
            failwith "Attempted to modulo by zero"
        else
            eval lhs mod eval rhs

let () =
    if Array.length Sys.argv < 2 then
        failwith "Usage: matty <file.my>";

    let filename = Sys.argv.(1) in
    let channel = open_in filename in

    let input =
        try
            let contents = really_input_string channel
                (in_channel_length channel) in
            close_in channel;
            contents
        with e ->
            close_in_noerr channel;
            raise e
    in

    let tokens = tokenize input in
    let ast = parse tokens in
    let result = eval ast in

Printf.printf "%d\n" result