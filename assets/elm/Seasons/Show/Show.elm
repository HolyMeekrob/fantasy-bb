module Seasons.Show exposing (main)

import Html exposing (program)
import Seasons.Show.State exposing (init, update, subscriptions)
import Seasons.Show.Types exposing (Model, Msg)
import Seasons.Show.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
