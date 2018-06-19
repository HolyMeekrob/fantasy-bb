module Teams.Show exposing (main)

import Html exposing (programWithFlags)
import Teams.Show.State exposing (init, update, subscriptions)
import Teams.Show.Types exposing (Flags, Model, Msg)
import Teams.Show.View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
