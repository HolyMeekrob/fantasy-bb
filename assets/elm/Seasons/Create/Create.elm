module Seasons.Create exposing (main)

import Html exposing (program)
import Seasons.Create.State exposing (init, update, subscriptions)
import Seasons.Create.Types exposing (Model, Msg)
import Seasons.Create.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
