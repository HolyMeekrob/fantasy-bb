module Leagues exposing (main)

import Html exposing (Html, program)
import Leagues.State exposing (init, update, subscriptions)
import Leagues.Types exposing (Model, Msg)
import Leagues.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
