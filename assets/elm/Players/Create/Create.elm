module Players.Create exposing (main)

import Html exposing (program)
import Players.Create.State exposing (init, update, subscriptions)
import Players.Create.Types exposing (Model, Msg)
import Players.Create.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
