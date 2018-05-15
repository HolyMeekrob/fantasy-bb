module Leagues.Show exposing (main)

import Html exposing (programWithFlags)
import Leagues.Show.State exposing (init, update, subscriptions)
import Leagues.Show.Types exposing (Flags, Model, Msg)
import Leagues.Show.View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
