module Common.Commands exposing (..)

import Task


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity
