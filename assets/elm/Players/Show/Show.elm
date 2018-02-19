module Players.Show exposing (main)

import Html exposing (programWithFlags)
import Players.Show.State exposing (init, update, subscriptions)
import Players.Show.Types exposing (Flags, Model, Msg)
import Players.Show.View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
