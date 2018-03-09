module Leagues.Create exposing (main)

import Html exposing (Html, program)
import Leagues.Create.State exposing (init, update, subscriptions)
import Leagues.Create.Types exposing (Model, Msg)
import Leagues.Create.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
