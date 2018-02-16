module Seasons.Show exposing (main)

import Html exposing (programWithFlags)
import Seasons.Show.State exposing (init, update, subscriptions)
import Seasons.Show.Types exposing (Flags, Model, Msg)
import Seasons.Show.View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
